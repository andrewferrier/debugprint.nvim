local M = {}

---@type DebugprintGlobalOptions
local GLOBAL_OPTION_DEFAULTS = {
    keymaps = {
        normal = {
            plain_below = "g?p",
            plain_above = "g?P",
            variable_below = "g?v",
            variable_above = "g?V",
            variable_below_alwaysprompt = "",
            variable_above_alwaysprompt = "",
            textobj_below = "g?o",
            textobj_above = "g?O",
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
    commands = {
        toggle_comment_debug_prints = "ToggleCommentDebugPrints",
        delete_debug_prints = "DeleteDebugPrints",
        reset_debug_prints_counter = "ResetDebugPrintsCounter",
    },
    display_counter = true,
    display_location = true,
    display_snippet = true,
    move_to_debugline = false,
    notify_for_registers = true,
    filetypes = require("debugprint.filetypes"),
    print_tag = "DEBUGPRINT",
}

---@param o DebugprintGlobalOptions
---@return nil
local validate_global_opts = function(o)
    local STRING_FALSE_NIL = { "string", "boolean", "nil" }

    vim.validate({
        keymaps = { o.keymaps, "table" },
        commands = { o.commands, "table" },
        display_counter = { o.display_counter, { "function", "boolean" } },
        display_location = { o.display_location, "boolean" },
        display_snippet = { o.display_snippet, "boolean" },
        move_to_debugline = { o.move_to_debugline, "boolean" },
        notify_for_registers = { o.notify_for_registers, "boolean" },
        filetypes = { o.filetypes, "table" },
        print_tag = { o.print_tag, "string" },
    })

    vim.validate({
        keymaps_normal = { o.keymaps.normal, "table" },
        keymaps_visual = { o.keymaps.visual, "table" },

        commands_delete_debug_prints = {
            o.commands.delete_debug_prints,
            STRING_FALSE_NIL,
        },

        commands_toggle_comment_debug_prints = {
            o.commands.toggle_comment_debug_prints,
            STRING_FALSE_NIL,
        },

        commands_reset_debug_prints_counter = {
            o.commands.reset_debug_prints_counter,
            STRING_FALSE_NIL,
        },
    })

    local normal = o.keymaps.normal
    local insert = o.keymaps.insert
    local visual = o.keymaps.visual

    if normal ~= nil then
        vim.validate({
            plain_below = { normal.plain_below, STRING_FALSE_NIL },
            plain_above = { normal.plain_above, STRING_FALSE_NIL },
            variable_below = { normal.variable_below, STRING_FALSE_NIL },
            variable_above = { normal.variable_above, STRING_FALSE_NIL },
            variable_below_alwaysprompt = {
                normal.variable_below_alwaysprompt,
                STRING_FALSE_NIL,
            },
            variable_above_alwaysprompt = {
                normal.variable_above_alwaysprompt,
                STRING_FALSE_NIL,
            },
            textobj_below = { normal.textobj_below, STRING_FALSE_NIL },
            textobj_above = { normal.textobj_above, STRING_FALSE_NIL },
            delete_debug_prints = {
                normal.delete_debug_prints,
                STRING_FALSE_NIL,
            },
            toggle_comment_debug_prints = {
                normal.toggle_comment_debug_prints,
                STRING_FALSE_NIL,
            },
        })
    end

    if insert ~= nil then
        vim.validate({
            variable_below = { insert.plain, STRING_FALSE_NIL },
            variable_above = { insert.variable, STRING_FALSE_NIL },
        })
    end

    if visual ~= nil then
        vim.validate({
            variable_below = { visual.variable_below, STRING_FALSE_NIL },
            variable_above = { visual.variable_above, STRING_FALSE_NIL },
        })
    end
end

local FUNCTION_OPTION_DEFAULTS = {
    above = false,
    variable = false,
    ignore_treesitter = false,
    motion = false,
    insert = false,
}

---@param o DebugprintFunctionOptions
---@return nil
local validate_function_opts = function(o)
    vim.validate({
        above = { o.above, "boolean" },
        variable = { o.above, "boolean" },
        ignore_treesitter = { o.ignore_treesitter, "boolean" },
        motion = { o.motion, "boolean" },
        insert = { o.motion, "boolean" },
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

---@param opts? DebugprintFunctionOptions
---@return DebugprintFunctionOptions
M.get_and_validate_function_opts = function(opts)
    local func_opts = vim.tbl_deep_extend(
        "force",
        vim.deepcopy(FUNCTION_OPTION_DEFAULTS),
        opts or {}
    )

    validate_function_opts(func_opts)

    assert(not (func_opts.motion and func_opts.insert))
    assert(not (func_opts.motion and func_opts.variable))

    if not func_opts._skip_warning then
        vim.notify_once(
            "debugprint.nvim: mapping directly to the debugprint() function is deprecated and no longer supported. You are *STRONGLY RECOMMENDED* to use the inbuilt mapping approach: https://github.com/andrewferrier/debugprint.nvim?tab=readme-ov-file#mapping-deprecation",
            vim.log.levels.WARN
        )
    end

    return func_opts
end

return M
