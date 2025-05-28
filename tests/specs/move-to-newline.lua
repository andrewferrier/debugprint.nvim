local debugprint = require("debugprint")
local support = require("tests.support")

describe("move to new line", function()
    before_each(function()
        vim.api.nvim_set_option_value("expandtab", true, {})
    end)

    after_each(support.teardown)

    it("true below", function()
        debugprint.setup({
            move_to_debugline = true,
        })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 0 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("true above", function()
        debugprint.setup({
            move_to_debugline = true,
        })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?P")

        support.check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
            "foo",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 0 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("false", function()
        debugprint.setup({
            move_to_debugline = false,
        })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 0 })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
