local debugprint = require("debugprint")
local support = require("tests.support")

describe("can do complex variable insertion with escaping", function()
    before_each(function()
        debugprint.setup({
            keymaps = support.ALWAYS_PROMPT_KEYMAP,
        })
    end)

    after_each(support.teardown)

    it("can escape variables in Python with dictionary access", function()
        local filename = support.init_file({
            "data = {'key': 'value'}",
            'result = data["key"]',
        }, "py", 2, 9)

        support.feedkeys("g?O$")

        support.check_lines({
            "data = {'key': 'value'}",
            'print(f"DEBUGPRINT[1]: '
                .. filename
                .. ':2: data[\\"key\\"]={data["key"]}")',
            'result = data["key"]',
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can escape variables in Lua with table access", function()
        local filename = support.init_file({
            "data = {key = 'value'}",
            "result = data['key']",
        }, "lua", 2, 9)

        support.feedkeys("g?O$")

        support.check_lines({
            "data = {key = 'value'}",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: data[\\'key\\']=' .. vim.inspect(data['key']))",
            "result = data['key']",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
