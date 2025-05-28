local debugprint = require("debugprint")
local support = require("tests.support")

describe("comment toggle", function()
    after_each(support.teardown)

    it("basic", function()
        debugprint.setup({})
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 1)

        support.feedkeys("g?p")
        vim.cmd("Debugprint commenttoggle")
        support.feedkeys("jjg?p")
        assert.equals(
            support.get_notify_message(),
            "1 debug line comment-toggled."
        )

        support.check_lines({
            "function x()",
            "    -- print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":3 (after local xyz = 3)')",
            "end",
        })

        vim.cmd("Debugprint commenttoggle")
        assert.equals(
            support.get_notify_message(),
            "2 debug lines comment-toggled."
        )

        support.check_lines({
            "function x()",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "    -- print('DEBUGPRINT[2]: "
                .. filename
                .. ":3 (after local xyz = 3)')",
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
        }, "lua", 1, 1)

        support.feedkeys("g?p")
        support.feedkeys("jj")
        support.feedkeys("g?p")
        vim.cmd("2 Debugprint commenttoggle")
        assert.equals(
            support.get_notify_message(),
            "1 debug line comment-toggled."
        )

        support.check_lines({
            "function x()",
            "    -- print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":3 (after local xyz = 3)')",
            "end",
        })
    end)

    it("basic with keymaps", function()
        debugprint.setup({
            keymaps = { normal = { toggle_comment_debug_prints = "g?x" } },
        })
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 1)

        support.feedkeys("g?p")
        support.feedkeys("g?xj")
        support.feedkeys("j")
        support.feedkeys("g?p")
        assert.equals(
            support.get_notify_message(),
            "1 debug line comment-toggled."
        )

        support.check_lines({
            "function x()",
            "    -- print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":3 (after local xyz = 3)')",
            "end",
        })
    end)
end)
