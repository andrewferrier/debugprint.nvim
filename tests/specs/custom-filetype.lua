local debugprint = require("debugprint")
local support = require("tests.support")

describe("add custom filetype with setup()", function()
    before_each(function()
        debugprint.setup({
            keymaps = support.ALWAYS_PROMPT_KEYMAP,
            filetypes = {
                ["wibble"] = {
                    left = "foo('",
                    right = "')",
                    mid_var = "' .. ",
                    right_var = ")",
                },
            },
        })

        vim.api.nvim_set_option_value("expandtab", true, {})
    end)

    after_each(support.teardown)

    it("can handle basic", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "wibble", 1, 0, { filetype = "wibble" })

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "foo('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can handle variable", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "wibble", 1, 0, { filetype = "wibble" })

        support.feedkeys("g?q<BS><BS><BS>apple<CR>")

        support.check_lines({
            "foo",
            "foo('DEBUGPRINT[1]: " .. filename .. ":1: apple=' .. apple)",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
