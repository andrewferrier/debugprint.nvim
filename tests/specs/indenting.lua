local debugprint = require("debugprint")
local support = require("tests.support")

describe("can do indenting correctly", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("lua - inside function", function()
        local filename = support.init_file({
            "function()",
            "end",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "function()",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function())')",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("lua - inside function from below", function()
        local filename = support.init_file({
            "function()",
            "end",
        }, "lua", 2, 0)

        support.feedkeys("g?P")

        support.check_lines({
            "function()",
            "    print('DEBUGPRINT[1]: " .. filename .. ":2 (before end)')",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("lua - above function", function()
        local filename = support.init_file({
            "function()",
            "end",
        }, "lua", 1, 0)

        support.feedkeys("g?P")

        support.check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before function())')",
            "function()",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("lua - inside function using tabs", function()
        local filename = support.init_file({
            "function()",
            "end",
        }, "lua", 1, 0)

        vim.api.nvim_set_option_value("expandtab", false, {})
        vim.api.nvim_set_option_value("shiftwidth", 8, {})
        support.feedkeys("g?p")

        support.check_lines({
            "function()",
            "\tprint('DEBUGPRINT[1]: " .. filename .. ":1 (after function())')",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
