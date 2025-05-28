local debugprint = require("debugprint")
local support = require("tests.support")

describe("double statement insertion", function()
    after_each(support.teardown)

    it("plain", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?sp")

        support.check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
            "foo",
            "print('DEBUGPRINT[2]: " .. filename .. ":2 (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("plain - undo is atomic", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?sp")

        support.check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
            "foo",
            "print('DEBUGPRINT[2]: " .. filename .. ":2 (after foo)')",
            "bar",
        })

        support.feedkeys("u")

        support.check_lines({
            "foo",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("plain - repeat", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?sp")
        support.feedkeys("jj")
        support.feedkeys("g?sp")

        support.check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
            "foo",
            "print('DEBUGPRINT[2]: " .. filename .. ":2 (after foo)')",
            "print('DEBUGPRINT[3]: " .. filename .. ":4 (before bar)')",
            "bar",
            "print('DEBUGPRINT[4]: " .. filename .. ":5 (after bar)')",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("plain - complex indentation", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "function()",
            "    foo = 1",
            "end",
        }, "lua", 1, 0)

        support.feedkeys("g?sp")

        support.check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before function())')",
            "function()",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":2 (after function())')",
            "    foo = 1",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("variable", function()
        local filename = support.init_file({
            "local foo = 1",
            "local bar = 2",
        }, "lua", 1, 7)

        support.feedkeys("g?sv")

        support.check_lines({
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: foo=' .. vim.inspect(foo))",
            "local foo = 1",
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":2: foo=' .. vim.inspect(foo))",
            "local bar = 2",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("variable (prompt)", function()
        local filename = support.init_file({
            "-- local foo = 1",
            "local bar = 2",
        }, "lua", 1, 10)

        support.feedkeys("g?sv<CR>")

        support.check_lines({
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: foo=' .. vim.inspect(foo))",
            "-- local foo = 1",
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":2: foo=' .. vim.inspect(foo))",
            "local bar = 2",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("variable (always prompt)", function()
        debugprint.setup({
            keymaps = {
                normal = {
                    surround_variable_alwaysprompt = "g?sz",
                },
            },
        })

        local filename = support.init_file({
            "local foo = 1",
            "local bar = 2",
        }, "lua", 1, 7)

        support.feedkeys("g?sz<CR>")

        support.check_lines({
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: foo=' .. vim.inspect(foo))",
            "local foo = 1",
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":2: foo=' .. vim.inspect(foo))",
            "local bar = 2",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("variable (textobj)", function()
        local filename = support.init_file({
            "local foo = 1",
            "local bar = 2",
        }, "lua", 1, 7)

        support.feedkeys("g?soiw")

        support.check_lines({
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: foo=' .. vim.inspect(foo))",
            "local foo = 1",
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":2: foo=' .. vim.inspect(foo))",
            "local bar = 2",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
