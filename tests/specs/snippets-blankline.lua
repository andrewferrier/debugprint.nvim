local debugprint = require("debugprint")
local support = require("tests.support")

describe("will ignore blank lines when calculating snippet", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("can insert a basic statement above", function()
        local filename = support.init_file({
            "foo",
            "",
            "",
            "bar",
        }, "lua", 3, 0)

        support.feedkeys("g?P")

        support.check_lines({
            "foo",
            "",
            "print('DEBUGPRINT[1]: " .. filename .. ":3 (before bar)')",
            "",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a basic statement below", function()
        local filename = support.init_file({
            "foo",
            "",
            "",
            "bar",
        }, "lua", 2, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "",
            "print('DEBUGPRINT[1]: " .. filename .. ":2 (after foo)')",
            "",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a basic statement above first line", function()
        local filename = support.init_file({
            "",
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?P")

        support.check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
            "",
            "foo",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a basic statement below last line", function()
        local filename = support.init_file({
            "foo",
            "bar",
            "",
        }, "lua", 3, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "bar",
            "",
            "print('DEBUGPRINT[1]: " .. filename .. ":3 (after bar)')",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a basic statement before first line", function()
        local filename = support.init_file({
            "",
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (start of file)')",
            "foo",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a basic statement above last line", function()
        local filename = support.init_file({
            "foo",
            "bar",
            "",
        }, "lua", 3, 0)

        support.feedkeys("g?P")

        support.check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":3 (end of file)')",
            "",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
