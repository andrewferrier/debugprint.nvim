local debugprint = require("debugprint")

local check_lines = function(lines)
    assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end

local feedkeys = function(keys)
    keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(keys, "mtx", false)
end

local write_file = function(filetype)
    vim.api.nvim_set_option_value("filetype", filetype, {})

    local tempfile = vim.fn.tempname() .. "." .. filetype
    vim.cmd("silent w! " .. tempfile)
    return vim.fn.expand("%:t")
end

local init_file = function(lines, filetype, row, col)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    local filename = write_file(filetype)
    vim.api.nvim_win_set_cursor(0, { row, col })
    return filename
end

local notify_message

vim.notify = function(msg, _)
    notify_message = msg
end

describe("can do setup()", function()
    it("can do basic setup", function()
        debugprint.setup()
    end)
end)

describe("can do basic debug statement insertion", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = true })
    end)

    it("can insert a basic statement below", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "bar",
        })
    end)

    it("can insert a basic statement above first line", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?P")

        check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "foo",
            "bar",
        })
    end)

    it("can insert a basic statement above first line twice", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?P")
        feedkeys("g?P")

        check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "print('DEBUGPRINT[2]: " .. filename .. ":2')",
            "foo",
            "bar",
        })
    end)

    it("can insert a basic statement below last line", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 2, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":2')",
        })
    end)
end)

describe("can do variable debug statement insertion", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = true })
    end)

    it("can insert a variable statement below", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?vbanana<CR>")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "bar",
        })
    end)

    it("can insert a variable statement above", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?Vbanana<CR>")

        check_lines({
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "foo",
            "bar",
        })
    end)
end)

describe("can do various file types", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = true })
    end)

    it("can handle a .vim file", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "vim", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            'echo "DEBUGPRINT[1]: ' .. filename .. ':1"',
            "bar",
        })
    end)

    it("can handle a .vim file variable", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "vim", 1, 0)

        feedkeys("g?vbanana<CR>")

        check_lines({
            "foo",
            'echo "DEBUGPRINT[1]: ' .. filename .. ':1: banana=" .. banana',
            "bar",
        })
    end)

    it("can gracefully handle unknown filetypes", function()
        init_file({
            "foo",
            "bar",
        }, "foo", 1, 0)

        feedkeys("g?p")
        assert.are.same(
            "Don't have debugprint configuration for filetype foo",
            notify_message
        )

        check_lines({
            "foo",
            "bar",
        })
    end)

    it("don't prompt for a variable name with an unknown filetype", function()
        init_file({
            "foo",
            "bar",
        }, "foo", 1, 0)

        feedkeys("g?v")
        feedkeys("<CR>")
        assert.are.same(
            "Don't have debugprint configuration for filetype foo",
            notify_message
        )

        check_lines({
            "foo",
            "bar",
        })
    end)
end)

describe("can do indenting correctly", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = true })
    end)

    it("lua - inside function", function()
        local filename = init_file({
            "function()",
            "end",
        }, "lua", 1, 0)

        vim.api.nvim_set_option_value("shiftwidth", 4, {})
        feedkeys("g?p")

        check_lines({
            "function()",
            "    print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "end",
        })
    end)

    it("lua - inside function from below", function()
        local filename = init_file({
            "function()",
            "end",
        }, "lua", 2, 0)

        vim.api.nvim_set_option_value("shiftwidth", 4, {})
        feedkeys("g?P")

        check_lines({
            "function()",
            "    print('DEBUGPRINT[1]: " .. filename .. ":2')",
            "end",
        })
    end)

    it("lua - above function", function()
        local filename = init_file({
            "function()",
            "end",
        }, "lua", 1, 0)

        vim.api.nvim_set_option_value("shiftwidth", 4, {})
        feedkeys("g?P")

        check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "function()",
            "end",
        })
    end)

    it("lua - inside function using tabs", function()
        local filename = init_file({
            "function()",
            "end",
        }, "lua", 1, 0)

        vim.api.nvim_set_option_value("expandtab", false, {})
        vim.api.nvim_set_option_value("shiftwidth", 8, {})
        feedkeys("g?p")

        check_lines({
            "function()",
            "\tprint('DEBUGPRINT[1]: " .. filename .. ":1')",
            "end",
        })
    end)
end)

describe("add custom filetype with setup()", function()
    before_each(function()
        debugprint.setup({
            ignore_treesitter = true,
            filetypes = {
                ["wibble"] = {
                    left = "foo('",
                    right = "')",
                    mid_var = "' .. ",
                    right_var = ")",
                },
            },
        })

        vim.api.nvim_set_option_value("expandtab", true, {})
        vim.api.nvim_set_option_value("shiftwidth", 4, {})
    end)

    it("can handle basic", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "wibble", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "foo('DEBUGPRINT[1]: " .. filename .. ":1')",
            "bar",
        })
    end)

    it("can handle variable", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "wibble", 1, 0)

        feedkeys("g?vapple<CR>")

        check_lines({
            "foo",
            "foo('DEBUGPRINT[1]: " .. filename .. ":1: apple=' .. apple)",
            "bar",
        })
    end)
end)

describe("add custom filetype with add_custom_filetypes()", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = true })

        vim.api.nvim_set_option_value("expandtab", true, {})
        vim.api.nvim_set_option_value("shiftwidth", 4, {})
    end)

    it("can handle", function()
        debugprint.add_custom_filetypes({
            ["foo"] = {
                left = "bar('",
                right = "')",
                mid_var = "' .. ",
                right_var = ")",
            },
        })

        local filename = init_file({
            "foo",
            "bar",
        }, "foo", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "bar('DEBUGPRINT[1]: " .. filename .. ":1')",
            "bar",
        })
    end)
end)

describe("move to new line", function()
    before_each(function()
        vim.api.nvim_set_option_value("expandtab", true, {})
        vim.api.nvim_set_option_value("shiftwidth", 4, {})
    end)

    it("true below", function()
        debugprint.setup({
            ignore_treesitter = true,
            move_to_debugline = true,
        })

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 0 })
    end)

    it("true above", function()
        debugprint.setup({
            ignore_treesitter = true,
            move_to_debugline = true,
        })

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?P")

        check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "foo",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 0 })
    end)

    it("false", function()
        debugprint.setup({
            ignore_treesitter = true,
            move_to_debugline = false,
        })

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 0 })
    end)
end)

describe("can repeat", function()
    before_each(function()
        debugprint.setup({
            ignore_treesitter = true,
        })
    end)

    it("can insert a basic statement and repeat", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")
        feedkeys(".")

        check_lines({
            "foo",
            "print('DEBUGPRINT[2]: " .. filename .. ":1')",
            "print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "bar",
        })
    end)

    it("can insert a basic statement and repeat above", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?P")
        feedkeys(".")

        check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "print('DEBUGPRINT[2]: " .. filename .. ":2')",
            "foo",
            "bar",
        })
    end)

    it(
        "can insert a basic statement and repeat in different directions",
        function()
            local filename = init_file({
                "foo",
                "bar",
            }, "lua", 1, 0)

            feedkeys("g?P")
            feedkeys(".")
            feedkeys("jg?p")
            feedkeys(".")

            check_lines({
                "print('DEBUGPRINT[1]: " .. filename .. ":1')",
                "print('DEBUGPRINT[2]: " .. filename .. ":2')",
                "foo",
                "bar",
                "print('DEBUGPRINT[4]: " .. filename .. ":4')",
                "print('DEBUGPRINT[3]: " .. filename .. ":4')",
            })
        end
    )

    it("can insert a variable statement and repeat", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?vbanana<CR>")
        feedkeys(".")
        feedkeys("g?Vapple<CR>")
        feedkeys(".")

        check_lines({
            "print('DEBUGPRINT[3]: "
                .. filename
                .. ":1: apple=' .. vim.inspect(apple))",
            "print('DEBUGPRINT[4]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "foo",
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "bar",
        })
    end)
end)

describe("can repeat with move to line", function()
    it("true below", function()
        debugprint.setup({
            ignore_treesitter = true,
            move_to_debugline = true,
        })

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")
        feedkeys(".")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "print('DEBUGPRINT[2]: " .. filename .. ":2')",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 3, 0 })
    end)
end)

describe("can handle treesitter identifiers", function()
    it("standard", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        feedkeys("g?v<CR>")

        check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[1]: " .. filename .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 3, 0 })
    end)

    it("non-identifier", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        feedkeys("g?vapple<CR>")

        check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 6 })
    end)

    it("disabled at function level", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        vim.keymap.set("n", "zxa", function()
            return require("debugprint").debugprint({
                variable = true,
                ignore_treesitter = true,
            })
        end, {
            expr = true,
        })
        feedkeys("zxaapple<CR>")

        check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 6 })
    end)
end)

describe("visual selection", function()
    it("standard", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        feedkeys("vllg?v")

        check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[1]: " .. filename .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })
    end)

    it("repeat", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        feedkeys("vllg?v.")

        check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[2]: " .. filename .. ":2: xyz=' .. vim.inspect(xyz))",
            "print('DEBUGPRINT[1]: " .. filename .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })
    end)

    it("standard line extremes", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "xyz",
            "end",
        }, "lua", 2, 0)

        feedkeys("vllg?v")

        check_lines({
            "function x()",
            "xyz",
            "print('DEBUGPRINT[1]: " .. filename .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })
    end)

    it("reverse", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 8)

        feedkeys("vhhg?v")

        check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[1]: " .. filename .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })
    end)

    it("reverse extremes", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        feedkeys("vllg?v")

        check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[1]: " .. filename .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })
    end)

    it("above", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        feedkeys("vllg?V")

        check_lines({
            "function x()",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "local xyz = 3",
            "end",
        })
    end)

    it("ignore multiline", function()
        debugprint.setup({ ignore_treesitter = true })

        init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 1, 1)

        feedkeys("vjg?v")

        assert.are.same(
            "debugprint not supported when multiple lines selected.",
            notify_message
        )
    end)
end)

describe("motion mode", function()
    it("standard", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        feedkeys("g?o2l")

        check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[1]: " .. filename .. ":2: xy=' .. vim.inspect(xy))",
            "end",
        })
    end)

    it("repeat", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        feedkeys("g?o2l.")

        check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[2]: " .. filename .. ":2: xy=' .. vim.inspect(xy))",
            "print('DEBUGPRINT[1]: " .. filename .. ":2: xy=' .. vim.inspect(xy))",
            "end",
        })
    end)

    it("above", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        feedkeys("g?Oiw")

        check_lines({
            "function x()",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "local xyz = 3",
            "end",
        })
    end)

    it("repeat", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 2, 6)

        feedkeys("g?oiw")
        feedkeys("j.")

        check_lines({
            "function x()",
            "local xyz = 3",
            "print('DEBUGPRINT[1]: " .. filename .. ":2: xyz=' .. vim.inspect(xyz))",
            "print('DEBUGPRINT[2]: " .. filename .. ":3: xyz=' .. vim.inspect(xyz))",
            "end",
        })
    end)

    it("ignore multiline", function()
        debugprint.setup({ ignore_treesitter = true })

        init_file({
            "function x()",
            "local xyz = 3",
            "end",
        }, "lua", 1, 1)

        feedkeys("g?oj")

        assert.are.same(
            "debugprint not supported when multiple lines in motion.",
            notify_message
        )
    end)
end)

describe("delete lines command", function()
    it("basic", function()
        debugprint.setup({})

        init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        feedkeys("g?p")
        vim.cmd('DeleteDebugPrints')

        check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    it("complex", function()
        debugprint.setup({})

        init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 0)

        feedkeys("g?pg?vwibble<CR>g?p")
        vim.cmd('DeleteDebugPrints')

        check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    it("range - one line", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 0)

        feedkeys("g?pg?pg?pg?p")

        vim.cmd("2 DeleteDebugPrints")

        check_lines({
            "function x()",
            "    print('DEBUGPRINT[3]: " .. filename .. ":1')",
            "    print('DEBUGPRINT[2]: " .. filename .. ":1')",
            "    print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "    local xyz = 3",
            "end",
        })
    end)

    it("range", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 0)

        feedkeys("g?pg?pg?pg?p")

        vim.cmd("2,3 DeleteDebugPrints")

        check_lines({
            "function x()",
            "    print('DEBUGPRINT[2]: " .. filename .. ":1')",
            "    print('DEBUGPRINT[1]: " .. filename .. ":1')",
            "    local xyz = 3",
            "end",
        })
    end)

    it("range at top", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
        }, "lua", 1, 0)

        feedkeys("g?pg?P")

        vim.cmd("1 DeleteDebugPrints")

        check_lines({
            "function x()",
            "    print('DEBUGPRINT[1]: " .. filename .. ":1')",
        })
    end)

    it("range at bottom", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
        }, "lua", 1, 0)

        feedkeys("g?pg?P")

        vim.cmd("$ DeleteDebugPrints")

        check_lines({
            "print('DEBUGPRINT[2]: " .. filename .. ":1')",
            "function x()",
        })
    end)
end)
