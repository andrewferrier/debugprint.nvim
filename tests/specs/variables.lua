local debugprint = require("debugprint")
local support = require("tests.support")

describe("can do variable debug statement insertion", function()
    before_each(function()
        debugprint.setup({
            keymaps = support.ALWAYS_PROMPT_KEYMAP,
        })
    end)

    after_each(support.teardown)

    it("can insert a var statement below using the default value", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?q<CR>")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: foo=' .. vim.inspect(foo))",
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
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a variable statement above", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?Q<BS><BS><BS>banana<CR>")

        support.check_lines({
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "foo",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("entering no name silently ends debugprint operation", function()
        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?q<BS><BS><BS><CR>")

        support.check_lines({
            "foo",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
