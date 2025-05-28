local debugprint = require("debugprint")
local support = require("tests.support")

describe("unmodifiable buffer", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("basic", function()
        assert.equals(support.get_notify_message(), nil)

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        vim.cmd("set nomodifiable")

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "bar",
        })

        assert.equals(support.get_notify_message(), "Buffer is not modifiable.")
    end)
end)
