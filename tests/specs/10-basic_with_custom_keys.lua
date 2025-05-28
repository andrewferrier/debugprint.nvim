local debugprint = require("debugprint")
local support = require("tests.support")

describe("can do basic debug statement insertion (custom keys)", function()
    before_each(function()
        debugprint.setup({
            keymaps = {
                normal = { plain_below = "zdp" },
            },
        })
    end)

    after_each(support.teardown)

    it("can insert a basic statement below", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("zdp")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })
    end)
end)
