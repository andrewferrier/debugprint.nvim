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

local write_file = function(filetype)
    vim.api.nvim_set_option_value("filetype", filetype, {})

    local tempfile = vim.fn.tempname() .. "." .. filetype
    vim.cmd("silent w! " .. tempfile)
    return vim.fn.expand("%:t")
end

vim.notify = function()
    -- Remove these just to keep output quiet
end

describe("can do setup()", function()
    it("can do basic setup", function()
        debugprint.setup()
    end)
end)

describe("can do basic debug statement insertion", function()
    before_each(function()
        debugprint.setup()
    end)

    it("can insert a basic statement below", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            "print('DEBUG: " .. filename .. ":1 [1]')",
            "bar",
        })
    end)

    it("can insert a basic statement above first line", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqP")

        check_lines({
            "print('DEBUG: " .. filename .. ":1 [1]')",
            "foo",
            "bar",
        })
    end)

    it("can insert a basic statement above first line twice", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqP")
        feedkeys("dqP")

        check_lines({
            "print('DEBUG: " .. filename .. ":1 [1]')",
            "print('DEBUG: " .. filename .. ":2 [2]')",
            "foo",
            "bar",
        })
    end)

    it("can insert a basic statement below last line", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            "bar",
            "print('DEBUG: " .. filename .. ":2 [1]')",
        })
    end)
end)

describe("can do various file types", function()
    before_each(function()
        debugprint.setup()
    end)

    it("can handle a .vim file", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("vim")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            'echo "DEBUG: ' .. filename .. ':1 [1]"',
            "bar",
        })
    end)

    it("can gracefully handle unknown filetypes", function()
        set_lines({
            "foo",
            "bar",
        })

        write_file("foo")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            "bar",
        })
    end)
end)
