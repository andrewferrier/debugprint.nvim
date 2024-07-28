local M = {}

local utils = require("debugprint.utils")

local global_opts
local default_counter = 0

MAX_SNIPPET_LENGTH = 40

---@param current_line integer
---@param above boolean
---@return string
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

---@return string
local default_display_counter = function()
    default_counter = default_counter + 1
    return "[" .. tostring(default_counter) .. "]"
end

---@param opts DebugprintFunctionOptionsInternal
---@return string
local debuginfo = function(opts)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    local line = global_opts.print_tag

    if global_opts.display_counter == true then
        line = line .. default_display_counter()
    elseif type(global_opts.display_counter) == "function" then
        line = line .. tostring(global_opts.display_counter())
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

---@return DebugprintFileTypeConfig?
local get_filetype_config = function()
    local effective_filetypes = utils.get_effective_filetypes()

    for _, effective_filetype in ipairs(effective_filetypes) do
        if global_opts.filetypes[effective_filetype] ~= nil then
            return global_opts.filetypes[effective_filetype]
        end
    end

    return nil
end

---@param opts DebugprintFunctionOptionsInternal
---@param fileconfig DebugprintFileTypeConfig
---@return nil
local construct_debugprint_line = function(opts, fileconfig)
    local line_to_insert

    if opts.variable_name then
        local left

        if fileconfig["left_var"] ~= nil then
            left = fileconfig["left_var"]
        else
            left = fileconfig["left"]
        end

        line_to_insert = left
            .. debuginfo(opts)
            .. fileconfig.mid_var
            .. opts.variable_name
            .. fileconfig.right_var
    else
        opts.variable_name = nil
        line_to_insert = fileconfig.left .. debuginfo(opts) .. fileconfig.right
    end

    return line_to_insert
end

---@param errormsg string
---@return nil
local construct_error_line = function(errormsg)
    local commentstring =
        vim.api.nvim_get_option_value("commentstring", { scope = "local" })

    if string.find(commentstring, "%%s") then
        return vim.fn.substitute(commentstring, "%s", errormsg, "")
    else
        return errormsg
    end
end

---@param opts DebugprintFunctionOptionsInternal
---@return nil
local addline = function(opts)
    local line_to_insert

    local fileconfig = get_filetype_config()

    if fileconfig ~= nil then
        line_to_insert = construct_debugprint_line(opts, fileconfig)
    else
        line_to_insert = construct_error_line(
            "No debugprint configuration for filetype "
                .. utils.get_effective_filetypes()[1]
                .. "; see https://github.com/andrewferrier/debugprint.nvim?tab=readme-ov-file#add-custom-filetypes"
        )
    end

    -- Inserting the leading space from the current line effectively acts as a
    -- 'default' indent for languages like Python, where the NeoVim or Treesitter
    -- indenter doesn't know how to indent them.
    local leading_space = vim.api.nvim_get_current_line():match("^(%s+)") or ""

    local current_line_nr = vim.api.nvim_win_get_cursor(0)[1]
    local line_to_insert_linenr

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
        { leading_space .. line_to_insert }
    )

    utils.indent_line(line_to_insert_linenr, global_opts.move_to_debugline)
end

local cache_request = {}

---@param opts DebugprintFunctionOptionsInternal
---@return nil
M.debugprint_cache = function(opts)
    if opts and opts.prerepeat == true then
        if opts.variable == true then
            local filetype_config = get_filetype_config()

            if filetype_config then
                opts.variable_name = utils.get_variable_name(
                    global_opts.ignore_treesitter or opts.ignore_treesitter,
                    filetype_config
                )

                if not opts.variable_name then
                    return
                end
            end
        end

        cache_request = opts
        vim.go.operatorfunc = "v:lua.require'debugprint'.debugprint_cache"
        return "g@l"
    end

    addline(cache_request)
    utils.set_callback("v:lua.require'debugprint'.debugprint_cache")
end

---@param opts DebugprintFunctionOptions
---@return nil
M.debugprint = function(opts)
    local func_opts =
        require("debugprint.options").get_and_validate_function_opts(opts)

    ---@cast func_opts DebugprintFunctionOptionsInternal

    if not utils.is_modifiable() then
        return
    end

    if func_opts.motion == true then
        cache_request = func_opts
        vim.go.operatorfunc =
            "v:lua.require'debugprint'.debugprint_motion_callback"
        return "g@"
    else
        cache_request = {}
        func_opts.prerepeat = true
        return M.debugprint_cache(func_opts)
    end
end

---@return nil
M.debugprint_motion_callback = function()
    cache_request.variable_name = utils.get_operator_selection()
    addline(cache_request)
    utils.set_callback("v:lua.require'debugprint'.debugprint_cache")
end

---@param opts DebugprintCommandOpts
---@return string[],integer
local get_lines_to_handle = function(opts)
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

    return lines_to_consider, initial_line
end

---@param opts DebugprintCommandOpts
---@return nil
M.deleteprints = function(opts)
    local lines_to_consider, initial_line = get_lines_to_handle(opts)
    local delete_adjust = 0
    local deleted_count = 0

    if not utils.is_modifiable() then
        return
    end

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
            deleted_count = deleted_count + 1
        end
    end

    if deleted_count == 1 then
        vim.notify(deleted_count .. " debug line deleted.", vim.log.levels.INFO)
    else
        vim.notify(
            deleted_count .. " debug lines deleted.",
            vim.log.levels.INFO
        )
    end
end

---@param opts DebugprintCommandOpts
---@return nil
M.toggle_comment_debugprints = function(opts)
    local lines_to_consider, initial_line = get_lines_to_handle(opts)
    local toggled_count = 0

    if not utils.is_modifiable() then
        return
    end

    for count, line in ipairs(lines_to_consider) do
        if string.find(line, global_opts.print_tag, 1, true) ~= nil then
            local line_to_toggle = count + initial_line - 1
            utils.toggle_comment_line(line_to_toggle)
            toggled_count = toggled_count + 1
        end
    end

    if toggled_count == 1 then
        vim.notify(
            toggled_count .. " debug line comment-toggled.",
            vim.log.levels.INFO
        )
    else
        vim.notify(
            toggled_count .. " debug lines comment-toggled.",
            vim.log.levels.INFO
        )
    end
end

---@param opts? DebugprintGlobalOptions
---@return nil
M.setup = function(opts)
    global_opts =
        require("debugprint.options").get_and_validate_global_opts(opts)

    require("debugprint.setup").map_keys_and_commands(global_opts)

    -- Because we want to be idempotent, re-running setup() resets the counter
    default_counter = 0
end

---@param filetypes DebugprintFileTypeConfig[]
---@return nil
M.add_custom_filetypes = function(filetypes)
    vim.validate({
        filetypes = { filetypes, "table" },
    })

    global_opts.filetypes =
        vim.tbl_deep_extend("force", global_opts.filetypes, filetypes)
end

if vim.fn.has("nvim-0.9.0") ~= 1 then
    vim.notify_once(
        "WARNING: debugprint.nvim is only compatible with NeoVim 0.9+",
        vim.log.levels.WARN
    )

    return
end

return M
