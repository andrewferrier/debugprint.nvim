local debugprint = require("debugprint")
local support = require("tests.support")

describe("motion mode", function()
    after_each(support.teardown)

    it("standard", function()
        debugprint.setup()

        local filename = support.init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        support.feedkeys("g?o2l")

        support.check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xy=' .. vim.inspect(xy))",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("repeat", function()
        debugprint.setup()

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys("g?o2l.")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":2: xy=' .. vim.inspect(xy))",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xy=' .. vim.inspect(xy))",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("above", function()
        debugprint.setup()

        local filename = support.init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        support.feedkeys("g?Oiw")

        support.check_lines({
            "function x()",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "local xyz = 3",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("repeat below inside word", function()
        debugprint.setup()

        local filename = support.init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        support.feedkeys("g?oiw")
        support.feedkeys("j.")

        support.check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":3: xyz=' .. vim.inspect(xyz))",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("ignore multiline", function()
        debugprint.setup()

        support.init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 1, 1)

        support.feedkeys("g?oj")

        assert.are.same(
            "debugprint not supported when multiple lines in motion.",
            support.get_notify_message()
        )
    end)
end)
