local debugprint = require("debugprint")
local support = require("tests.support")

-- See https://github.com/andrewferrier/debugprint.nvim/issues/172 for the history of these tests
describe("dvorak mapping handled", function()
    before_each(function()
        debugprint.setup()
        vim.cmd("noremap l n")
        vim.cmd("noremap s l")
        vim.cmd("noremap n k")
        vim.cmd("noremap t j")
        vim.cmd("noremap L N")
    end)

    after_each(function()
        vim.cmd("unmap l")
        vim.cmd("unmap s")
        vim.cmd("unmap n")
        vim.cmd("unmap t")
        vim.cmd("unmap L")
        support.teardown()
    end)

    it("can insert a basic statement below", function()
        assert.equals(support.get_notify_message(), nil)

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

        assert.equals(support.get_notify_message(), nil)
    end)

    it("standard motion", function()
        debugprint.setup()

        local filename = support.init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        support.feedkeys("g?o2<right>")

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

    it("register motion", function()
        debugprint.setup({})

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys('"ag?o2<right>')
        assert.equals(
            support.get_notify_message(),
            "Written variable debug line (xy) to register a"
        )
        support.feedkeys("j")
        support.feedkeys('"ap')

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xy=' .. vim.inspect(xy))",
        })
    end)

    it("register visual", function()
        debugprint.setup({})

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys("v<right><right>")
        support.feedkeys('"ag?v')
        assert.equals(
            support.get_notify_message(),
            "Written variable debug line (xyz) to register a"
        )
        support.feedkeys("j")
        support.feedkeys('"ap')

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
        })
    end)
end)
