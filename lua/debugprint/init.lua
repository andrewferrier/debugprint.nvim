local M = {}

local utils = require("debugprint.utils")

local global_opts

GLOBAL_OPTION_DEFAULTS = {
    create_keymaps = true,
    create_commands = true,
    move_to_debugline = false,
    ignore_treesitter = false,
    filetypes = require("debugprint.filetypes"),
    print_tag = "DEBUGPRINT",
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

    local line = global_opts.print_tag
        .. "["
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

    if not vim.tbl_contains(vim.tbl_keys(global_opts.filetypes), filetype) then
        vim.notify(
            "Don't have debugprint configuration for filetype " .. filetype,
            vim.log.levels.WARN
        )
        return false
    else
        return true
    end
end

M.NOOP = function() end

local set_callback = function(func_name)
    vim.go.operatorfunc = "v:lua.require'debugprint'.NOOP"
    vim.cmd("normal! g@l")
    vim.go.operatorfunc = func_name
end

local indent_line = function(current_line)
    local pos = vim.api.nvim_win_get_cursor(0)
    -- There's probably a better way to do this indent, but I don't know what it is
    vim.cmd(current_line + 1 .. "normal! ==")

    if not global_opts.move_to_debugline then
        vim.api.nvim_win_set_cursor(0, pos)
    end
end

local debugprint_addline = function(opts)
    local current_line_nr = vim.api.nvim_win_get_cursor(0)[1]
    local filetype =
        vim.api.nvim_get_option_value("filetype", { scope = "local" })
    local fixes = global_opts.filetypes[filetype]

    if fixes == nil then
        return
    end

    local line_to_insert_content
    local line_to_insert_linenr

    if opts.variable_name then
        line_to_insert_content = fixes.left
            .. debuginfo(opts.variable_name)
            .. fixes.mid_var
            .. opts.variable_name
            .. fixes.right_var
    else
        line_to_insert_content = fixes.left .. debuginfo() .. fixes.right
    end

    local current_line = vim.api.nvim_get_current_line()
    local leading_space = current_line:match('(%s+)') or ''

    if opts.above then
        line_to_insert_linenr = current_line_nr - 1
    else
        line_to_insert_linenr = current_line_nr
    end

    vim.api.nvim_buf_set_lines(
        0,
        line_to_insert_linenr,
        line_to_insert_linenr,
        true,
        { leading_space .. line_to_insert_content }
    )
    indent_line(line_to_insert_linenr)
end

local cache_request = nil

M.debugprint_cache = function(opts)
    if opts and opts.prerepeat == true then
        if not filetype_configured() then
            return
        end

        if opts.variable == true then
            opts.variable_name = utils.get_visual_selection()

            if opts.variable_name == false then
                return
            end

            if
                opts.variable_name == nil
                and opts.ignore_treesitter ~= true
                and global_opts.ignore_treesitter ~= true
            then
                opts.variable_name = utils.find_treesitter_variable()
            end

            if opts.variable_name == nil then
                opts.variable_name = vim.fn.input("Variable name: ")

                if opts.variable_name == nil or opts.variable_name == "" then
                    vim.notify("No variable name entered.", vim.log.levels.WARN)
                    return
                end
            end
        end

        cache_request = opts
        vim.go.operatorfunc = "v:lua.require'debugprint'.debugprint_cache"
        return "g@l"
    end

    debugprint_addline(cache_request)
    set_callback("v:lua.require'debugprint'.debugprint_cache")
end

M.debugprint = function(opts)
    local func_opts =
        vim.tbl_deep_extend("force", FUNCTION_OPTION_DEFAULTS, opts or {})

    vim.validate({
        above = { func_opts.above, "boolean" },
        variable = { func_opts.above, "boolean" },
        ignore_treesitter = { func_opts.ignore_treesitter, "boolean" },
    })

    if func_opts.motion == true then
        cache_request = func_opts
        vim.go.operatorfunc =
            "v:lua.require'debugprint'.debugprint_motion_callback"
        return "g@"
    else
        cache_request = nil
        func_opts.prerepeat = true
        return M.debugprint_cache(func_opts)
    end
end

M.debugprint_motion_callback = function()
    cache_request.variable_name = utils.get_operator_selection()
    debugprint_addline(cache_request)
    set_callback("v:lua.require'debugprint'.debugprint_cache")
end

M.deleteprints = function(opts)
    local lines_to_consider
    local initial_line

    -- opts.range appears to be the magic value that indicates a range is passed
    -- in and valid.

    if
        opts
        and (opts.range == 1 or opts.range == 2)
        and opts.line1
        and opts.line2
    then
        lines_to_consider =
            vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
        initial_line = opts.line1
    else
        lines_to_consider = vim.api.nvim_buf_get_lines(0, 0, -1, true)
        initial_line = 1
    end

    local delete_adjust = 0

    for count, line in ipairs(lines_to_consider) do
        if string.find(line, global_opts.print_tag) ~= nil then
            local line_to_delete = count
                - 1
                - delete_adjust
                + (initial_line - 1)
            vim.api.nvim_buf_set_lines(
                0,
                line_to_delete,
                line_to_delete + 1,
                false,
                {}
            )
            delete_adjust = delete_adjust + 1
        end
    end
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

M.setup = function(opts)
    global_opts =
        vim.tbl_deep_extend("force", GLOBAL_OPTION_DEFAULTS, opts or {})

    vim.validate({
        create_keymaps = { global_opts.create_keymaps, "boolean" },
        create_commands = { global_opts.create_commands, "boolean" },
        move_to_debugline = { global_opts.move_to_debugline, "boolean" },
        ignore_treesitter = { global_opts.ignore_treesitter, "boolean" },
        filetypes = { global_opts.filetypes, "table" },
        print_tag = { global_opts.print_tag, "string" },
    })

    if global_opts.create_keymaps then
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
        vim.keymap.set("n", "g?o", function()
            return M.debugprint({ motion = true })
        end, {
            expr = true,
        })
        vim.keymap.set("n", "g?O", function()
            return M.debugprint({ motion = true, above = true })
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

    if global_opts.create_commands then
        vim.api.nvim_create_user_command("DeleteDebugPrints", function(opts)
            M.deleteprints(opts)
        end, {
            range = true,
            desc = "Delete all debugprint statements in the current buffer.",
        })
    end

    -- Because we want to be idempotent, re-running setup() resets the counter
    counter = 0
end

M.add_custom_filetypes = function(filetypes)
    vim.validate({
        filetypes = { filetypes, "table" },
    })

    global_opts.filetypes =
        vim.tbl_deep_extend("force", global_opts.filetypes, filetypes)
end

return M
