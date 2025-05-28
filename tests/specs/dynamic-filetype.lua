local debugprint = require("debugprint")
local support = require("tests.support")

describe("dynamic filetype configuration", function()
    before_each(function()
        support.teardown()
    end)

    after_each(function()
        support.teardown()
    end)

    it("can capture one plain statement", function()
        debugprint.setup({
            filetypes = {
                ["lua"] = function(opts)
                    assert.equals(type(opts.bufnr), "number")
                    assert.equals(type(opts.file_path), "string")
                    assert.are.same(opts.effective_filetypes, { "lua" })

                    return {
                        left = "blah('",
                        right = "')",
                    }
                end,
            },
        })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "blah('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })
    end)

    it("can capture one variable statement", function()
        debugprint.setup({
            filetypes = {
                ["lua"] = function(opts)
                    assert.equals(type(opts.bufnr), "number")
                    assert.equals(type(opts.file_path), "string")
                    assert.are.same(opts.effective_filetypes, { "lua" })

                    return {
                        left = "blah('",
                        right = "')",
                        mid_var = opts.effective_filetypes[1]
                            .. "' .. vim.inspect(",
                        right_var = "))",
                    }
                end,
            },
        })

        local filename = support.init_file({
            "foo = 123",
            "bar = 456",
        }, "lua", 1, 0)

        support.feedkeys("g?v")

        support.check_lines({
            "foo = 123",
            "blah('DEBUGPRINT[1]: "
                .. filename
                .. ":1: foo=lua' .. vim.inspect(foo))",
            "bar = 456",
        })
    end)
end)
