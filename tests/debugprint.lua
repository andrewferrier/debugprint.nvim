local set_lines = function(lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local check_lines = function(lines)
    assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end

local feedkeys = function(keys)
    keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(keys, "mtx", false)
end

local debugprint = require("debugprint")

describe("can do setup()", function()
    it("can do basic setup", function()
        debugprint.setup()
    end)
end)

describe("can do basic debug statement insertion", function()
    it("can insert a basic statement", function()
        set_lines({
            "foo",
            "bar",
        })

        feedkeys(":w! /tmp/filename.lua<CR>")
        vim.api.nvim_set_option_value("filetype", "lua", {})
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            "print('DEBUG: filename.lua:1 [1]')",
            "bar",
        })
    end)
end)
