local debugprint = require("debugprint")
local support = require("tests.support")

describe("check that counter persistence works", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(function()
        support.teardown({ reset_counter = false })
    end)

    it("statement 1", function()
        assert.equals(vim.fn.filereadable(support.COUNTER_FILE), 0)

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

        assert.equals(vim.fn.filereadable(support.COUNTER_FILE), 1)

        assert.equals(support.get_notify_message(), nil)
    end)

    it("statement 2", function()
        assert.equals(vim.fn.filereadable(support.COUNTER_FILE), 1)

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?P")

        support.check_lines({
            "print('DEBUGPRINT[2]: " .. filename .. ":1 (before foo)')",
            "foo",
            "bar",
        })

        assert.equals(vim.fn.filereadable(support.COUNTER_FILE), 1)

        assert.equals(support.get_notify_message(), nil)
    end)
end)
