local debugprint = require("debugprint")
local support = require("tests.support")

describe("register support", function()
    before_each(function()
        support.teardown()
        debugprint.setup()
    end)

    after_each(function()
        support.teardown()
    end)

    it("can capture one plain statement", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys('"ag?p')
        assert.equals(
            support.get_notify_message(),
            "Written plain debug line to register a"
        )
        support.feedkeys("j")
        support.feedkeys('"ap')

        support.check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
        })
    end)

    it("can capture one plain statement - no notification", function()
        debugprint.setup({ notify_for_registers = false })
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys('"ag?p')
        assert.equals(support.get_notify_message(), nil)
        support.feedkeys("j")
        support.feedkeys('"ap')

        support.check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
        })
    end)

    it("can capture one plain statement above", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys('"ag?P')
        assert.equals(
            support.get_notify_message(),
            "Written plain debug line to register a"
        )
        support.feedkeys("j")
        support.feedkeys('"ap')

        support.check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
        })
    end)

    it("can capture two plain statements", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "foo",
            "    bar",
        }, "lua", 1, 0)

        support.feedkeys('"ag?p')
        assert.equals(
            support.get_notify_message(),
            "Written plain debug line to register a"
        )
        support.feedkeys("j")
        support.feedkeys('"Ag?p')
        assert.equals(
            support.get_notify_message(),
            "Appended plain debug line to register A"
        )
        support.feedkeys('"ap')

        support.check_lines({
            "foo",
            "    bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "    print('DEBUGPRINT[2]: " .. filename .. ":2 (after bar)')",
        })
    end)

    it("can reset after two statements", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys('"ag?p')
        support.feedkeys("j")
        support.feedkeys('"Ag?p')
        support.feedkeys("k")
        support.feedkeys('"ag?p')
        support.feedkeys("j")
        support.feedkeys('"ap')

        support.check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[3]: " .. filename .. ":1 (after foo)')",
        })
    end)

    it("can capture variable statement", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "foo = 123",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys('"ag?v')
        assert.equals(
            support.get_notify_message(),
            "Written variable debug line (foo) to register a"
        )
        support.feedkeys("j")
        support.feedkeys('"ap')

        support.check_lines({
            "foo = 123",
            "bar",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: foo=' .. vim.inspect(foo))",
        })
    end)

    it("can capture prompt", function()
        debugprint.setup({
            keymaps = {
                normal = { variable_below_alwaysprompt = "zxa" },
            },
        })

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys('"azxa<BS><BS><BS>apple<CR>')
        assert.equals(
            support.get_notify_message(),
            "Written variable debug line (apple) to register a"
        )
        support.feedkeys("j")
        support.feedkeys('"ap')

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
        })
    end)

    it("motion", function()
        debugprint.setup({})

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys('"ag?o2l')
        assert.equals(
            support.get_notify_message(),
            "Written variable debug line (xy) to register a"
        )
        support.feedkeys("j")
        support.feedkeys('"ap')

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xy=' .. vim.inspect(xy))",
        })
    end)

    it("visual", function()
        debugprint.setup({})

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys("vll")
        support.feedkeys('"ag?v')
        assert.equals(
            support.get_notify_message(),
            "Written variable debug line (xyz) to register a"
        )
        support.feedkeys("j")
        support.feedkeys('"ap')

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
        })
    end)
end)
