local debugprint = require("debugprint")
local support = require("tests.support")

describe("delete lines command", function()
    after_each(support.teardown)

    it("basic", function()
        assert.equals(support.get_notify_message(), nil)

        debugprint.setup({})

        support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        support.feedkeys("g?p")
        vim.cmd("Debugprint delete")

        assert.equals(support.get_notify_message(), "1 debug line deleted.")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    it("complex", function()
        debugprint.setup({})

        assert.equals(support.get_notify_message(), nil)

        support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 0)

        support.feedkeys("g?pg?vwibble<CR>g?p")
        vim.cmd("Debugprint delete")
        assert.equals(support.get_notify_message(), "3 debug lines deleted.")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    it("range - one line", function()
        debugprint.setup({})

        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 0)

        support.feedkeys("g?pg?pg?pg?p")

        vim.cmd("2 Debugprint delete")
        assert.equals(support.get_notify_message(), "1 debug line deleted.")

        support.check_lines({
            "function x()",
            "    print('DEBUGPRINT[3]: "
                .. filename
                .. ":1 (after function x())')",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":1 (after function x())')",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "end",
        })
    end)

    it("range", function()
        debugprint.setup({})

        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 0)

        support.feedkeys("g?pg?pg?pg?p")

        vim.cmd("2,3 Debugprint delete")
        assert.equals(support.get_notify_message(), "2 debug lines deleted.")

        support.check_lines({
            "function x()",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":1 (after function x())')",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "end",
        })
    end)

    it("range at top", function()
        debugprint.setup({})

        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "function x()",
            "end",
        }, "lua", 1, 0)

        support.feedkeys("g?p")
        support.feedkeys("g?P")

        vim.cmd("1 Debugprint delete")
        assert.equals(support.get_notify_message(), "1 debug line deleted.")

        support.check_lines({
            "function x()",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "end",
        })
    end)

    it("range at bottom", function()
        debugprint.setup({})

        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "function x()",
        }, "lua", 1, 0)

        support.feedkeys("g?p")
        support.feedkeys("g?P")

        vim.cmd("$ Debugprint delete")
        assert.equals(support.get_notify_message(), "1 debug line deleted.")

        support.check_lines({
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":1 (before function x())')",
            "function x()",
        })
    end)

    it("with regexp print_tag", function()
        debugprint.setup({ print_tag = "\\033[33mDEBUG\\033[0m" })

        assert.equals(support.get_notify_message(), nil)

        support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        support.feedkeys("g?p")
        vim.cmd("Debugprint delete")
        assert.equals(support.get_notify_message(), "1 debug line deleted.")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    it("basic - with key binding", function()
        debugprint.setup({
            keymaps = { normal = { delete_debug_prints = "g?x" } },
        })

        assert.equals(support.get_notify_message(), nil)

        support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        support.feedkeys("g?p")
        support.feedkeys("g?x")
        assert.equals(support.get_notify_message(), "1 debug line deleted.")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)
end)
