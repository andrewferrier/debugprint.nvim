vim.o.hidden = true
vim.o.swapfile = false

-- These must be prepended because of this:
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/3092#issue-1288690088
vim.opt.runtimepath:prepend(
    "~/.local/share/nvim/site/pack/vendor/start/nvim-treesitter"
)
vim.opt.runtimepath:prepend("../nvim-treesitter")

if vim.fn.has("nvim-0.10.0") == 0 then
    vim.opt.runtimepath:prepend(
        "~/.local/share/nvim/site/pack/vendor/start/mini.nvim"
    )
    vim.opt.runtimepath:prepend("../mini.nvim")
end

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
install_parser_if_needed("html")
install_parser_if_needed("javascript")
install_parser_if_needed("lua")
install_parser_if_needed("markdown")
install_parser_if_needed("markdown_inline")
install_parser_if_needed("php")
install_parser_if_needed("python")

local debugprint = require("debugprint")

local check_lines = function(lines)
    assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end

local feedkeys = function(keys)
    keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(keys, "mtx", false)
end

local init_file = function(lines, extension, row, col, opts)
    opts = opts or {}

    local tempfile = vim.fn.tempname() .. "." .. extension
    vim.cmd("split " .. tempfile)
    vim.cmd("only")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.cmd("silent w!")
    vim.api.nvim_win_set_cursor(0, { row, col })

    if opts["filetype"] ~= nil then
        vim.api.nvim_set_option_value("filetype", opts.filetype, {})
    end

    vim.api.nvim_set_option_value("shiftwidth", 4, {})

    return vim.fn.expand("%:t")
end

local notify_message

vim.notify = function(msg, _)
    notify_message = msg
end

local teardown = function()
    notify_message = nil
    pcall(vim.keymap.del, "n", "g?p")
    pcall(vim.keymap.del, "n", "g?P")
    pcall(vim.keymap.del, { "n", "x" }, "g?v")
    pcall(vim.keymap.del, { "n", "x" }, "g?V")
    pcall(vim.keymap.del, "n", "g?o")
    pcall(vim.keymap.del, "n", "g?O")
    vim.cmd("set modifiable")
end

describe("can do setup()", function()
    after_each(teardown)

    it("can do basic setup", function()
        debugprint.setup()
    end)
end)

describe("can do basic debug statement insertion", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(teardown)

    it("can insert a basic statement below", function()
        assert.equals(notify_message, nil)

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

describe("can do basic debug statement insertion (custom keys)", function()
    before_each(function()
        debugprint.setup({ keymaps = { normal = { plain_below = "zdp" } } })
    end)

    after_each(teardown)

    it("can insert a basic statement below", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("zdp")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
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

    it("entering no name silently ends debugprint operation", function()
        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?v<BS><BS><BS><CR>")

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

    it("can handle a file where ext != filetype", function()
        local filename = init_file({
            "const Foo: FunctionalComponent = () => {",
            "    return <div>Hello World!</div>;",
            "};",
        }, "tsx", 1, 0)

        feedkeys("g?p")

        check_lines({
            "const Foo: FunctionalComponent = () => {",
            '    console.warn("DEBUGPRINT[1]: '
                .. filename
                .. ':1 (after const Foo: FunctionalComponent = () => )")',
            "    return <div>Hello World!</div>;",
            "};",
        })
    end)

    it("can gracefully handle unknown filetypes", function()
        init_file({
            "foo",
            "bar",
        }, "foo", 1, 0, { filetype = "foo" })

        feedkeys("g?p")

        check_lines({
            "foo",
            "No debugprint configuration for filetype foo; see https://github.com/andrewferrier/debugprint.nvim?tab=readme-ov-file#add-custom-filetypes",
            "bar",
        })
    end)

    it(
        "can gracefully handle known filetypes we don't have a config for: fennel",
        function()
            init_file({
                "(fn print-and-add [a b c]",
                "  (print a)",
                "  (+ b c))",
            }, "fnl", 1, 0)

            feedkeys("g?p")

            check_lines({
                "(fn print-and-add [a b c]",
                "  ;No debugprint configuration for filetype fennel; see https://github.com/andrewferrier/debugprint.nvim?tab=readme-ov-file#add-custom-filetypes",
                "  (print a)",
                "  (+ b c))",
            })
        end
    )

    it("don't prompt for a variable name with an unknown filetype", function()
        init_file({
            "foo",
            "bar",
        }, "foo", 1, 0, { filetype = "foo" })

        feedkeys("g?v")
        feedkeys("<CR>")

        check_lines({
            "foo",
            "No debugprint configuration for filetype foo; see https://github.com/andrewferrier/debugprint.nvim?tab=readme-ov-file#add-custom-filetypes",
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
    end)

    after_each(teardown)

    it("can handle basic", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "wibble", 1, 0, { filetype = "wibble" })

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
        }, "wibble", 1, 0, { filetype = "wibble" })

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
        }, "foo", 1, 0, { filetype = "foo" })

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
        debugprint.setup({
            keymaps = { normal = { variable_below_alwaysprompt = "zxa" } },
        })

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

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

    it("special case dot expression (lua)", function()
        debugprint.setup()

        local filename = init_file({
            "function x()",
            "    local xyz = {}",
            "    xyz.abc = 123",
            "end",
        }, "lua", 3, 10)

        feedkeys("g?v")

        check_lines({
            "function x()",
            "    local xyz = {}",
            "    xyz.abc = 123",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":3: xyz.abc=' .. vim.inspect(xyz.abc))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 3, 10 })
    end)

    it("special case dot expression (javascript)", function()
        debugprint.setup()

        local filename = init_file({
            "let x = {}",
            "x.abc = 123",
        }, "javascript", 2, 4)

        feedkeys("g?v")

        check_lines({
            "let x = {}",
            "x.abc = 123",
            'console.warn("DEBUGPRINT[1]: '
                .. filename
                .. ':2: x.abc=", x.abc)',
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 4 })
    end)

    it("non-special case variable (python)", function()
        debugprint.setup()

        local filename = init_file({
            "x = 1",
        }, "py", 1, 0)

        feedkeys("g?v")

        check_lines({
            "x = 1",
            'print(f"DEBUGPRINT[1]: ' .. filename .. ':1: x={x}")',
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 0 })
    end)

    -- These two test cases based on https://github.com/andrewferrier/debugprint.nvim/issues/89
    it("non-special case variable (php cursor-on-name)", function()
        debugprint.setup()

        local filename = init_file({
            "<?php",
            "$branchCode = 'au';",
            "?>",
        }, "php", 2, 3)

        feedkeys("g?v")

        check_lines({
            "<?php",
            "$branchCode = 'au';",
            'fwrite(STDERR, "DEBUGPRINT[1]: '
                .. filename
                .. ':2: branchCode=$branchCode\\n");',
            "?>",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 3 })
    end)

    it("non-special case variable (php cursor-on-dollar)", function()
        debugprint.setup()

        local filename = init_file({
            "<?php",
            "$branchCode = 'au';",
            "?>",
        }, "php", 2, 1)

        feedkeys("g?v")

        check_lines({
            "<?php",
            "$branchCode = 'au';",
            'fwrite(STDERR, "DEBUGPRINT[1]: '
                .. filename
                .. ':2: branchCode=$branchCode\\n");',
            "?>",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 1 })
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

        feedkeys("vll")
        feedkeys("g?v")
        feedkeys(".")

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

        check_lines({
            "function x()",
            "local xyz = 3",
            "end",
        })
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
        assert.equals(notify_message, nil)

        debugprint.setup({})

        init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        feedkeys("g?p")
        vim.cmd("DeleteDebugPrints")

        assert.equals(notify_message, "1 debug line deleted.")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    it("with custom command", function()
        assert.equals(notify_message, nil)

        debugprint.setup({ commands = { delete_debug_prints = "FooBar" } })

        init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        feedkeys("g?p")
        vim.cmd("FooBar")

        assert.equals(notify_message, "1 debug line deleted.")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    it("complex", function()
        debugprint.setup({})

        assert.equals(notify_message, nil)

        init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 0)

        feedkeys("g?pg?vwibble<CR>g?p")
        vim.cmd("DeleteDebugPrints")
        assert.equals(notify_message, "3 debug lines deleted.")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    it("range - one line", function()
        debugprint.setup({})

        assert.equals(notify_message, nil)

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 0)

        feedkeys("g?pg?pg?pg?p")

        vim.cmd("2 DeleteDebugPrints")
        assert.equals(notify_message, "1 debug line deleted.")

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

        assert.equals(notify_message, nil)

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 0)

        feedkeys("g?pg?pg?pg?p")

        vim.cmd("2,3 DeleteDebugPrints")
        assert.equals(notify_message, "2 debug lines deleted.")

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

        assert.equals(notify_message, nil)

        local filename = init_file({
            "function x()",
            "end",
        }, "lua", 1, 0)

        feedkeys("g?p")
        feedkeys("g?P")

        vim.cmd("1 DeleteDebugPrints")
        assert.equals(notify_message, "1 debug line deleted.")

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

        assert.equals(notify_message, nil)

        local filename = init_file({
            "function x()",
        }, "lua", 1, 0)

        feedkeys("g?p")
        feedkeys("g?P")

        vim.cmd("$ DeleteDebugPrints")
        assert.equals(notify_message, "1 debug line deleted.")

        check_lines({
            "print('DEBUGPRINT[2]: "
                .. filename
                .. ":1 (before function x())')",
            "function x()",
        })
    end)

    it("with regexp print_tag", function()
        debugprint.setup({ print_tag = "\\033[33mDEBUG\\033[0m" })

        assert.equals(notify_message, nil)

        init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        feedkeys("g?p")
        vim.cmd("DeleteDebugPrints")
        assert.equals(notify_message, "1 debug line deleted.")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    it("basic - with key binding", function()
        debugprint.setup({
            keymaps = { normal = { delete_debug_prints = "g?x" } },
        })

        assert.equals(notify_message, nil)

        init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        feedkeys("g?p")
        feedkeys("g?x")
        assert.equals(notify_message, "1 debug line deleted.")

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
        vim.api.nvim_set_option_value("expandtab", true, {})
    end)

    after_each(teardown)

    it("at top level", function()
        local filename = init_file({
            "x = 1",
            "y = 2",
        }, "py", 1, 0)

        feedkeys("g?p")

        check_lines({
            "x = 1",
            'print("DEBUGPRINT[1]: ' .. filename .. ':1 (after x = 1)")',
            "y = 2",
        })
    end)

    it("just below def()", function()
        local filename = init_file({
            "def xyz():",
            "    pass",
        }, "py", 1, 0)

        feedkeys("g?p")

        check_lines({
            "def xyz():",
            '    print("DEBUGPRINT[1]: '
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
        }, "py", 2, 5)

        feedkeys("g?p")

        check_lines({
            "def xyz():",
            "    x = 1",
            '    print("DEBUGPRINT[1]: ' .. filename .. ':2 (after x = 1)")',
            "    y = 2",
        })
    end)

    it("variable", function()
        local filename = init_file({
            "def xyz():",
            "    x = 1",
            "    y = 2",
        }, "py", 2, 4)

        feedkeys("g?v<CR>")

        check_lines({
            "def xyz():",
            "    x = 1",
            '    print(f"DEBUGPRINT[1]: ' .. filename .. ':2: x={x}")',
            "    y = 2",
        })
    end)
end)

describe("embedded treesitter langs", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = false })
    end)

    after_each(teardown)

    it("lua in markdown", function()
        local filename = init_file({
            "foo",
            "```lua",
            "x = 1",
            "```",
            "bar",
        }, "markdown", 3, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "```lua",
            "x = 1",
            "print('DEBUGPRINT[1]: " .. filename .. ":3 (after x = 1)')",
            "```",
            "bar",
        })
    end)

    it("lua in markdown above", function()
        local filename = init_file({
            "foo",
            "```lua",
            "x = 1",
            "```",
            "bar",
        }, "markdown", 3, 0)

        feedkeys("g?P")

        check_lines({
            "foo",
            "```lua",
            "print('DEBUGPRINT[1]: " .. filename .. ":3 (before x = 1)')",
            "x = 1",
            "```",
            "bar",
        })
    end)

    it("javascript in html", function()
        local filename = init_file({
            "<html>",
            "<body>",
            "<script>",
            "    let x = 3;",
            "",
            "    console.log(x);",
            "</script>",
            "</body>",
            "</html>",
        }, "html", 6, 0)

        feedkeys("g?p")

        check_lines({
            "<html>",
            "<body>",
            "<script>",
            "    let x = 3;",
            "",
            "    console.log(x);",
            '    console.warn("DEBUGPRINT[1]: '
                .. filename
                .. ':6 (after console.log(x);)")',
            "</script>",
            "</body>",
            "</html>",
        })
    end)

    it("comment in lua", function()
        local filename = init_file({
            "x = 3",
            "-- abc",
            "a = 2",
        }, "lua", 2, 4)

        feedkeys("g?v<CR>")

        check_lines({
            "x = 3",
            "-- abc",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: abc=' .. vim.inspect(abc))",
            "a = 2",
        })
    end)
end)

describe("comment toggle", function()
    after_each(teardown)

    it("basic", function()
        debugprint.setup({})
        assert.equals(notify_message, nil)

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 1)

        feedkeys("g?p")
        vim.cmd("ToggleCommentDebugPrint")
        feedkeys("jjg?p")
        assert.equals(notify_message, "1 debug line comment-toggled.")

        check_lines({
            "function x()",
            "    -- print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":3 (after local xyz = 3)')",
            "end",
        })

        vim.cmd("ToggleCommentDebugPrint")
        assert.equals(notify_message, "2 debug lines comment-toggled.")

        check_lines({
            "function x()",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "    -- print('DEBUGPRINT[2]: "
                .. filename
                .. ":3 (after local xyz = 3)')",
            "end",
        })
    end)

    it("range", function()
        debugprint.setup({})
        assert.equals(notify_message, nil)

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 1)

        feedkeys("g?p")
        feedkeys("jj")
        feedkeys("g?p")
        vim.cmd("2 ToggleCommentDebugPrint")
        assert.equals(notify_message, "1 debug line comment-toggled.")

        check_lines({
            "function x()",
            "    -- print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":3 (after local xyz = 3)')",
            "end",
        })
    end)

    it("basic with keymaps", function()
        debugprint.setup({
            keymaps = { normal = { toggle_comment_debug_prints = "g?x" } },
        })
        assert.equals(notify_message, nil)

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 1)

        feedkeys("g?p")
        feedkeys("g?xj")
        feedkeys("j")
        feedkeys("g?p")
        assert.equals(notify_message, "1 debug line comment-toggled.")

        check_lines({
            "function x()",
            "    -- print('DEBUGPRINT[1]: "
                .. filename
                .. ":1 (after function x())')",
            "    local xyz = 3",
            "    print('DEBUGPRINT[2]: "
                .. filename
                .. ":3 (after local xyz = 3)')",
            "end",
        })
    end)
end)

describe("handle deprecated options, create_keymaps=false", function()
    before_each(function()
        debugprint.setup({ create_keymaps = false })
    end)

    after_each(teardown)

    it("basic", function()
        assert.True(
            notify_message:find("^`create_keymaps` option is deprecated") == 1
        )

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "bar",
        })
    end)
end)

describe("handle deprecated options, create_keymaps=true", function()
    before_each(function()
        debugprint.setup({ create_keymaps = true })
    end)

    after_each(teardown)

    it("basic", function()
        -- This deprecation message will not be shown again after the test above
        -- because these tests are run inside the same NeoVim instance and
        -- vim.deprecate won't show the same notification twice.
        --
        -- assert.True(
        --     notify_message:find("^`create_keymaps` option is deprecated") == 1
        -- )

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
end)

describe("unmodifiable buffer", function()
    before_each(function()
        debugprint.setup({ create_keymaps = true })
    end)

    after_each(teardown)

    it("basic", function()
        assert.equals(notify_message, nil)

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        vim.cmd("set nomodifiable")

        feedkeys("g?p")

        check_lines({
            "foo",
            "bar",
        })

        assert.equals(notify_message, "Buffer is not modifiable.")
    end)
end)

describe("custom counter", function()
    local count = 0

    before_each(function()
        debugprint.setup({
            display_counter = function(opts)
                count = count + 2
                return "-" .. tostring(count) .. "x"
            end,
        })
    end)

    after_each(teardown)

    it("basic", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")
        feedkeys("g?p")
        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT-6x: " .. filename .. ":1 (after foo)')",
            "print('DEBUGPRINT-4x: " .. filename .. ":1 (after foo)')",
            "print('DEBUGPRINT-2x: " .. filename .. ":1 (after foo)')",
            "bar",
        })
    end)
end)
