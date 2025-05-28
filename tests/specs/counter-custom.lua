local debugprint = require("debugprint")
local support = require("tests.support")

describe("custom counter", function()
    local count = 0

    before_each(function()
        debugprint.setup({
            display_counter = function(_)
                count = count + 2
                return "-" .. tostring(count) .. "x"
            end,
        })
    end)

    after_each(support.teardown)

    it("basic", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")
        support.feedkeys("g?p")
        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT-6x: " .. filename .. ":1 (after foo)')",
            "print('DEBUGPRINT-4x: " .. filename .. ":1 (after foo)')",
            "print('DEBUGPRINT-2x: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
