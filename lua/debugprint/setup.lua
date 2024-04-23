local M = {}

local debugprint = require("debugprint")

local map_key = function(mode, lhs, opts)
    if lhs ~= nil then
        vim.api.nvim_set_keymap(mode, lhs, "", opts)
    end
end

local feedkeys = function(keys)
    if keys ~= nil and keys ~= "" then
        vim.api.nvim_feedkeys(keys, "xt", true)
    end
end

M.map_keys_and_commands = function(global_opts)
    map_key("n", global_opts.keymaps.normal.plain_below, {
        callback = function()
            feedkeys(debugprint.debugprint({}))
        end,
        desc = "Plain debug below current line",
    })

    map_key("n", global_opts.keymaps.normal.plain_above, {
        callback = function()
            feedkeys(debugprint.debugprint({ above = true }))
        end,
        desc = "Plain debug below current line",
    })

    map_key("n", global_opts.keymaps.normal.variable_below, {
        callback = function()
            feedkeys(debugprint.debugprint({ variable = true }))
        end,
        desc = "Variable debug below current line",
    })

    map_key("n", global_opts.keymaps.normal.variable_above, {
        callback = function()
            feedkeys(debugprint.debugprint({
                above = true,
                variable = true,
            }))
        end,
        desc = "Variable debug above current line",
    })

    map_key("n", global_opts.keymaps.normal.variable_below_alwaysprompt, {
        callback = function()
            feedkeys(debugprint.debugprint({
                variable = true,
                ignore_treesitter = true,
            }))
        end,
        desc = "Variable debug below current line (always prompt})",
    })

    map_key("n", global_opts.keymaps.normal.variable_above_alwaysprompt, {
        callback = function()
            feedkeys(debugprint.debugprint({
                above = true,
                variable = true,
                ignore_treesitter = true,
            }))
        end,
        desc = "Variable debug above current line (always prompt})",
    })

    map_key("n", global_opts.keymaps.normal.textobj_below, {
        callback = function()
            return debugprint.debugprint({ motion = true })
        end,
        expr = true,
        desc = "Text-obj-selected variable debug below current line",
    })

    map_key("n", global_opts.keymaps.normal.textobj_above, {
        callback = function()
            return debugprint.debugprint({
                motion = true,
                above = true,
            })
        end,
        expr = true,
        desc = "Text-obj-selected variable debug above current line",
    })

    map_key("x", global_opts.keymaps.visual.variable_below, {
        callback = function()
            feedkeys(debugprint.debugprint({ variable = true }))
        end,
        desc = "Variable debug below current line",
    })

    map_key("x", global_opts.keymaps.visual.variable_above, {
        callback = function()
            feedkeys(debugprint.debugprint({
                above = true,
                variable = true,
            }))
        end,
        desc = "Variable debug above current line",
    })

    map_key("n", global_opts.keymaps.normal.delete_debug_prints, {
        callback = debugprint.deleteprints,
        desc = "Delete all debugprint statements in the current buffer",
    })

    map_key("n", global_opts.keymaps.normal.toggle_comment_debug_prints, {
        callback = debugprint.toggle_comment_debugprints,
        desc = "Comment/uncomment all debugprint statements in the current buffer",
    })

    map_key("x", global_opts.keymaps.visual.variable_below, {
        callback = function()
            feedkeys(debugprint.debugprint({ variable = true }))
        end,
        desc = "Variable debug below current line",
    })

    map_key("x", global_opts.keymaps.visual.variable_above, {
        callback = function()
            feedkeys(debugprint.debugprint({
                above = true,
                variable = true,
            }))
        end,
        desc = "Variable debug above current line",
    })

    map_key("n", global_opts.keymaps.normal.variable_above_alwaysprompt, {
        callback = function()
            return debugprint.debugprint({
                above = true,
                variable = true,
                ignore_treesitter = true,
            })
        end,
        desc = "Variable debug above current line (always prompt})",
    })

    if global_opts.commands.delete_debug_prints then
        vim.api.nvim_create_user_command(
            global_opts.commands.delete_debug_prints,
            function(cmd_opts)
                debugprint.deleteprints(cmd_opts)
            end,
            {
                range = true,
                desc = "Delete all debugprint statements in the current buffer",
            }
        )
    end

    if global_opts.commands.toggle_comment_debug_prints then
        vim.api.nvim_create_user_command(
            global_opts.commands.toggle_comment_debug_prints,
            function(cmd_opts)
                debugprint.toggle_comment_debugprints(cmd_opts)
            end,
            {
                range = true,
                desc = "Comment/uncomment all debugprint statements in the current buffer",
            }
        )
    end
end

return M
