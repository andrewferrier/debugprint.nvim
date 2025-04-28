local M = {}

local debugprint = require("debugprint")

---@param mode string
---@param lhs string|false
---@param opts table
---@return nil
local map_key = function(mode, lhs, opts)
    if lhs ~= nil and lhs ~= "" and lhs ~= false then
        vim.api.nvim_set_keymap(mode, lhs, "", opts)
    end
end

---@param name string|false
---@param command function
---@param opts table
---@return nil
local create_command = function(name, command, opts)
    if name ~= nil and name ~= "" and name ~= false then
        vim.api.nvim_create_user_command(name, command, opts)
    end
end

---@param global_opts debugprint.GlobalOptions
---@return nil
M.map_keys_and_commands = function(global_opts)
    map_key("n", global_opts.keymaps.normal.plain_below, {
        callback = function()
            debugprint.debugprint({})
        end,
        desc = "Plain debug below current line",
    })

    map_key("n", global_opts.keymaps.normal.plain_above, {
        callback = function()
            debugprint.debugprint({ above = true })
        end,
        desc = "Plain debug above current line",
    })

    map_key("n", global_opts.keymaps.normal.variable_below, {
        callback = function()
            debugprint.debugprint({ variable = true })
        end,
        desc = "Variable debug below current line",
    })

    map_key("n", global_opts.keymaps.normal.variable_above, {
        callback = function()
            debugprint.debugprint({
                above = true,
                variable = true,
            })
        end,
        desc = "Variable debug above current line",
    })

    map_key("n", global_opts.keymaps.normal.variable_below_alwaysprompt, {
        callback = function()
            debugprint.debugprint({
                variable = true,
                ignore_treesitter = true,
            })
        end,
        desc = "Variable debug below current line (always prompt)",
    })

    map_key("n", global_opts.keymaps.normal.variable_above_alwaysprompt, {
        callback = function()
            debugprint.debugprint({
                above = true,
                variable = true,
                ignore_treesitter = true,
            })
        end,
        desc = "Variable debug above current line (always prompt)",
    })

    map_key("n", global_opts.keymaps.normal.surround_plain, {
        callback = function()
            debugprint.debugprint({ surround = true })
        end,
        desc = "Surround plain debug",
    })

    map_key("n", global_opts.keymaps.normal.surround_variable, {
        callback = function()
            debugprint.debugprint({ surround = true, variable = true })
        end,
        desc = "Surround variable debug",
    })

    map_key("n", global_opts.keymaps.normal.surround_variable_alwaysprompt, {
        callback = function()
            debugprint.debugprint({
                surround = true,
                variable = true,
                ignore_treesitter = true,
            })
        end,
        desc = "Surround variable debug (always prompt)",
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

    map_key("n", global_opts.keymaps.normal.textobj_surround, {
        callback = function()
            return debugprint.debugprint({
                motion = true,
                surround = true,
            })
        end,
        expr = true,
        desc = "Text-obj-selected variable debug surrounded",
    })

    map_key("i", global_opts.keymaps.insert.plain, {
        callback = function()
            debugprint.debugprint({ insert = true })
        end,
        desc = "Plain debug in-place",
    })

    map_key("i", global_opts.keymaps.insert.variable, {
        callback = function()
            debugprint.debugprint({
                insert = true,
                variable = true,
                ignore_treesitter = true,
            })
        end,
        desc = "Variable debug in-place (always prompt)",
    })

    map_key("x", global_opts.keymaps.visual.variable_below, {
        callback = function()
            debugprint.debugprint({ variable = true })
        end,
        desc = "Variable debug below current line",
    })

    map_key("x", global_opts.keymaps.visual.variable_above, {
        callback = function()
            debugprint.debugprint({
                above = true,
                variable = true,
            })
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

    create_command(
        global_opts.commands.reset_debug_prints_counter,
        require("debugprint.counter").reset_debug_prints_counter,
        {
            desc = "Reset the debugprint counter to 0",
        }
    )

    create_command(
        global_opts.commands.search_debug_prints,
        require("debugprint").show_debug_prints_fzf,
        {
            desc = "Search for debug prints using fzf-lua or telescope.nvim",
        }
    )
end

return M
