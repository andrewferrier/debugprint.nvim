local debugprint = require("debugprint")
local support = require("tests.support")

describe("check for variations of printtag/display_counter", function()
    after_each(support.teardown)

    it("regular printtag", function()
        debugprint.setup({ display_counter = false })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("empty printtag with display_counter=false", function()
        debugprint.setup({ print_tag = "", display_counter = false })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('" .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("empty printtag with display_counter=true", function()
        debugprint.setup({ print_tag = "" })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("basic Debugprint delete", function()
        assert.equals(support.get_notify_message(), nil)

        debugprint.setup({ print_tag = "" })

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        support.feedkeys("g?p")
        vim.cmd("Debugprint delete")

        assert.equals(
            support.get_notify_message(),
            "No print_tag set, cannot delete lines."
        )

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('[1]: " .. filename .. ":2 (after local xyz = 3)')",
            "end",
        })
    end)

    it("basic commenttoggle", function()
        assert.equals(support.get_notify_message(), nil)

        debugprint.setup({ print_tag = "" })

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 1)

        support.feedkeys("g?p")
        vim.cmd("Debugprint commenttoggle")

        assert.equals(
            support.get_notify_message(),
            "No print_tag set, cannot comment-toggle lines."
        )

        support.check_lines({
            "function x()",
            "    print('[1]: " .. filename .. ":1 (after function x())')",
            "    local xyz = 3",
            "end",
        })
    end)
end)
