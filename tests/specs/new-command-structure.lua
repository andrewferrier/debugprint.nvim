local debugprint = require("debugprint")
local support = require("tests.support")

describe("new command structure", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("shows error for unknown subcommand", function()
        vim.cmd("Debugprint wibble")
        assert.True(
            string.find(
                support.get_notify_message(),
                "Unknown subcommand: wibble"
            ) > 0
        )
    end)

    it("shows usage message when no subcommand provided", function()
        -- selene: allow(incorrect_standard_library_use)
        assert.error_matches(function()
            vim.cmd("Debugprint")
        end, "E471: Argument required")
    end)
end)
