local M = {}

local opts

OPTION_DEFAULTS = {
    create_keymaps = true,
    move_to_debugline = false,
    filetypes = require("debugprint.filetypes"),
}

FUNCTION_OPTION_DEFAULTS = {
    above = false,
    variable = false,
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
    local filetype = vim.api.nvim_get_option_value(
        "filetype",
        { scope = "local" }
    )

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

local debugprint_logic = function(funcopts)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local filetype = vim.api.nvim_get_option_value(
        "filetype",
        { scope = "local" }
    )
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
            o.variable_name = vim.fn.input("Variable name: ")
        end

        cache_request = o
        vim.go.operatorfunc = "v:lua.require'debugprint'.debugprint_callback"
        return "g@l"
    end

    debugprint_logic(cache_request)

    set_callback("v:lua.require'debugprint'.debugprint_callback")
end

M.debugprint_callback = function()
    debugprint_cache()
end

M.debugprint = function(o)
    local funcopts = vim.tbl_deep_extend(
        "force",
        FUNCTION_OPTION_DEFAULTS,
        o or {}
    )

    vim.validate({
        above = { funcopts.above, "boolean" },
        variable = { funcopts.above, "boolean" },
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
        vim.keymap.set("n", "dqp", function()
            return M.debugprint()
        end, {
            expr = true,
        })
        vim.keymap.set("n", "dqP", function()
            return M.debugprint({ above = true })
        end, {
            expr = true,
        })
        vim.keymap.set("n", "dQp", function()
            return M.debugprint({ variable = true })
        end, {
            expr = true,
        })
        vim.keymap.set("n", "dQP", function()
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
