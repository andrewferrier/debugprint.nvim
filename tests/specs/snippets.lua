local debugprint = require("debugprint")
local support = require("tests.support")

describe("snippet handling", function()
    after_each(support.teardown)

    it("don't display snippet", function()
        debugprint.setup({ display_snippet = false })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can handle long lines", function()
        debugprint.setup({})

        local filename = support.init_file({
            "very_long_function_name_that_goes_on_for_quite_a_while_and_will_possibly_never_stop_but_maybe_it_will()",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "very_long_function_name_that_goes_on_for_quite_a_while_and_will_possibly_never_stop_but_maybe_it_will()",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after very_long_function_name_that_goes_on_for…)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
