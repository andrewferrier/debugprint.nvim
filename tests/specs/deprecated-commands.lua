local debugprint = require("debugprint")
local support = require("tests.support")

describe("deprecated commands", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("shows deprecation warning for DeleteDebugPrints", function()
        support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        support.feedkeys("g?p")
        vim.cmd("DeleteDebugPrints")

        -- FIXME: Don't yet issue deprecation warning
        -- assert.True(
        --     string.find(
        --         support.get_notify_message()_warnerr,
        --         "Command :DeleteDebugPrints is deprecated"
        --     ) > 0
        -- )
        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    it("shows deprecation warning for ToggleCommentDebugPrints", function()
        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 1)

        support.feedkeys("g?p")
        vim.cmd("ToggleCommentDebugPrints")

        -- FIXME: Don't yet issue deprecation warning
        -- assert.True(
        --     string.find(
        --         support.get_notify_message()_warnerr,
        --         "Command :ToggleCommentDebugPrints is deprecated"
        --     ) > 0
        -- )
        support.check_lines({
            "function x()",
            "    -- print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "end",
        })
    end)

    it("shows deprecation warning for ResetDebugPrintsCounter", function()
        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        vim.cmd("ResetDebugPrintsCounter")

        -- FIXME: Don't yet issue deprecation warning
        -- assert.True(
        --     string.find(
        --         support.get_notify_message()_warnerr,
        --         "Command :ResetDebugPrintsCounter is deprecated"
        --     ) > 0
        -- )
    end)

    it("shows deprecation warning for DebugPrintQFList", function()
        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")
        vim.cmd("DebugPrintQFList")

        -- FIXME: Don't yet issue deprecation warning
        -- assert.True(
        --     string.find(
        --         support.get_notify_message()_warnerr,
        --         "Command :DebugPrintQFList is deprecated"
        --     ) > 0
        -- )
    end)
end)

describe("deprecated commands - custom", function()
    after_each(support.teardown)

    it("with custom command", function()
        assert.equals(support.get_notify_message(), nil)

        debugprint.setup({ commands = { delete_debug_prints = "FooBar" } })

        support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        support.feedkeys("g?p")
        vim.cmd("FooBar")

        -- FIXME: Don't yet issue deprecation warning
        -- assert.True(
        --     string.find(support.get_notify_message()_warnerr, "Command :FooBar is deprecated")
        --         > 0
        -- )
        assert.equals(support.get_notify_message(), "1 debug line deleted.")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    it(
        "custom command nil - does NOT disable custom DeleteDebugPrints",
        function()
            assert.equals(support.get_notify_message(), nil)

            debugprint.setup({ commands = { delete_debug_prints = nil } })
            assert.equals(support.command_exists("DeleteDebugPrints"), true)

            support.init_file({
                "function x()",
                "    local xyz = 3",
                "end",
            }, "lua", 2, 1)

            support.feedkeys("g?p")
            vim.cmd("DeleteDebugPrints")

            assert.equals(support.get_notify_message(), "1 debug line deleted.")

            support.check_lines({
                "function x()",
                "    local xyz = 3",
                "end",
            })
        end
    )

    -- These cannot be tested directly because there doesn't seem to be a way to
    -- intercept a Vim-level error
    it("custom command false - does disable", function()
        debugprint.setup({ commands = { delete_debug_prints = false } })
        assert.equals(support.command_exists("DeleteDebugPrints"), false)
    end)

    it("custom command zero-length string - does disable", function()
        debugprint.setup({ commands = { delete_debug_prints = "" } })
        assert.equals(support.command_exists("DeleteDebugPrints"), false)
    end)
end)
