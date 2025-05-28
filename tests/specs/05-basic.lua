local debugprint = require("debugprint")
local support = require("tests.support")

describe("can do basic debug statement insertion", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("can insert a basic statement below", function()
        assert.equals(support.get_notify_message(), nil)

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

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a basic statement above first line", function()
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

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a basic statement above first line twice", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?P")
        support.feedkeys("g?P")

        support.check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
            "print('DEBUGPRINT[2]: " .. filename .. ":2 (before foo)')",
            "foo",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a basic statement below last line", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 2, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":2 (after bar)')",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
