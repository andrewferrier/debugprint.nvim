local M = {}

local utils = require("debugprint.utils")
local utils_buffer = require("debugprint.utils.buffer")
local utils_errors = require("debugprint.utils.errors")
local utils_operator = require("debugprint.utils.operator")
local utils_register = require("debugprint.utils.register")

---@type debugprint.GlobalOptions
local global_opts

---@param display_counter? boolean|function
---@return string
local get_debugline_tag_and_counter = function(display_counter)
    local tag_and_counter = ""

    if global_opts.print_tag then
        tag_and_counter = global_opts.print_tag
    end

    if display_counter == true then
        tag_and_counter = tag_and_counter
            .. require("debugprint.counter").default_display_counter()
    elseif type(display_counter) == "function" then
        tag_and_counter = tag_and_counter .. tostring(display_counter())
    end

    ---@cast tag_and_counter string
    return tag_and_counter
end

---@param fileconfig debugprint.FileTypeConfig
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

---@param linenr integer
---@param fileconfig debugprint.FileTypeConfig
---@return string
local get_debugline_location = function(linenr, fileconfig)
    if fileconfig.location then
        return fileconfig.location
    else
        return vim.fn.expand("%:t") .. ":" .. linenr
    end
end

---@param opts debugprint.FunctionOptionsInternal
---@param fileconfig debugprint.FileTypeConfig
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
            get_debugline_location(current_line_nr, fileconfig)
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

---@param opts debugprint.FunctionOptionsInternal
---@param fileconfig debugprint.FileTypeConfig
---@return string
local get_debugprint_line_core = function(opts, fileconfig)
    ---@type string
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

---@param opts debugprint.FunctionOptionsInternal
---@return string
local get_debugprint_line = function(opts)
    ---@type string
    local line_to_insert

    local filetype_config =
        require("debugprint.filetype_config").get(global_opts.filetypes)

    if filetype_config ~= nil then
        line_to_insert = get_debugprint_line_core(opts, filetype_config)
    else
        line_to_insert = utils_errors.construct_error_line(
            "No debugprint configuration for filetype "
                .. utils.get_effective_filetypes()[1]
                .. "; see https://github.com/andrewferrier/debugprint.nvim/"
                .. "blob/main/SHOWCASE.md#modifying-or-adding-filetypes"
        )
    end

    return line_to_insert
end

---@param opts debugprint.FunctionOptionsInternal
---@param keys string
local add_to_register = function(opts, keys)
    utils_register.set_register(keys)

    if global_opts.notify_for_registers then
        ---@type string
        local content

        if opts.variable_name then
            content = "variable debug line (" .. opts.variable_name .. ")"
        else
            content = "plain debug line"
        end

        if utils_register.register_append() then
            vim.notify(
                "Appended " .. content .. " to register " .. opts.register
            )
        else
            vim.notify(
                "Written " .. content .. " to register " .. opts.register
            )
        end
    end
end

---@param opts debugprint.FunctionOptionsInternal
---@return nil
local handle_debugprint_line = function(opts)
    -- Inserting the leading space from the current line effectively acts as a
    -- 'default' indent for languages like Python, where the NeoVim or Treesitter
    -- indenter doesn't know how to indent them.
    local leading_space = vim.api.nvim_get_current_line():match("^(%s+)") or ""
    local line_content = leading_space .. get_debugprint_line(opts)

    if opts.register then
        add_to_register(opts, line_content)
    else
        local line_nr = vim.api.nvim_win_get_cursor(0)[1]

        if opts.above then
            line_nr = line_nr - 1
        end

        ---@type boolean
        local move_to_debugline = global_opts.move_to_debugline

        if opts.surround == true then
            move_to_debugline = false
        end

        utils_buffer.insert_and_indent_line(
            line_nr,
            line_content,
            move_to_debugline
        )
    end
end

local cache_request = {}

---@return nil
M.debugprint_operatorfunc_regular = function()
    if cache_request.surround then
        local cache_request_copy = vim.deepcopy(cache_request)

        cache_request_copy.above = true
        handle_debugprint_line(cache_request_copy)

        cache_request_copy.above = false
        handle_debugprint_line(cache_request_copy)
    else
        handle_debugprint_line(cache_request)
    end

    utils_operator.set_callback(
        "v:lua.require'debugprint'.debugprint_operatorfunc_regular"
    )
end

---@return nil
M.debugprint_operatorfunc_motion = function()
    cache_request.variable_name = utils_buffer.get_operator_selection()
    M.debugprint_operatorfunc_regular()
end

---@param opts? debugprint.FunctionOptions
---@return string|nil
M.debugprint = function(opts)
    opts = require("debugprint.options").get_and_validate_function_opts(opts)
    opts.register = utils_register.register_named()

    require("debugprint.options").check_function_opts_compatibility(opts)

    if not utils_buffer.is_modifiable() then
        return
    end

    if opts.variable == true then
        local filetype_config =
            require("debugprint.filetype_config").get(global_opts.filetypes)

        if filetype_config then
            opts.variable_name = utils.get_variable_name(
                global_opts.ignore_treesitter or opts.ignore_treesitter or false,
                filetype_config
            )

            if not opts.variable_name then
                return
            end
        end
    end

    if opts.motion == true then
        cache_request = opts
        utils_operator.set_operatorfunc(
            "v:lua.require'debugprint'.debugprint_operatorfunc_motion"
        )
        return "g@"
    end

    if opts.insert == true then
        cache_request = {}
        vim.api.nvim_put({ get_debugprint_line(opts) }, "c", true, true)
    else
        cache_request = opts
        utils_operator.set_operatorfunc(
            "v:lua.require'debugprint'.debugprint_operatorfunc_regular"
        )
        vim.api.nvim_cmd({ cmd = "normal", bang = true, args = { "g@l" } }, {})
    end
end

---@param opts? debugprint.GlobalOptions
---@return nil
M.setup = function(opts)
    global_opts =
        require("debugprint.options").get_and_validate_global_opts(opts)

    require("debugprint.health").set_global_opts(global_opts)
    require("debugprint.printtag_operations").set_print_tag(
        global_opts.print_tag
    )
    require("debugprint.printtag_operations").set_picker(global_opts.picker)

    require("debugprint.setup").map_keys_and_commands(global_opts)

    if global_opts.highlight_lines then
        require("debugprint.highlight").setup_highlight(
            global_opts.filetypes,
            global_opts.print_tag,
            global_opts.highlight_lines
        )
    end
end

---@param filetypes debugprint.FileTypeConfigOrDynamic[]
---@return nil
M.add_custom_filetypes = function(filetypes)
    vim.validate({
        filetypes = { filetypes, "table" },
    })

    global_opts.filetypes =
        vim.tbl_deep_extend("force", global_opts.filetypes, filetypes)
end

if vim.fn.has("nvim-0.10.0") ~= 1 then
    vim.notify_once(
        "debugprint.nvim is only compatible with NeoVim 0.10+",
        vim.log.levels.WARN
    )

    return
end

return M
