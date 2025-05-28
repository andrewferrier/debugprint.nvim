local debugprint = require("debugprint")
local support = require("tests.support")

describe("can repeat with move to line", function()
    after_each(support.teardown)

    it("true below", function()
        debugprint.setup({
            move_to_debugline = true,
        })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")
        support.feedkeys(".")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":2 (after print(DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after foo…)')",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 3, 0 })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
