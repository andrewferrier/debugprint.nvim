vim.o.hidden = true
vim.o.swapfile = false

-- These must be prepended because of this:
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/3092#issue-1288690088
vim.opt.runtimepath:prepend(
    "~/.local/share/nvim/site/pack/vendor/start/nvim-treesitter"
)
vim.opt.runtimepath:prepend("../nvim-treesitter")
vim.cmd("runtime! plugin/nvim-treesitter.lua")

local install_parser_if_needed = function(filetype)
    if vim.tbl_contains(vim.tbl_keys(vim.fn.environ()), "GITHUB_WORKFLOW") then
        print("Running in GitHub; installing parser " .. filetype .. "...")
        vim.cmd("TSInstallSync! " .. filetype)
    else
        vim.cmd("new")
        vim.cmd("only")
        local ok, _ = pcall(vim.treesitter.get_parser, 0, filetype, {})
        if not ok then
            print("Cannot load parser for " .. filetype .. ", installing...")
            vim.cmd("TSInstallSync! " .. filetype)
        end
    end
end

install_parser_if_needed("bash")
install_parser_if_needed("lua")

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
    vim.cmd("new")
    vim.cmd("only")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    local filename = write_file(filetype)
    vim.api.nvim_win_set_cursor(0, { row, col })
    return filename
end

local teardown = function()
    vim.keymap.del("n", "g?p")
    vim.keymap.del("n", "g?P")
    vim.keymap.del({ "n", "x" }, "g?v")
    vim.keymap.del({ "n", "x" }, "g?V")
    vim.keymap.del("n", "g?o")
    vim.keymap.del("n", "g?O")
end

local notify_message

vim.notify = function(msg, _)
    notify_message = msg
end

describe("can do setup()", function()
    after_each(teardown)

    it("can do basic setup", function()
        debugprint.setup()
    end)
end)

describe("can do basic debug statement insertion", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = true })
    end)

    after_each(teardown)

    it("can insert a basic statement below", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
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
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
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
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
            "print('DEBUGPRINT[2]: " .. filename .. ":2 (before foo)')",
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
            "print('DEBUGPRINT[1]: " .. filename .. ":2 (after bar)')",
        })
    end)
end)

describe("snippet handling", function()
    after_each(teardown)

    it("can insert a basic statement below", function()
        debugprint.setup({ display_snippet = false })

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

    it("can handle long lines", function()
        debugprint.setup({})

        local filename = init_file({
            "very_long_function_name_that_goes_on_for_quite_a_while_and_will_possibly_never_stop_but_maybe_it_will()",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "very_long_function_name_that_goes_on_for_quite_a_while_and_will_possibly_never_stop_but_maybe_it_will()",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after very_long_function_name_that_goes_on_for…)')",
            "bar",
        })
    end)
end)

describe("will ignore blank lines when calculating snippet", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = true })
    end)

    after_each(teardown)

    it("can insert a basic statement above", function()
        local filename = init_file({
            "foo",
            "",
            "",
            "bar",
        }, "lua", 3, 0)

        feedkeys("g?P")

        check_lines({
            "foo",
            "",
            "print('DEBUGPRINT[1]: " .. filename .. ":3 (before bar)')",
            "",
            "bar",
        })
    end)

    it("can insert a basic statement below", function()
        local filename = init_file({
            "foo",
            "",
            "",
            "bar",
        }, "lua", 2, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "",
            "print('DEBUGPRINT[1]: " .. filename .. ":2 (after foo)')",
            "",
            "bar",
        })
    end)

    it("can insert a basic statement above first line", function()
        local filename = init_file({
            "",
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?P")

        check_lines({
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
            "",
            "foo",
            "bar",
        })
    end)

    it("can insert a basic statement below last line", function()
        local filename = init_file({
            "foo",
            "bar",
            "",
        }, "lua", 3, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "bar",
            "",
            "print('DEBUGPRINT[1]: " .. filename .. ":3 (after bar)')",
        })
    end)

    it("can insert a basic statement before first line", function()
        local filename = init_file({
            "",
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (start of file)')",
            "foo",
            "bar",
        })
    end)

    it("can insert a basic statement above last line", function()
        local filename = init_file({
            "foo",
            "bar",
            "",
        }, "lua", 3, 0)

        feedkeys("g?P")

        check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":3 (end of file)')",
            "",
        })
    end)
end)

describe("can do variable debug statement insertion", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = true })
    end)

    after_each(teardown)

    it("can insert a var statement below using the default value", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?v<CR>")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: foo=' .. vim.inspect(foo))",
            "bar",
        })
    end)

    it("can insert a variable statement below", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?v<BS><BS><BS>banana<CR>")

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

        feedkeys("g?V<BS><BS><BS>banana<CR>")

        check_lines({
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "foo",
            "bar",
        })
    end)

    it("entering no name gives an error", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?v<BS><BS><BS><CR>")
        assert.are.same("No variable name entered.", notify_message)

        check_lines({
            "foo",
            "bar",
        })
    end)
end)

describe("can do various file types", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = true })
    end)

    after_each(teardown)

    it("can handle a .vim file", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "vim", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            'echo "DEBUGPRINT[1]: ' .. filename .. ':1 (after foo)"',
            "bar",
        })
    end)

    it("can handle a .vim file variable", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "vim", 1, 0)

        feedkeys("g?v<BS><BS><BS>banana<CR>")

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

    after_each(teardown)

    it("lua - inside function", function()
        local filename = init_file({
            "function()",
            "end",
        }, "lua", 1, 0)

        vim.api.nvim_set_option_value("shiftwidth", 4, {})
        feedkeys("g?p")

        check_lines({
            "function()",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function())')",
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
            "    print('DEBUGPRINT[1]: " .. filename .. ":2 (before end)')",
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
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before function())')",
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
            "\tprint('DEBUGPRINT[1]: " .. filename .. ":1 (after function())')",
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

    after_each(teardown)

    it("can handle basic", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "wibble", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "foo('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })
    end)

    it("can handle variable", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "wibble", 1, 0)

        feedkeys("g?v<BS><BS><BS>apple<CR>")

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

    after_each(teardown)

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
            "bar('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })
    end)
end)

describe("move to new line", function()
    before_each(function()
        vim.api.nvim_set_option_value("expandtab", true, {})
        vim.api.nvim_set_option_value("shiftwidth", 4, {})
    end)

    after_each(teardown)

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
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
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
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
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
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
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

    after_each(teardown)

    it("can insert a basic statement and repeat", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")
        feedkeys(".")

        check_lines({
            "foo",
            "print('DEBUGPRINT[2]: " .. filename .. ":1 (after foo)')",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
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
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
            "print('DEBUGPRINT[2]: " .. filename .. ":2 (before foo)')",
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
                "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
                "print('DEBUGPRINT[2]: " .. filename .. ":2 (before foo)')",
                "foo",
                "bar",
                "print('DEBUGPRINT[4]: " .. filename .. ":4 (after bar)')",
                "print('DEBUGPRINT[3]: " .. filename .. ":4 (after bar)')",
            })
        end
    )

    it("can insert a variable statement and repeat", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?v<BS><BS><BS>banana<CR>")
        feedkeys(".")
        feedkeys("g?V<BS><BS><BS>apple<CR>")
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
    after_each(teardown)

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
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":2 (after print(DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after foo…)')",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 3, 0 })
    end)
end)

describe("can handle treesitter identifiers", function()
    after_each(teardown)

    it("standard", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        feedkeys("g?v")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 10 })
    end)

    it("standard (bash)", function()
        debugprint.setup({})

        local filename = init_file({
            "XYZ=123",
        }, "bash", 1, 1)

        feedkeys("g?v")

        check_lines({
            "XYZ=123",
            '>&2 echo "DEBUGPRINT[1]: ' .. filename .. ':1: XYZ=${XYZ}"',
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 1 })
    end)

    it("non-identifier", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 9)

        feedkeys("g?v<BS><BS><BS>apple<CR>")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 9 })
    end)

    it("disabled at function level", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        vim.keymap.set("n", "zxa", function()
            return require("debugprint").debugprint({
                variable = true,
                ignore_treesitter = true,
            })
        end, {
            expr = true,
        })
        feedkeys("zxa<BS><BS><BS>apple<CR>")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 10 })
    end)
end)

describe("visual selection", function()
    after_each(teardown)

    it("standard", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        feedkeys("vllg?v")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })
    end)

    it("repeat", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        feedkeys("vllg?v.")

        check_lines({
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
    end)

    it("standard line extremes", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "    xyz",
            "end",
        }, "lua", 2, 4)

        feedkeys("vllg?v")

        check_lines({
            "function x()",
            "    xyz",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })
    end)

    it("reverse", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 12)

        feedkeys("vhhg?v")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })
    end)

    it("reverse extremes", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        feedkeys("vllg?v")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
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
    after_each(teardown)

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
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xy=' .. vim.inspect(xy))",
            "end",
        })
    end)

    it("repeat", function()
        debugprint.setup({ ignore_treesitter = true })

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        feedkeys("g?o2l.")

        check_lines({
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

    it("repeat below inside word", function()
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
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":3: xyz=' .. vim.inspect(xyz))",
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
    after_each(teardown)

    it("basic", function()
        debugprint.setup({})

        init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        feedkeys("g?p")
        vim.cmd("DeleteDebugPrints")

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
        vim.cmd("DeleteDebugPrints")

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
            "    print('DEBUGPRINT[3]: "
                .. filename
                .. ":1 (after function x())')",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":1 (after function x())')",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
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
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":1 (after function x())')",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "end",
        })
    end)

    it("range at top", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
            "end",
        }, "lua", 1, 0)

        feedkeys("g?pg?P")

        vim.cmd("1 DeleteDebugPrints")

        check_lines({
            "function x()",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "end",
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
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":1 (before function x())')",
            "function x()",
        })
    end)

    it("with regexp print_tag", function()
        debugprint.setup({ print_tag = "\\033[33mDEBUG\\033[0m" })

        init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        feedkeys("g?p")
        vim.cmd("DeleteDebugPrints")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)
end)

describe("don't display counter", function()
    after_each(teardown)

    before_each(function()
        debugprint.setup({ ignore_treesitter = true, display_counter = false })
    end)

    it("basic statement", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT: " .. filename .. ":1 (after foo)')",
            "bar",
        })
    end)

    it("can insert a variable statement below", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?v<BS><BS><BS>banana<CR>")

        check_lines({
            "foo",
            "print('DEBUGPRINT: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "bar",
        })
    end)
end)

describe("check python indenting", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = true })
        vim.api.nvim_set_option_value("shiftwidth", 4, {})
        vim.api.nvim_set_option_value("expandtab", true, {})
    end)

    after_each(teardown)

    it("at top level", function()
        local filename = init_file({
            "x = 1",
            "y = 2",
        }, "python", 1, 0)

        feedkeys("g?p")

        check_lines({
            "x = 1",
            'print(f"DEBUGPRINT[1]: ' .. filename .. ':1 (after x = 1)")',
            "y = 2",
        })
    end)

    it("just below def()", function()
        local filename = init_file({
            "def xyz():",
            "    pass",
        }, "python", 1, 0)

        feedkeys("g?p")

        check_lines({
            "def xyz():",
            '    print(f"DEBUGPRINT[1]: '
                .. filename
                .. ':1 (after def xyz():)")',
            "    pass",
        })
    end)

    it("in the middle of a statement block", function()
        local filename = init_file({
            "def xyz():",
            "    x = 1",
            "    y = 2",
        }, "python", 2, 0)

        feedkeys("g?p")

        check_lines({
            "def xyz():",
            "    x = 1",
            '    print(f"DEBUGPRINT[1]: ' .. filename .. ':2 (after x = 1)")',
            "    y = 2",
        })
    end)
end)
