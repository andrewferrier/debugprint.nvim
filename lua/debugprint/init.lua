local M = {}

local utils = require("debugprint.utils")

local global_opts

GLOBAL_OPTION_DEFAULTS = {
    create_keymaps = true,
    create_commands = true,
    display_counter = true,
    display_snippet = true,
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

MAX_SNIPPET_LENGTH = 40

local validate_global_opts = function(o)
    vim.validate({
        create_keymaps = { o.create_keymaps, "boolean" },
        create_commands = { o.create_commands, "boolean" },
        display_counter = { o.move_to_debugline, "boolean" },
        display_snippet = { o.move_to_debugline, "boolean" },
        move_to_debugline = { o.move_to_debugline, "boolean" },
        ignore_treesitter = { o.ignore_treesitter, "boolean" },
        filetypes = { o.filetypes, "table" },
        print_tag = { o.print_tag, "string" },
    })
end

local validate_function_opts = function(o)
    vim.validate({
        above = { o.above, "boolean" },
        variable = { o.above, "boolean" },
        ignore_treesitter = { o.ignore_treesitter, "boolean" },
    })
end

local counter = 0

local get_trimmed_content_of_line = function(line)
    local line_contents = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]

    -- Remove whitespace and any quoting characters which could potentially
    -- cause a syntax error in the statement being printed, or any characters
    -- which could cause unintended interpolation of expressions
    line_contents = line_contents:gsub("^%s+", "") -- leading
    line_contents = line_contents:gsub("%s+$", "") -- trailing
    line_contents = line_contents:gsub("[\"'\\`%${}]", "")

    return line_contents
end

local get_snippet = function(current_line, above)
    local line_contents = ""

    while line_contents == "" do
        line_contents = get_trimmed_content_of_line(current_line)

        if line_contents == "" then
            if above then
                current_line = current_line + 1
            else
                current_line = current_line - 1
            end

            if current_line < 1 then
                return "(start of file)"
            end

            if current_line > vim.api.nvim_buf_line_count(0) then
                return "(end of file)"
            end
        end
    end

    if line_contents:len() > MAX_SNIPPET_LENGTH then
        line_contents = string.sub(line_contents, 0, MAX_SNIPPET_LENGTH)
            .. "…"
    end

    if above then
        line_contents = "(before " .. line_contents .. ")"
    else
        line_contents = "(after " .. line_contents .. ")"
    end

    return line_contents
end

local debuginfo = function(opts)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    counter = counter + 1

    local line = global_opts.print_tag

    if global_opts.display_counter then
        line = line .. "[" .. counter .. "]"
    end

    line = line .. ": " .. vim.fn.expand("%:t") .. ":" .. current_line

    if global_opts.display_snippet and opts.variable_name == nil then
        local snippet = get_snippet(current_line, opts.above)

        if snippet then
            line = line .. " " .. snippet
        end
    end

    if opts.variable_name ~= nil then
        line = line .. ": " .. opts.variable_name .. "="
    end

    return line
end

local filetype_configured = function()
    local filetype = utils.get_effective_filetype()

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

local addline = function(opts)
    local current_line_nr = vim.api.nvim_win_get_cursor(0)[1]
    local filetype = utils.get_effective_filetype()
    local fileconfig = global_opts.filetypes[filetype]

    if fileconfig == nil then
        return
    end

    local line_to_insert_content
    local line_to_insert_linenr

    if opts.variable_name then
        local left

        if fileconfig["left_var"] ~= nil then
            left = fileconfig["left_var"]
        else
            left = fileconfig["left"]
        end

        line_to_insert_content = left
            .. debuginfo(opts)
            .. fileconfig.mid_var
            .. opts.variable_name
            .. fileconfig.right_var
    else
        opts.variable_name = nil
        line_to_insert_content = fileconfig.left
            .. debuginfo(opts)
            .. fileconfig.right
    end

    -- Inserting the leading space from the current line effectively acts as a
    -- 'default' indent for languages like Python, where the NeoVim or Treesitter
    -- indenter doesn't know how to indent them.
    local current_line = vim.api.nvim_get_current_line()
    local leading_space = current_line:match("^(%s+)") or ""

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

local get_variable_name = function(opts)
    local variable_name = utils.get_visual_selection()

    if variable_name == false then
        return false
    end

    if
        variable_name == nil
        and opts.ignore_treesitter ~= true
        and global_opts.ignore_treesitter ~= true
    then
        variable_name = utils.find_treesitter_variable()
    end

    if variable_name == nil then
        local word_under_cursor = vim.fn.expand("<cword>")
        variable_name = vim.fn.input("Variable name: ", word_under_cursor)

        if variable_name == nil or variable_name == "" then
            vim.notify("No variable name entered.", vim.log.levels.WARN)
            return false
        end
    end

    return variable_name
end

local cache_request = nil

M.debugprint_cache = function(opts)
    if opts and opts.prerepeat == true then
        if not filetype_configured() then
            return
        end

        if opts.variable == true then
            opts.variable_name = get_variable_name(opts)

            if opts.variable_name == false then
                return
            end
        end

        cache_request = opts
        vim.go.operatorfunc = "v:lua.require'debugprint'.debugprint_cache"
        return "g@l"
    end

    addline(cache_request)
    set_callback("v:lua.require'debugprint'.debugprint_cache")
end

M.debugprint = function(opts)
    local func_opts =
        vim.tbl_deep_extend("force", FUNCTION_OPTION_DEFAULTS, opts or {})

    validate_function_opts(func_opts)

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
    addline(cache_request)
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
        if string.find(line, global_opts.print_tag, 1, true) ~= nil then
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

M.setup = function(opts)
    global_opts =
        vim.tbl_deep_extend("force", GLOBAL_OPTION_DEFAULTS, opts or {})

    validate_global_opts(global_opts)

    if global_opts.create_keymaps then
        vim.keymap.set("n", "g?p", function()
            return M.debugprint()
        end, {
            expr = true,
            desc = "Plain debug below current line",
        })
        vim.keymap.set("n", "g?P", function()
            return M.debugprint({ above = true })
        end, {
            expr = true,
            desc = "Plain debug above current line",
        })
        vim.keymap.set({ "n", "x" }, "g?v", function()
            return M.debugprint({ variable = true })
        end, {
            expr = true,
            desc = "Variable debug below current line",
        })
        vim.keymap.set({ "n", "x" }, "g?V", function()
            return M.debugprint({ above = true, variable = true })
        end, {
            expr = true,
            desc = "Variable debug above current line",
        })
        vim.keymap.set("n", "g?o", function()
            return M.debugprint({ motion = true })
        end, {
            expr = true,
            desc = "Text-obj-selected variable debug below current line",
        })
        vim.keymap.set("n", "g?O", function()
            return M.debugprint({ motion = true, above = true })
        end, {
            expr = true,
            desc = "Text-obj-selected variable debug above current line",
        })
    end

    if global_opts.create_commands then
        vim.api.nvim_create_user_command("DeleteDebugPrints", function(cmd_opts)
            M.deleteprints(cmd_opts)
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

if vim.fn.has("nvim-0.8.0") ~= 1 then
    vim.notify(
        "WARNING: debugprint.nvim is only compatible with NeoVim 0.8+",
        vim.log.levels.WARN
    )

    return
end

return M
