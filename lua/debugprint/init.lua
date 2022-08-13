local M = {}

local opts

OPTION_DEFAULTS = {
    create_keymaps = true,
    move_to_debugline = false,
    ignore_treesitter = false,
    filetypes = require("debugprint.filetypes"),
}

FUNCTION_OPTION_DEFAULTS = {
    above = false,
    variable = false,
    ignore_treesitter = false,
}

local counter = 0

local debuginfo = function(variable_name)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    counter = counter + 1

    local line = "DEBUG["
        .. counter
        .. "]: "
        .. vim.fn.expand("%:t")
        .. ":"
        .. current_line

    if variable_name ~= nil then
        line = line .. ": " .. variable_name .. "="
    end

    return line
end

local filetype_configured = function()
    local filetype =
        vim.api.nvim_get_option_value("filetype", { scope = "local" })

    if not vim.tbl_contains(vim.tbl_keys(opts.filetypes), filetype) then
        vim.notify(
            "Don't have debugprint configuration for filetype " .. filetype,
            vim.log.levels.WARN
        )
        return false
    else
        return true
    end
end

local indent_line = function(current_line)
    local pos = vim.api.nvim_win_get_cursor(0)
    -- There's probably a better way to do this indent, but I don't know what it is
    vim.cmd(current_line + 1 .. "normal! ==")

    if not opts.move_to_debugline then
        vim.api.nvim_win_set_cursor(0, pos)
    end
end

local find_treesitter_variable = function()
    local function requiref(module)
        require(module)
    end

    local ts_utils_test = pcall(requiref, "nvim-treesitter.ts_utils")

    if not ts_utils_test then
        return nil
    else
        local ts_utils = require("nvim-treesitter.ts_utils")
        -- Once get_node_at_cursor() is in NeoVim core, the nvim-treesitter
        -- dependency can be removed: https://github.com/neovim/neovim/pull/18232
        local node = ts_utils.get_node_at_cursor()

        if node == nil then
            return nil
        else
            local node_type = node:type()
            local variable_name = vim.treesitter.query.get_node_text(node, 0)

            if node_type ~= "identifier" then
                return nil
            else
                return variable_name
            end
        end
    end
end

local get_visual_selection = function()
    local mode = vim.fn.mode():lower()
    if not (mode:find("^v") or mode:find("^ctrl-v")) then
        return nil
    end

    local first_pos, last_pos = vim.fn.getpos("v"), vim.fn.getpos(".")

    local line1 = first_pos[2] - 1
    local line2 = last_pos[2] - 1
    local col1 = first_pos[3] - 1
    local col2 = last_pos[3]

    if line2 < line1 or (line1 == line2 and col2 < col1) then
        local linet = line2
        line2 = line1
        line1 = linet

        local colt = col2
        col2 = col1
        col1 = colt

        col1 = col1 - 1
        col2 = col2 + 1
    end

    if line1 ~= line2 then
        vim.notify(
            "debugprint not supported when multiple lines selected.",
            vim.log.levels.ERROR
        )
        return false
    end

    return vim.api.nvim_buf_get_text(0, line1, col1, line2, col2, {})[1]
end

local debugprint_logic = function(funcopts)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local filetype =
        vim.api.nvim_get_option_value("filetype", { scope = "local" })
    local fixes = opts.filetypes[filetype]

    if fixes == nil then
        return
    end

    local line_to_insert
    local line_to_insert_on

    if funcopts.variable_name then
        line_to_insert = fixes.left
            .. debuginfo(funcopts.variable_name)
            .. fixes.mid_var
            .. funcopts.variable_name
            .. fixes.right_var
    else
        line_to_insert = fixes.left .. debuginfo() .. fixes.right
    end

    if funcopts.above then
        line_to_insert_on = current_line - 1
    else
        line_to_insert_on = current_line
    end

    vim.api.nvim_buf_set_lines(
        0,
        line_to_insert_on,
        line_to_insert_on,
        true,
        { line_to_insert }
    )

    indent_line(line_to_insert_on)
end

local cache_request = nil

M.NOOP = function() end

local set_callback = function(func_name)
    vim.go.operatorfunc = "v:lua.require'debugprint'.NOOP"
    vim.cmd("normal! g@l")
    vim.go.operatorfunc = func_name
end

local debugprint_cache = function(o)
    if o and o.prerepeat == true then
        if not filetype_configured() then
            return
        end

        if o.variable == true then
            o.variable_name = get_visual_selection()

            if o.variable_name == false then
                return
            end

            if
                o.variable_name == nil
                and o.ignore_treesitter ~= true
                and opts.ignore_treesitter ~= true
            then
                o.variable_name = find_treesitter_variable()
            end

            if o.variable_name == nil then
                o.variable_name = vim.fn.input("Variable name: ")
            end
        end

        cache_request = o
        vim.go.operatorfunc = "v:lua.require'debugprint'.debugprint_callback"
        return "g@l"
    end

    debugprint_logic(cache_request)

    set_callback("v:lua.require'debugprint'.debugprint_callback")
end

local notify_deprecated = function()
    vim.notify(
        "dqp and similar keymappings are deprecated for debugprint and are "
            .. "replaced with g?p, g?P, g?q, and g?Q. If you wish to continue "
            .. "using dqp etc., please see the Keymappings section in the README "
            .. "on how to map your own keymappings and map them explicitly. Thanks!",
        vim.log.levels.WARN
    )
end

M.debugprint_callback = function()
    debugprint_cache()
end

M.debugprint = function(o)
    local funcopts =
        vim.tbl_deep_extend("force", FUNCTION_OPTION_DEFAULTS, o or {})

    vim.validate({
        above = { funcopts.above, "boolean" },
        variable = { funcopts.above, "boolean" },
        ignore_treesitter = { funcopts.ignore_treesitter, "boolean" },
    })

    funcopts.prerepeat = true
    cache_request = nil
    return debugprint_cache(funcopts)
end

M.setup = function(o)
    opts = vim.tbl_deep_extend("force", OPTION_DEFAULTS, o or {})

    vim.validate({
        create_keymaps = { opts.create_keymaps, "boolean" },
    })

    if opts.create_keymaps then
        vim.keymap.set("n", "g?p", function()
            return M.debugprint()
        end, {
            expr = true,
        })
        vim.keymap.set("n", "g?P", function()
            return M.debugprint({ above = true })
        end, {
            expr = true,
        })
        vim.keymap.set("n", "g?v", function()
            return M.debugprint({ variable = true })
        end, {
            expr = true,
        })
        vim.keymap.set("n", "g?V", function()
            return M.debugprint({ above = true, variable = true })
        end, {
            expr = true,
        })
        vim.keymap.set("x", "g?v", function()
            return M.debugprint({ variable = true })
        end, {
            expr = true,
        })
        vim.keymap.set("x", "g?V", function()
            return M.debugprint({ above = true, variable = true })
        end, {
            expr = true,
        })

        vim.keymap.set("n", "dqp", function()
            notify_deprecated()
            return M.debugprint()
        end, {
            expr = true,
        })
        vim.keymap.set("n", "dqP", function()
            notify_deprecated()
            return M.debugprint({ above = true })
        end, {
            expr = true,
        })
        vim.keymap.set("n", "dQp", function()
            notify_deprecated()
            return M.debugprint({ variable = true })
        end, {
            expr = true,
        })
        vim.keymap.set("n", "dQP", function()
            notify_deprecated()
            return M.debugprint({ above = true, variable = true })
        end, {
            expr = true,
        })
    end

    -- Because we want to be idempotent, re-running setup() resets the counter
    counter = 0
end

M.add_custom_filetypes = function(filetypes)
    vim.validate({
        filetypes = { filetypes, "table" },
    })

    opts.filetypes = vim.tbl_deep_extend("force", opts.filetypes, filetypes)
end

return M
