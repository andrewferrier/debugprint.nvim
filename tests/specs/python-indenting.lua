local debugprint = require("debugprint")
local support = require("tests.support")

describe("check python indenting", function()
    before_each(function()
        debugprint.setup({ keymaps = support.ALWAYS_PROMPT_KEYMAP })
        vim.api.nvim_set_option_value("expandtab", true, {})
    end)

    after_each(support.teardown)

    it("at top level", function()
        local filename = support.init_file({
            "x = 1",
            "y = 2",
        }, "py", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "x = 1",
            'print("DEBUGPRINT[1]: ' .. filename .. ':1 (after x = 1)")',
            "y = 2",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("just below def()", function()
        local filename = support.init_file({
            "def xyz():",
            "    pass",
        }, "py", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "def xyz():",
            '    print("DEBUGPRINT[1]: '
                .. filename
                .. ':1 (after def xyz():)")',
            "    pass",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("in the middle of a statement block", function()
        local filename = support.init_file({
            "def xyz():",
            "    x = 1",
            "    y = 2",
        }, "py", 2, 5)

        support.feedkeys("g?p")

        support.check_lines({
            "def xyz():",
            "    x = 1",
            '    print("DEBUGPRINT[1]: ' .. filename .. ':2 (after x = 1)")',
            "    y = 2",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("variable", function()
        local filename = support.init_file({
            "def xyz():",
            "    x = 1",
            "    y = 2",
        }, "py", 2, 4)

        support.feedkeys("g?q<CR>")

        support.check_lines({
            "def xyz():",
            "    x = 1",
            '    print(f"DEBUGPRINT[1]: ' .. filename .. ':2: x={x}")',
            "    y = 2",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
