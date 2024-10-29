local M = {}

---@type DebugprintGlobalOptions
local GLOBAL_OPTION_DEFAULTS = {
    keymaps = {
        normal = {
            plain_below = "g?p",
            plain_above = "g?P",
            variable_below = "g?v",
            variable_above = "g?V",
            variable_below_alwaysprompt = nil,
            variable_above_alwaysprompt = nil,
            textobj_below = "g?o",
            textobj_above = "g?O",
            toggle_comment_debug_prints = nil,
            delete_debug_prints = nil,
        },
        visual = {
            variable_below = "g?v",
            variable_above = "g?V",
        },
    },
    commands = {
        toggle_comment_debug_prints = "ToggleCommentDebugPrints",
        delete_debug_prints = "DeleteDebugPrints",
    },
    display_counter = true,
    display_location = true,
    display_snippet = true,
    move_to_debugline = false,
    filetypes = require("debugprint.filetypes"),
    print_tag = "DEBUGPRINT",
}

---@param o DebugprintGlobalOptions
---@return nil
local validate_global_opts = function(o)
    local STRING_NIL = { "string", "nil" }

    vim.validate({
        keymaps = { o.keymaps, "table" },
        commands = { o.commands, "table" },
        display_counter = { o.display_counter, { "function", "boolean" } },
        display_location = { o.display_location, "boolean" },
        display_snippet = { o.display_snippet, "boolean" },
        move_to_debugline = { o.move_to_debugline, "boolean" },
        filetypes = { o.filetypes, "table" },
        print_tag = { o.print_tag, "string" },
    })

    vim.validate({
        keymaps_normal = { o.keymaps.normal, "table" },
        keymaps_visual = { o.keymaps.visual, "table" },

        commands_delete_debug_prints = {
            o.commands.delete_debug_prints,
            STRING_NIL,
        },

        commands_toggle_comment_debug_prints = {
            o.commands.toggle_comment_debug_prints,
            STRING_NIL,
        },
    })

    local normal = o.keymaps.normal
    local visual = o.keymaps.visual

    vim.validate({
        plain_below = { normal.plain_below, STRING_NIL },
        plain_above = { normal.plain_above, STRING_NIL },
        variable_below = { normal.variable_below, STRING_NIL },
        variable_above = { normal.variable_above, STRING_NIL },
        variable_below_alwaysprompt = {
            normal.variable_below_alwaysprompt,
            STRING_NIL,
        },
        variable_above_alwaysprompt = {
            normal.variable_above_alwaysprompt,
            STRING_NIL,
        },
        textobj_below = { normal.textobj_below, STRING_NIL },
        textobj_above = { normal.textobj_above, STRING_NIL },
        delete_debug_prints = { normal.delete_debug_prints, STRING_NIL },
        toggle_comment_debug_prints = {
            normal.toggle_comment_debug_prints,
            STRING_NIL,
        },
    })

    vim.validate({
        variable_below = { visual.variable_below, STRING_NIL },
        variable_above = { visual.variable_above, STRING_NIL },
    })
end

local FUNCTION_OPTION_DEFAULTS = {
    above = false,
    variable = false,
    ignore_treesitter = false,
}

---@param o DebugprintFunctionOptions
---@return nil
local validate_function_opts = function(o)
    vim.validate({
        above = { o.above, "boolean" },
        variable = { o.above, "boolean" },
        ignore_treesitter = { o.ignore_treesitter, "boolean" },
    })
end

---@param opts? DebugprintGlobalOptions
---@return DebugprintGlobalOptions
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

---@param opts DebugprintFunctionOptions
---@return DebugprintFunctionOptions
M.get_and_validate_function_opts = function(opts)
    local func_opts = vim.tbl_deep_extend(
        "force",
        vim.deepcopy(FUNCTION_OPTION_DEFAULTS),
        opts or {}
    )

    validate_function_opts(func_opts)

    return func_opts
end

return M
