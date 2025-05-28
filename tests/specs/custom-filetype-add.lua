local debugprint = require("debugprint")
local support = require("tests.support")

describe("add custom filetype with add_custom_filetypes()", function()
    before_each(function()
        debugprint.setup()

        vim.api.nvim_set_option_value("expandtab", true, {})
    end)

    after_each(support.teardown)

    it("can handle", function()
        debugprint.add_custom_filetypes({
            ["foo"] = {
                left = "bar('",
                right = "')",
                mid_var = "' .. ",
                right_var = ")",
            },
        })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "foo", 1, 0, { filetype = "foo" })

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "bar('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
