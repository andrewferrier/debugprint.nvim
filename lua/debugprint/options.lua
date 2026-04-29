local M = {}

---@type debugprint.GlobalOptions
local GLOBAL_OPTION_DEFAULTS = {
    keymaps = {
        normal = {
            plain_below = "g?p",
            plain_above = "g?P",
            variable_below = "g?v",
            variable_above = "g?V",
            variable_below_alwaysprompt = "",
            variable_above_alwaysprompt = "",
            surround_plain = "g?sp",
            surround_variable = "g?sv",
            surround_variable_alwaysprompt = "",
            textobj_below = "g?o",
            textobj_above = "g?O",
            textobj_surround = "g?so",
            toggle_comment_debug_prints = "",
            delete_debug_prints = "",
        },
        insert = {
            plain = "<C-G>p",
            variable = "<C-G>v",
        },
        visual = {
            variable_below = "g?v",
            variable_above = "g?V",
        },
    },
    display_counter = true,
    display_location = true,
    display_snippet = true,
    display_timestamp = false,
    move_to_debugline = false,
    notify_for_registers = true,
    highlight_lines = function(bufnr)
        -- Check if filetype is 'bigfile' as set by snacks' bigfile support:
        -- https://github.com/folke/snacks.nvim/blob/main/docs/bigfile.md
        if vim.bo.filetype == "bigfile" then
            return false
        end

        -- Check file size on disk
        local filename = vim.api.nvim_buf_get_name(bufnr)
        if filename ~= "" then
            local size = vim.fn.getfsize(filename)
            if size > 0 and size > 512 * 1024 then -- 512KB
                return false
            end
        end

        -- Check line count
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        if line_count > 5000 then
            return false
        end

        return true
    end,
    filetypes = require("debugprint.filetypes"),
    print_tag = "DEBUGPRINT",
    picker = nil,
}

local STRING_OR_BOOLEAN = { "string", "boolean" }

---@param o debugprint.GlobalOptions
---@return nil
local validate_global_opts = function(o)
    vim.validate("keymaps", o.keymaps, "table")
    vim.validate(
        "display_counter",
        o.display_counter,
        { "function", "boolean" }
    )
    vim.validate("display_location", o.display_location, "boolean")
    vim.validate("display_snippet", o.display_snippet, "boolean")
    vim.validate("display_timestamp", o.display_timestamp, "boolean")
    vim.validate("move_to_debugline", o.move_to_debugline, "boolean")
    vim.validate("notify_for_registers", o.notify_for_registers, "boolean")
    vim.validate(
        "highlight_lines",
        o.highlight_lines,
        { "function", "boolean" }
    )
    vim.validate("filetypes", o.filetypes, "table")
    vim.validate("print_tag", o.print_tag, "string")
    vim.validate("picker", o.picker, "string", true)

    vim.validate("keymaps_normal", o.keymaps.normal, "table")
    vim.validate("keymaps_visual", o.keymaps.visual, "table")

    local normal = o.keymaps.normal
    local insert = o.keymaps.insert
    local visual = o.keymaps.visual

    if normal ~= nil then
        vim.validate("plain_below", normal.plain_below, STRING_OR_BOOLEAN, true)
        vim.validate("plain_above", normal.plain_above, STRING_OR_BOOLEAN, true)
        vim.validate(
            "variable_below",
            normal.variable_below,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "variable_above",
            normal.variable_above,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "variable_below_alwaysprompt",
            normal.variable_below_alwaysprompt,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "variable_above_alwaysprompt",
            normal.variable_above_alwaysprompt,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "surround_plain",
            normal.surround_plain,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "surround_variable",
            normal.surround_variable,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "surround_variable_alwaysprompt",
            normal.surround_variable_alwaysprompt,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "textobj_below",
            normal.textobj_below,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "textobj_above",
            normal.textobj_above,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "textobj_surround",
            normal.textobj_surround,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "delete_debug_prints",
            normal.delete_debug_prints,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "toggle_comment_debug_prints",
            normal.toggle_comment_debug_prints,
            STRING_OR_BOOLEAN,
            true
        )
    end

    if insert ~= nil then
        vim.validate("plain", insert.plain, STRING_OR_BOOLEAN, true)
        vim.validate("variable", insert.variable, STRING_OR_BOOLEAN, true)
    end

    if visual ~= nil then
        vim.validate(
            "variable_below",
            visual.variable_below,
            STRING_OR_BOOLEAN,
            true
        )
        vim.validate(
            "variable_above",
            visual.variable_above,
            STRING_OR_BOOLEAN,
            true
        )
    end
end

local FUNCTION_OPTION_DEFAULTS = {
    above = false,
    variable = false,
    ignore_treesitter = false,
    motion = false,
    insert = false,
    surround = false,
}

---@param o debugprint.FunctionOptions
---@return nil
local validate_function_opts = function(o)
    vim.validate("above", o.above, "boolean")
    vim.validate("variable", o.variable, "boolean")
    vim.validate("ignore_treesitter", o.ignore_treesitter, "boolean")
    vim.validate("motion", o.motion, "boolean")
    vim.validate("insert", o.insert, "boolean")
    vim.validate("surround", o.surround, "boolean")
end

---@param opts? debugprint.GlobalOptions
---@return debugprint.GlobalOptions
M.get_and_validate_global_opts = function(opts)
    opts = opts or {}

    local global_opts =
        vim.tbl_deep_extend("force", vim.deepcopy(GLOBAL_OPTION_DEFAULTS), opts)

    validate_global_opts(global_opts)

    if opts["create_keymaps"] ~= nil then
        vim.deprecate(
            "`create_keymaps` option",
            "`keymaps` option",
            "in a future version, use ':help debugprint.nvim-mapping-deprecation' for more information",
            "debugprint.nvim",
            false
        )

        if opts.create_keymaps == false then
            global_opts.keymaps.normal = {}
            global_opts.keymaps.visual = {}
        end
    end

    if opts["create_commands"] ~= nil then
        vim.deprecate(
            "`create_commands` option",
            "`commands` option",
            "in a future version, use ':help debugprint.nvim-mapping-deprecation' for more information",
            "debugprint.nvim",
            false
        )

        if opts.create_commands == false then
            global_opts.commands = {}
        end
    end

    if opts["ignore_treesitter"] ~= nil then
        vim.deprecate(
            "`ignore_treesitter` option",
            "`*_alwaysprompt` keymappings",
            "in a future version, see ':help debugprint.nvim-keymappings-and-commands' for more information",
            "debugprint.nvim",
            false
        )
    end

    return global_opts
end

---@param opts? debugprint.FunctionOptions
---@return debugprint.FunctionOptionsInternal
M.get_and_validate_function_opts = function(opts)
    local func_opts = vim.tbl_deep_extend(
        "force",
        vim.deepcopy(FUNCTION_OPTION_DEFAULTS),
        opts or {}
    )

    validate_function_opts(func_opts)

    ---@cast func_opts debugprint.FunctionOptionsInternal

    return func_opts
end

---@param opts debugprint.FunctionOptionsInternal
---@return nil
M.check_function_opts_compatibility = function(opts)
    assert(not (opts.register and opts.insert))
    assert(not (opts.register and opts.surround))

    assert(not (opts.motion and opts.insert))
    assert(not (opts.motion and opts.variable))
end

return M
