local debugprint = require("debugprint")
local support = require("tests.support")

describe("quickfix list", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("can use Debugprint qflist command", function()
        local original_dir = vim.fn.getcwd()
        local filename, new_dir = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0, { create_in_dir = true })

        support.feedkeys("g?p")
        vim.cmd("write!")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        vim.cmd("cd " .. new_dir)
        vim.cmd("Debugprint qflist")
        vim.cmd("cd " .. original_dir)

        local qflist = vim.fn.getqflist()
        assert.equals(#qflist, 1)
        assert.True(string.find(qflist[1].text, "DEBUGPRINT") > 0)
    end)
end)
