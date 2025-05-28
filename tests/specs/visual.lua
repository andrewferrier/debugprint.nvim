local debugprint = require("debugprint")
local support = require("tests.support")

describe("visual selection", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("standard", function()
        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys("vllg?v")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("repeat", function()
        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys("vll")
        support.feedkeys("g?v")
        support.feedkeys(".")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("standard line extremes", function()
        local filename = support.init_file({
            "function x()",
            "    xyz",
            "end",
        }, "lua", 2, 4)

        support.feedkeys("vllg?v")

        support.check_lines({
            "function x()",
            "    xyz",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("reverse", function()
        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 12)

        support.feedkeys("vhhg?v")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("reverse extremes", function()
        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys("vllg?v")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("above", function()
        local filename = support.init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        support.feedkeys("vllg?V")

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

    it("ignore multiline", function()
        support.init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 1, 1)

        support.feedkeys("vjg?v")

        support.check_lines({
            "function x()",
            "local xyz = 3",
            "end",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
