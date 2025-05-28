local debugprint = require("debugprint")
local support = require("tests.support")

describe("can disable built-in keymaps/commands", function()
    after_each(support.teardown)

    it("with nil - does NOT disable", function()
        debugprint.setup({
            keymaps = { normal = { plain_below = nil } },
        })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("with false - does disable", function()
        debugprint.setup({
            keymaps = { normal = { plain_below = false } },
        })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("with empty string - does disable", function()
        debugprint.setup({
            keymaps = { normal = { plain_below = "" } },
        })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
