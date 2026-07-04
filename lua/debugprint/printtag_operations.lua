local M = {}

local utils_buffer = require("debugprint.utils.buffer")

---@type debugprint.GlobalOptions
local global_opts

---@param opts debugprint.GlobalOptions
---@return nil
M.set_global_opts = function(opts)
    global_opts = opts
end

---@param opts vim.api.keyset.create_user_command.command_args
---@param action function(integer, integer)
---@param action_present string
---@param action_past string
local buffer_action = function(opts, action, action_present, action_past)
    if global_opts.print_tag == "" then
        vim.notify(
            "No print_tag set, cannot " .. action_present .. " lines.",
            vim.log.levels.WARN
        )

        return
    end

    local lines_to_consider, initial_line =
        utils_buffer.get_command_lines_to_handle(opts)
    local actioned_count = 0

    if not utils_buffer.is_modifiable() then
        return
    end

    for count, line in ipairs(lines_to_consider) do
        if string.find(line, global_opts.print_tag, 1, true) ~= nil then
            action(count, initial_line)
            actioned_count = actioned_count + 1
        end
    end

    ---@type string
    local linestring
    if actioned_count == 1 then
        linestring = "line"
    else
        linestring = "lines"
    end

    vim.notify(
        actioned_count .. " debug " .. linestring .. " " .. action_past .. ".",
        vim.log.levels.INFO
    )
end

---@param opts vim.api.keyset.create_user_command.command_args
---@return nil
M.deleteprints = function(opts)
    local delete_adjust = 0

    buffer_action(opts, function(count, initial_line)
        local line_to_delete = count - 1 - delete_adjust + (initial_line - 1)
        vim.api.nvim_buf_set_lines(
            0,
            line_to_delete,
            line_to_delete + 1,
            false,
            {}
        )
        delete_adjust = delete_adjust + 1
    end, "delete", "deleted")
end

---@param opts vim.api.keyset.create_user_command.command_args
---@return nil
M.toggle_comment_debugprints = function(opts)
    buffer_action(opts, function(count, initial_line)
        local line_to_toggle = count + initial_line - 1
        utils_buffer.toggle_comment_line(line_to_toggle)
    end, "comment-toggle", "comment-toggled")
end

---@param line_nr integer?
---@return nil
local move_cursor_to_debug_print = function(line_nr)
    if line_nr == nil then
        vim.notify("No matching debug print found in this direction")
        return
    end

    local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
    local first_non_ws_col = 0

    if line ~= nil then
        local first_non_ws = string.find(line, "%S")
        if first_non_ws ~= nil then
            first_non_ws_col = first_non_ws - 1
        end
    end

    vim.api.nvim_win_set_cursor(0, { line_nr, first_non_ws_col })
end

---@param print_tag string
---@return string
local get_literal_search_pattern = function(print_tag)
    return "\\V" .. print_tag:gsub("\\", "\\\\")
end

---@param direction "next"|"prev"|"first"|"last"
---@return integer?
local find_debug_print_line = function(direction)
    local pattern = get_literal_search_pattern(global_opts.print_tag)
    local current_view = vim.fn.winsaveview()
    local target_line = nil

    if direction == "next" or direction == "prev" then
        local line_nr = vim.api.nvim_win_get_cursor(0)[1]

        if direction == "next" then
            local current_line = vim.api.nvim_get_current_line()
            vim.api.nvim_win_set_cursor(0, { line_nr, #current_line })
        else
            vim.api.nvim_win_set_cursor(0, { line_nr, 0 })
        end

        local flags = direction == "next" and "Wn" or "bWn"
        local match = vim.fn.searchpos(pattern, flags)
        if match[1] > 0 then
            target_line = match[1]
        end
    elseif direction == "first" then
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        local match = vim.fn.searchpos(pattern, "Wn")
        if match[1] > 0 then
            target_line = match[1]
        end
    else
        local last_line_nr = vim.api.nvim_buf_line_count(0)
        local last_line = vim.api.nvim_buf_get_lines(
            0,
            last_line_nr - 1,
            last_line_nr,
            false
        )[1]
        local last_col = last_line and #last_line or 0
        vim.api.nvim_win_set_cursor(0, { last_line_nr, last_col })
        local match = vim.fn.searchpos(pattern, "bWn")
        if match[1] > 0 then
            target_line = match[1]
        end
    end

    vim.fn.winrestview(current_view)
    return target_line
end

---@param direction "next"|"prev"|"first"|"last"
---@return nil
local jump_debug_print = function(direction)
    if global_opts.print_tag == "" then
        vim.notify("No print_tag set, cannot jump through debug lines.")
        return
    end

    move_cursor_to_debug_print(find_debug_print_line(direction))
end

---@return nil
M.jump_prev_debug_print = function()
    jump_debug_print("prev")
end

---@return nil
M.jump_next_debug_print = function()
    jump_debug_print("next")
end

---@return nil
M.jump_first_debug_print = function()
    jump_debug_print("first")
end

---@return nil
M.jump_last_debug_print = function()
    jump_debug_print("last")
end

---@return nil
local picker_handlers = {
    ["fzf-lua"] = {
        call = function()
            local ok_fzf, fzf = pcall(require, "fzf-lua")
            if ok_fzf then
                fzf.grep({
                    prompt = "Debug Prints> ",
                    search = global_opts.print_tag,
                })
                return true
            end
            return false
        end,
    },
    ["telescope"] = {
        call = function()
            local ok_telescope, telescope = pcall(require, "telescope.builtin")
            if ok_telescope then
                telescope.live_grep({
                    prompt_title = "Debug Prints",
                    default_text = global_opts.print_tag,
                })
                return true
            end
            return false
        end,
    },
    ["snacks.picker"] = {
        call = function()
            local ok_snacks, snacks = pcall(require, "snacks")
            if ok_snacks then
                snacks.picker.grep_word({
                    title = "Debug Prints",
                    search = global_opts.print_tag,
                    regex = true,
                })
                return true
            end
            return false
        end,
    },
}

M.show_debug_prints_fuzzy_finder = function()
    if global_opts.picker then
        if picker_handlers[global_opts.picker] then
            if not picker_handlers[global_opts.picker].call() then
                vim.notify(
                    "Explicit picker "
                        .. global_opts.picker
                        .. " was requested but is not available",
                    vim.log.levels.ERROR
                )
            end
        else
            vim.notify(
                "Picker " .. global_opts.picker .. " is not a valid picker",
                vim.log.levels.ERROR
            )
        end
    else
        for _, handler in pairs(picker_handlers) do
            if handler.call() then
                return
            end
        end

        vim.notify(
            "None of fzf-lua, telescope.nvim or snacks.nvim are available",
            vim.log.levels.ERROR
        )
    end
end

---@return nil
M.debug_print_qf_list = function()
    local grep_cmd = vim.o.grepprg
    local search_args = '"' .. global_opts.print_tag .. '" ' .. vim.fn.getcwd()

    local cannot_run = function()
        vim.notify(
            "Warning: grepprg does not contain $* placeholder, cannot run command",
            vim.log.levels.WARN
        )
    end

    -- The standard setups for 'rg' and 'grep' for grepprg seem to be
    -- incompatible for recursive searches, which is very annoying - FIXME:
    -- raise a NeoVim bug on this.
    if grep_cmd:find("^rg") then
        grep_cmd = grep_cmd .. " " .. search_args
    else
        if not grep_cmd:find("%$%*") then
            cannot_run()
            return
        end

        if grep_cmd:find("^grep") then
            grep_cmd = grep_cmd:gsub("%$%*", "-r " .. search_args)
        else
            grep_cmd = grep_cmd:gsub("%$%*", search_args)
        end
    end

    vim.fn.setqflist({}, " ", {
        title = "Debug Prints",
        lines = vim.fn.systemlist(grep_cmd),
        efm = "%f:%l:%m",
    })
    vim.cmd("copen")
end

return M
