local M = {}

local utils_buffer = require("debugprint.utils.buffer")

---@type string
local print_tag
---@type string
local picker

---@param tag string
---@return nil
M.set_print_tag = function(tag)
    print_tag = tag
end

---@param pick string
---@return nil
M.set_picker = function(pick)
    picker = pick
end

---@param opts vim.api.keyset.create_user_command.command_args
---@param action function(integer, integer)
---@param action_present string
---@param action_past string
local buffer_action = function(opts, action, action_present, action_past)
    if print_tag == "" then
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
        if string.find(line, print_tag, 1, true) ~= nil then
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

---@return nil
local picker_handlers = {
    ["fzf-lua"] = {
        call = function()
            local ok_fzf, fzf = pcall(require, "fzf-lua")
            if ok_fzf then
                fzf.grep({
                    prompt = "Debug Prints> ",
                    search = print_tag,
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
                    prompt_title = "Debug Prints> ",
                    default_text = print_tag,
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
                snacks.picker.grep({
                    title = "Debug Prints> ",
                    search = print_tag,
                })
                return true
            end
            return false
        end,
    },
}

M.show_debug_prints_fuzzy_finder = function()
    if picker then
        if picker_handlers[picker] then
            if not picker_handlers[picker].call() then
                vim.notify(
                    "Explicit picker "
                        .. picker
                        .. " was requested but is not available",
                    vim.log.levels.ERROR
                )
            end
        else
            vim.notify(
                "Picker " .. picker .. " is not a valid picker",
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
    local search_args = '"' .. print_tag .. '" ' .. vim.fn.getcwd()

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
