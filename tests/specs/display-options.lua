local debugprint = require("debugprint")
local support = require("tests.support")

describe("variations of display_* options", function()
    after_each(support.teardown)

    it("no display_location", function()
        debugprint.setup({ display_location = false })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("no display_location, counter", function()
        debugprint.setup({
            display_location = false,
            display_counter = false,
        })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT: (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("no display_location, counter, snippet", function()
        debugprint.setup({
            display_location = false,
            display_counter = false,
            display_snippet = false,
        })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("no display_location, counter, snippet, print_tag", function()
        debugprint.setup({
            display_location = false,
            display_counter = false,
            display_snippet = false,
            print_tag = "",
        })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        -- In this case we print the snippet anyway, because otherwise this makes no sense and the plain print statement will print nothing.
        support.check_lines({
            "foo",
            "print('(after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("variable, no display_location", function()
        debugprint.setup({
            display_location = false,
        })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?v")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: foo=' .. vim.inspect(foo))",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("variable, no display_location, counter, snippet", function()
        debugprint.setup({
            display_location = false,
            display_counter = false,
            display_snippet = false,
        })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?v")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT: foo=' .. vim.inspect(foo))",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("variable, no display_location, counter, snippet, print_tag", function()
        debugprint.setup({
            display_location = false,
            display_counter = false,
            display_snippet = false,
            print_tag = "",
        })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?v")

        support.check_lines({
            "foo",
            "print('foo=' .. vim.inspect(foo))",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
