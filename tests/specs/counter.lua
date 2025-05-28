local debugprint = require("debugprint")
local support = require("tests.support")

describe("don't display counter", function()
    after_each(support.teardown)

    before_each(function()
        debugprint.setup({
            keymaps = support.ALWAYS_PROMPT_KEYMAP,
            display_counter = false,
        })
    end)

    it("basic statement", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a variable statement below", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?q<BS><BS><BS>banana<CR>")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
