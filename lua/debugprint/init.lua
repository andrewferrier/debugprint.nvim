local M = {}

local utils = require("debugprint.utils")
local utils_buffer = require("debugprint.utils.buffer")
local utils_errors = require("debugprint.utils.errors")
local utils_operator = require("debugprint.utils.operator")

local global_opts
local default_counter = 0

---@return string
local default_display_counter = function()
    default_counter = default_counter + 1
    return "[" .. tostring(default_counter) .. "]"
end

---@param display_counter? boolean|function
---@return string
local get_debugline_tag_and_counter = function(display_counter)
    local tag_and_counter = ""

    if global_opts.print_tag then
        tag_and_counter = global_opts.print_tag
    end

    if display_counter == true then
        tag_and_counter = tag_and_counter .. default_display_counter()
    elseif type(display_counter) == "function" then
        tag_and_counter = tag_and_counter .. tostring(display_counter())
    end

    return tag_and_counter
end

---@param fileconfig DebugprintFileTypeConfig
---@return function|boolean?, boolean?, boolean?
local get_display_options = function(fileconfig)
    local display_counter
    if fileconfig.display_counter ~= nil then
        display_counter = fileconfig.display_counter
    else
        display_counter = global_opts.display_counter
    end

    local display_location
    if fileconfig.display_location ~= nil then
        display_location = fileconfig.display_location
    else
        display_location = global_opts.display_location
    end

    local display_snippet
    if fileconfig.display_snippet ~= nil then
        display_snippet = fileconfig.display_snippet
    else
        display_snippet = global_opts.display_snippet
    end

    return display_counter, display_location, display_snippet
end

---@param opts DebugprintFunctionOptionsInternal
---@param fileconfig DebugprintFileTypeConfig
---@return string
local get_debugline_textcontent = function(opts, fileconfig)
    local current_line_nr = vim.api.nvim_win_get_cursor(0)[1]

    local line_components = {}
    local force_snippet_for_plain = false

    local display_counter, display_location, display_snippet =
        get_display_options(fileconfig)

    if
        not display_location
        and not display_snippet
        and not display_counter
        and global_opts.print_tag == ""
    then
        force_snippet_for_plain = true
    end

    local tag_and_counter = get_debugline_tag_and_counter(display_counter)

    if tag_and_counter ~= "" then
        table.insert(line_components, tag_and_counter .. ":")
    end

    if display_location then
        table.insert(
            line_components,
            vim.fn.expand("%:t") .. ":" .. current_line_nr
        )
    end

    if
        (display_snippet or force_snippet_for_plain)
        and opts.variable_name == nil
    then
        local snippet = utils.get_snippet(current_line_nr, opts.above)

        if snippet then
            table.insert(line_components, snippet)
        end
    end

    local line = vim.fn.trim(table.concat(line_components, " "), ":")

    if opts.variable_name ~= nil then
        if line ~= "" then
            line = line .. ": "
        end

        line = line .. opts.variable_name .. "="
    end

    return line
end

---@return DebugprintFileTypeConfig?
local get_filetype_config = function()
    local effective_filetypes = utils.get_effective_filetypes()
    local config = {}
    local found_config = false

    for _, effective_filetype in ipairs(effective_filetypes) do
        if global_opts.filetypes[effective_filetype] ~= nil then
            found_config = true
            -- Combine all valid configs into the same object. This seems to
            -- make sense as an approach; the only case where I've found where
            -- this applies so far is ["bash", "sh"]. If this causes problems we
            -- may need to come up with something more sophisticated.
            config = vim.tbl_deep_extend(
                "keep",
                vim.deepcopy(global_opts.filetypes[effective_filetype]),
                config
            )
        end
    end

    if not found_config then
        return nil
    else
        return config
    end
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
            .. get_debugline_textcontent(opts, fileconfig)
            .. fileconfig.mid_var
            .. opts.variable_name
            .. fileconfig.right_var
    else
        opts.variable_name = nil
        line_to_insert = fileconfig.left
            .. get_debugline_textcontent(opts, fileconfig)
            .. fileconfig.right
    end

    return line_to_insert
end

---@param opts DebugprintFunctionOptionsInternal
---@return nil
local insert_debugprint_line = function(opts)
    local line_to_insert

    local fileconfig = get_filetype_config()

    if fileconfig ~= nil then
        line_to_insert = construct_debugprint_line(opts, fileconfig)
    else
        line_to_insert = utils_errors.construct_error_line(
            "No debugprint configuration for filetype "
                .. utils.get_effective_filetypes()[1]
                .. "; see https://github.com/andrewferrier/debugprint.nvim/"
                .. "blob/main/SHOWCASE.md#modifying-or-adding-filetypes"
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

    utils_buffer.indent_line(
        line_to_insert_linenr,
        global_opts.move_to_debugline
    )
end

local cache_request = {}

---@return nil
M.debugprint_operatorfunc_regular = function()
    insert_debugprint_line(cache_request)
    utils_operator.set_callback(
        "v:lua.require'debugprint'.debugprint_operatorfunc_regular"
    )
end

---@return nil
M.debugprint_operatorfunc_motion = function()
    cache_request.variable_name = utils_buffer.get_operator_selection()
    M.debugprint_operatorfunc_regular()
end

---@param opts DebugprintFunctionOptionsInternal
---@return nil
M.debugprint_regular = function(opts)
    if opts.variable == true then
        local filetype_config = get_filetype_config()

        if filetype_config then
            local ignore_treesitter

            if global_opts.ignore_treesitter or opts.ignore_treesitter then
                -- Works around issue with optional types
                ignore_treesitter = true
            end

            opts.variable_name =
                utils.get_variable_name(ignore_treesitter, filetype_config)

            if not opts.variable_name then
                return
            end
        end
    end

    cache_request = opts
    utils_operator.set_operatorfunc(
        "v:lua.require'debugprint'.debugprint_operatorfunc_regular"
    )
    return "g@l"
end

---@param opts? DebugprintFunctionOptions
---@return string?
M.debugprint = function(opts)
    local func_opts =
        require("debugprint.options").get_and_validate_function_opts(opts)

    ---@cast func_opts DebugprintFunctionOptionsInternal

    if not utils_buffer.is_modifiable() then
        return
    end

    if func_opts.motion == true then
        cache_request = func_opts
        utils_operator.set_operatorfunc(
            "v:lua.require'debugprint'.debugprint_operatorfunc_motion"
        )
        return "g@"
    else
        cache_request = {}
        return M.debugprint_regular(func_opts)
    end
end

---@param opts DebugprintCommandOpts
---@return nil
M.deleteprints = function(opts)
    if global_opts.print_tag == "" then
        vim.notify(
            "WARNING: no print_tag set, cannot delete lines.",
            vim.log.levels.WARN
        )

        return
    end

    local lines_to_consider, initial_line =
        utils_buffer.get_command_lines_to_handle(opts)
    local delete_adjust = 0
    local deleted_count = 0

    if not utils_buffer.is_modifiable() then
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
    if global_opts.print_tag == "" then
        vim.notify(
            "WARNING: no print_tag set, cannot comment-toggle lines.",
            vim.log.levels.WARN
        )

        return
    end

    local lines_to_consider, initial_line =
        utils_buffer.get_command_lines_to_handle(opts)
    local toggled_count = 0

    if not utils_buffer.is_modifiable() then
        return
    end

    for count, line in ipairs(lines_to_consider) do
        if string.find(line, global_opts.print_tag, 1, true) ~= nil then
            local line_to_toggle = count + initial_line - 1
            utils_buffer.toggle_comment_line(line_to_toggle)
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
