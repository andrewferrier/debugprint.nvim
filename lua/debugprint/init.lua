local M = {}

local utils = require("debugprint.utils")

local global_opts
local counter = 0

MAX_SNIPPET_LENGTH = 40

local get_snippet = function(current_line, above)
    local line_contents = ""

    while line_contents == "" do
        line_contents = utils.get_trimmed_content_of_line(current_line)

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

    utils.indent_line(line_to_insert_linenr, global_opts.move_to_debugline)
end

local cache_request = nil

M.debugprint_cache = function(opts)
    if opts and opts.prerepeat == true then
        if not filetype_configured() then
            return
        end

        if opts.variable == true then
            opts.variable_name = utils.get_variable_name(
                global_opts.ignore_treesitter,
                opts.ignore_treesitter
            )

            if opts.variable_name == false then
                return
            end
        end

        cache_request = opts
        vim.go.operatorfunc = "v:lua.require'debugprint'.debugprint_cache"
        return "g@l"
    end

    addline(cache_request)
    utils.set_callback("v:lua.require'debugprint'.debugprint_cache")
end

M.debugprint = function(opts)
    local func_opts =
        require("debugprint.options").get_and_validate_function_opts(opts)

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
    utils.set_callback("v:lua.require'debugprint'.debugprint_cache")
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
        require("debugprint.options").get_and_validate_global_opts(opts)

    require("debugprint.setup").map_keys_and_commands(global_opts)

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
