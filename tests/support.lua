local M = {}

local debugprint = require("debugprint")

local notify_message
-- FIXME: This will be needed when deprecating the old commands
-- local notify_message_warnerr

vim.notify = function(msg, _)
    -- FIXME: This will be needed when deprecating the old commands
    -- if level == vim.log.levels.ERROR or level == vim.log.levels.WARN then
    --     -- notify_message_warnerr = msg
    -- end

    notify_message = msg
end

-- This also overrides the behaviour of vim.deprecate to only show warnings once
-- within one NeoVim session
vim.notify_once = vim.notify

M.get_notify_message = function()
    return notify_message
end

M.check_lines = function(lines)
    assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end

M.feedkeys = function(keys)
    keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(keys, "mtx", false)
end

M.init_file = function(lines, extension, row, col, opts)
    opts = opts or {}

    local tempfile
    local dir

    if opts.create_in_dir then
        dir = vim.fn.tempname()
        vim.fn.mkdir(dir, "p")
        tempfile = vim.fs.joinpath(dir, "tmpfile." .. extension)
    else
        tempfile = vim.fn.tempname() .. "." .. extension
    end

    vim.cmd("split " .. tempfile)
    vim.cmd("only")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.cmd("silent w!")
    vim.api.nvim_win_set_cursor(0, { row, col })

    if opts["filetype"] ~= nil then
        vim.api.nvim_set_option_value("filetype", opts.filetype, {})
    end

    vim.api.nvim_set_option_value("shiftwidth", 4, {})

    return vim.fn.expand("%:t"), dir
end

M.teardown = function(opts)
    opts = vim.tbl_extend("keep", opts or {}, { reset_counter = true })

    -- Reset filetypes
    debugprint.setup({ filetypes = require("debugprint.filetypes") })

    notify_message = nil
    pcall(vim.keymap.del, "n", "g?p")
    pcall(vim.keymap.del, "n", "g?P")
    pcall(vim.keymap.del, { "n", "x" }, "g?v")
    pcall(vim.keymap.del, { "n", "x" }, "g?V")
    pcall(vim.keymap.del, "n", "g?o")
    pcall(vim.keymap.del, "n", "g?O")
    pcall(vim.api.nvim_del_user_command, "Debugprint")
    pcall(vim.api.nvim_del_user_command, "DeleteDebugPrints")
    vim.cmd("set modifiable")

    if opts.reset_counter then
        require("debugprint.counter").reset_debug_prints_counter()
    end

    for c in
        ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"):gmatch(".")
    do
        -- Empty register
        vim.cmd.call("setreg ('" .. c .. "', [])")
    end
end

---@param name string
M.command_exists = function(name)
    local commands = vim.api.nvim_get_commands({})
    return commands[name] ~= nil
end

M.ALWAYS_PROMPT_KEYMAP = {
    normal = {
        variable_below_alwaysprompt = "g?q",
        variable_above_alwaysprompt = "g?Q",
    },
}

local DATA_PATH = vim.fs.joinpath(vim.fn.stdpath("data"), "debugprint")
M.COUNTER_FILE = vim.fs.joinpath(DATA_PATH, "counter")

return M
