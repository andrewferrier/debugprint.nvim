local debugprint = require("debugprint")
local support = require("tests.support")

describe("allow display_* to be set in filetypes", function()
    after_each(support.teardown)

    it("display_counter", function()
        debugprint.setup({ filetypes = { sh = { display_counter = false } } })

        local lua_filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. lua_filename .. ":1 (after foo)')",
            "bar",
        })

        local sh_filename = support.init_file({
            "XYZ=123",
        }, "bash", 1, 1)

        support.feedkeys("g?v")

        support.check_lines({
            "XYZ=123",
            '>&2 echo "DEBUGPRINT: $0:$LINENO: XYZ=${XYZ}"',
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("display_location", function()
        debugprint.setup({ filetypes = { lua = { display_location = false } } })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: (after foo)')",
            "bar",
        })

        local sh_filename = support.init_file({
            "XYZ=123",
        }, "bash", 1, 1)

        support.feedkeys("g?v")

        support.check_lines({
            "XYZ=123",
            '>&2 echo "DEBUGPRINT[2]: $0:$LINENO: XYZ=${XYZ}"',
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("display_snippet", function()
        debugprint.setup({ filetypes = { lua = { display_snippet = false } } })

        local lua_filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. lua_filename .. ":1')",
            "bar",
        })

        local sh_filename = support.init_file({
            "XYZ=123",
        }, "bash", 1, 1)

        support.feedkeys("g?p")

        support.check_lines({
            "XYZ=123",
            '>&2 echo "DEBUGPRINT[2]: $0:$LINENO (after XYZ=123)"',
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
