local debugprint = require("debugprint")
local support = require("tests.support")

describe("can repeat", function()
    before_each(function()
        debugprint.setup({
            keymaps = support.ALWAYS_PROMPT_KEYMAP,
        })
    end)

    after_each(support.teardown)

    it("can insert a basic statement and repeat", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")
        support.feedkeys(".")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[2]: " .. filename .. ":1 (after foo)')",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a basic statement and repeat above", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?P")
        support.feedkeys(".")

        support.check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
            "print('DEBUGPRINT[2]: " .. filename .. ":2 (before foo)')",
            "foo",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it(
        "can insert a basic statement and repeat in different directions",
        function()
            local filename = support.init_file({
                "foo",
                "bar",
            }, "lua", 1, 0)

            support.feedkeys("g?P")
            support.feedkeys(".")
            support.feedkeys("jg?p")
            support.feedkeys(".")

            support.check_lines({
                "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
                "print('DEBUGPRINT[2]: " .. filename .. ":2 (before foo)')",
                "foo",
                "bar",
                "print('DEBUGPRINT[4]: " .. filename .. ":4 (after bar)')",
                "print('DEBUGPRINT[3]: " .. filename .. ":4 (after bar)')",
            })

            assert.equals(support.get_notify_message(), nil)
        end
    )

    it("can insert a variable statement and repeat", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?q<BS><BS><BS>banana<CR>")
        support.feedkeys(".")
        support.feedkeys("g?Q<BS><BS><BS>apple<CR>")
        support.feedkeys(".")

        support.check_lines({
            "print('DEBUGPRINT[3]: "
                .. filename
                .. ":1: apple=' .. vim.inspect(apple))",
            "print('DEBUGPRINT[4]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "foo",
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
