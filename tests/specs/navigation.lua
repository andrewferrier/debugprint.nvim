local debugprint = require("debugprint")
local support = require("tests.support")

describe("debug print navigation keymaps", function()
    after_each(function()
        support.teardown()
    end)

    it("supports previous/next/first/last jumps", function()
        debugprint.setup()
        support.init_file({
            "local a = 1",
            "print('DEBUGPRINT: first')",
            "local b = 2",
            "print('DEBUGPRINT: second')",
            "local c = 3",
            "print('DEBUGPRINT: third')",
        }, "lua", 3, 0)

        support.feedkeys("]g")
        assert.equals(vim.api.nvim_win_get_cursor(0)[1], 4)

        support.feedkeys("[g")
        assert.equals(vim.api.nvim_win_get_cursor(0)[1], 2)

        support.feedkeys("]G")
        assert.equals(vim.api.nvim_win_get_cursor(0)[1], 6)

        support.feedkeys("[G")
        assert.equals(vim.api.nvim_win_get_cursor(0)[1], 2)
    end)

    it("jumps to first non-whitespace in matched debugprint line", function()
        debugprint.setup()
        support.init_file({
            "local x = 1",
            "    print('DEBUGPRINT: first')",
            "local y = 2",
        }, "lua", 1, 0)

        support.feedkeys("]g")
        local cursor = vim.api.nvim_win_get_cursor(0)
        assert.equals(cursor[1], 2)
        assert.equals(cursor[2], 4)
    end)

    it("notifies if there is no matching target in direction", function()
        debugprint.setup()
        support.init_file({
            "foo",
            "print('DEBUGPRINT: first')",
            "bar",
        }, "lua", 2, 0)

        support.feedkeys("[g")
        assert.equals(vim.api.nvim_win_get_cursor(0)[1], 2)
        assert.equals(
            support.get_notify_message(),
            "No matching debug print found in this direction"
        )
    end)
    it("finds a print tag at the start of the first line", function()
        debugprint.setup()
        support.init_file({
            "DEBUGPRINT first",
            "other",
            "DEBUGPRINT last",
        }, "lua", 2, 0)

        support.feedkeys("[G")
        assert.equals(vim.api.nvim_win_get_cursor(0)[1], 1)
        assert.equals(vim.api.nvim_win_get_cursor(0)[2], 0)
    end)
end)
