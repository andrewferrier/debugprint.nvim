local debugprint = require("debugprint")
local support = require("tests.support")

describe("handle deprecated options, create_keymaps=false", function()
    before_each(function()
        debugprint.setup({ create_keymaps = false })
    end)

    after_each(support.teardown)

    it("basic", function()
        assert.True(
            support
                .get_notify_message()
                :find("^`create_keymaps` option is deprecated")
                == 1
        )

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "bar",
        })
    end)
end)

describe("handle deprecated options, create_keymaps=true", function()
    before_each(function()
        debugprint.setup({ create_keymaps = true })
    end)

    after_each(support.teardown)

    it("basic", function()
        assert.True(
            support
                .get_notify_message()
                :find("^`create_keymaps` option is deprecated")
                == 1
        )

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })
    end)
end)
