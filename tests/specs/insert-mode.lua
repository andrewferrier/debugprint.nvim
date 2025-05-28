local debugprint = require("debugprint")
local support = require("tests.support")

describe("can support insert mode", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("can insert a basic statement below", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("o<C-G>p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":2 (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a variable statement below", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("o<C-G>vwibble<CR>")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: wibble=' .. vim.inspect(wibble))",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can insert a variable statement below - indented", function()
        assert.equals(support.get_notify_message(), nil)

        local filename = support.init_file({
            "    foo",
            "    bar",
        }, "lua", 1, 0)

        support.feedkeys("o<C-G>vwibble<CR>")

        support.check_lines({
            "    foo",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: wibble=' .. vim.inspect(wibble))",
            "    bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("don't insert when skipping variable name", function()
        assert.equals(support.get_notify_message(), nil)

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("o<C-G>v<CR>")

        support.check_lines({
            "foo",
            "",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
