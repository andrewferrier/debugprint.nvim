local debugprint = require("debugprint")
local support = require("tests.support")

describe("can do setup()", function()
    after_each(support.teardown)

    it("can do basic setup", function()
        debugprint.setup()
    end)
end)
