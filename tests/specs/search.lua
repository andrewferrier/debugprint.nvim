local debugprint = require("debugprint")
local support = require("tests.support")

describe("search command", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("can use Debugprint search command", function()
        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")
        vim.cmd("Debugprint search")
        -- Note: We can't easily test the actual search functionality since it depends on external plugins
        -- But we can verify the command exists and doesn't error
        assert.equals(
            "None of fzf-lua, telescope.nvim or snacks.nvim are available",
            support.get_notify_message()
        )
    end)
end)
