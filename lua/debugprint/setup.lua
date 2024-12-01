local M = {}

local debugprint = require("debugprint")

---@param mode string
---@param lhs string
---@param opts table
---@return nil
local map_key = function(mode, lhs, opts)
    if lhs ~= nil and lhs ~= '' then
        vim.api.nvim_set_keymap(mode, lhs, "", opts)
    end
end

---@param name string
---@param command function
---@param opts table
---@return nil
local create_command = function(name, command, opts)
    if name then
        vim.api.nvim_create_user_command(name, command, opts)
    end
end

---@param keys string?
---@param insert_mode boolean
---@return nil
local feedkeys = function(keys, insert_mode)
    if keys ~= nil and keys ~= "" then
        if insert_mode then
            vim.api.nvim_put({ keys }, "c", true, true)
        else
            vim.api.nvim_feedkeys(keys, "xt", true)
        end
    end
end

---@param global_opts DebugprintGlobalOptions
---@return nil
M.map_keys_and_commands = function(global_opts)
    map_key("n", global_opts.keymaps.normal.plain_below, {
        callback = function()
            feedkeys(debugprint.debugprint({}), false)
        end,
        desc = "Plain debug below current line",
    })

    map_key("n", global_opts.keymaps.normal.plain_above, {
        callback = function()
            feedkeys(debugprint.debugprint({ above = true }), false)
        end,
        desc = "Plain debug above current line",
    })

    map_key("n", global_opts.keymaps.normal.variable_below, {
        callback = function()
            feedkeys(debugprint.debugprint({ variable = true }), false)
        end,
        desc = "Variable debug below current line",
    })

    map_key("n", global_opts.keymaps.normal.variable_above, {
        callback = function()
            feedkeys(
                debugprint.debugprint({
                    above = true,
                    variable = true,
                }),
                false
            )
        end,
        desc = "Variable debug above current line",
    })

    map_key("n", global_opts.keymaps.normal.variable_below_alwaysprompt, {
        callback = function()
            feedkeys(
                debugprint.debugprint({
                    variable = true,
                    ignore_treesitter = true,
                }),
                false
            )
        end,
        desc = "Variable debug below current line (always prompt)",
    })

    map_key("n", global_opts.keymaps.normal.variable_above_alwaysprompt, {
        callback = function()
            feedkeys(
                debugprint.debugprint({
                    above = true,
                    variable = true,
                    ignore_treesitter = true,
                }),
                false
            )
        end,
        desc = "Variable debug above current line (always prompt)",
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

    map_key("i", global_opts.keymaps.insert.plain, {
        callback = function()
            feedkeys(debugprint.debugprint({ insert = true }), true)
        end,
        desc = "Plain debug in-place",
    })

    map_key("i", global_opts.keymaps.insert.variable, {
        callback = function()
            feedkeys(
                debugprint.debugprint({
                    insert = true,
                    variable = true,
                    ignore_treesitter = true,
                }),
                true
            )
        end,
        desc = "Variable debug in-place (always prompt)",
    })

    map_key("x", global_opts.keymaps.visual.variable_below, {
        callback = function()
            feedkeys(debugprint.debugprint({ variable = true }), false)
        end,
        desc = "Variable debug below current line",
    })

    map_key("x", global_opts.keymaps.visual.variable_above, {
        callback = function()
            feedkeys(
                debugprint.debugprint({
                    above = true,
                    variable = true,
                }),
                false
            )
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

    create_command(
        global_opts.commands.delete_debug_prints,
        debugprint.deleteprints,
        {
            range = true,
            desc = "Delete all debugprint statements in the current buffer",
        }
    )

    create_command(
        global_opts.commands.toggle_comment_debug_prints,
        debugprint.toggle_comment_debugprints,
        {
            range = true,
            desc = "Comment/uncomment all debugprint statements in the current buffer",
        }
    )
end

return M
