local debugprint = require("debugprint")
local support = require("tests.support")

describe("embedded treesitter langs", function()
    before_each(function()
        debugprint.setup({ keymaps = support.ALWAYS_PROMPT_KEYMAP })
    end)

    after_each(support.teardown)

    it("lua in markdown", function()
        local filename = support.init_file({
            "foo",
            "```lua",
            "x = 1",
            "```",
            "bar",
        }, "markdown", 3, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "```lua",
            "x = 1",
            "print('DEBUGPRINT[1]: " .. filename .. ":3 (after x = 1)')",
            "```",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("lua in markdown above", function()
        local filename = support.init_file({
            "foo",
            "```lua",
            "x = 1",
            "```",
            "bar",
        }, "markdown", 3, 0)

        support.feedkeys("g?P")

        support.check_lines({
            "foo",
            "```lua",
            "print('DEBUGPRINT[1]: " .. filename .. ":3 (before x = 1)')",
            "x = 1",
            "```",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("javascript in html", function()
        local filename = support.init_file({
            "<html>",
            "<body>",
            "<script>",
            "    let x = 3;",
            "",
            "    console.log(x);",
            "</script>",
            "</body>",
            "</html>",
        }, "html", 6, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "<html>",
            "<body>",
            "<script>",
            "    let x = 3;",
            "",
            "    console.log(x);",
            '    console.warn("DEBUGPRINT[1]: '
                .. filename
                .. ':6 (after console.log(x);)")',
            "</script>",
            "</body>",
            "</html>",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("comment in lua", function()
        local filename = support.init_file({
            "x = 3",
            "-- abc",
            "a = 2",
        }, "lua", 2, 4)

        support.feedkeys("g?q<CR>")

        support.check_lines({
            "x = 3",
            "-- abc",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: abc=' .. vim.inspect(abc))",
            "a = 2",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
