vim.o.hidden = true
vim.o.swapfile = false

-- These must be prepended because of this:
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/3092#issue-1288690088
vim.opt.runtimepath:prepend(
    vim.fn.stdpath("data") .. "/site/pack/vendor/start/nvim-treesitter"
)
vim.opt.runtimepath:prepend("../nvim-treesitter")

if vim.fn.has("nvim-0.10.0") == 0 then
    vim.opt.runtimepath:prepend(
        vim.fn.stdpath("data") .. "/site/pack/vendor/start/mini.nvim"
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

-- This also overrides the behaviour of vim.deprecate to only show warnings once
-- within one NeoVim session
vim.notify_once = vim.notify

-- FIXME: Switch to joinpath for more elegance once we stop supporting <0.10
local DATA_PATH = vim.fn.stdpath("data") .. "/debugprint"
local COUNTER_FILE = DATA_PATH .. "/counter"

local ALWAYS_PROMPT_KEYMAP = {
    normal = {
        variable_below_alwaysprompt = "g?q",
        variable_above_alwaysprompt = "g?Q",
    },
}

local teardown = function(opts)
    opts = vim.tbl_extend("keep", opts or {}, { reset_counter = true })

    notify_message = nil
    pcall(vim.keymap.del, "n", "g?p")
    pcall(vim.keymap.del, "n", "g?P")
    pcall(vim.keymap.del, { "n", "x" }, "g?v")
    pcall(vim.keymap.del, { "n", "x" }, "g?V")
    pcall(vim.keymap.del, "n", "g?o")
    pcall(vim.keymap.del, "n", "g?O")
    pcall(vim.api.nvim_del_user_command, "DeleteDebugPrints")
    pcall(vim.api.nvim_del_user_command, "ToggleCommentDebugPrints")
    vim.cmd("set modifiable")

    if opts.reset_counter then
        require("debugprint.counter").reset_debug_prints_counter()
    end

    for c in
        ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"):gmatch(".")
    do
        -- Empty register
        vim.cmd.call("setreg ('" .. c .. "', [])")
    end
end

---@param name string
local command_exists = function(name)
    local commands = vim.api.nvim_get_commands({})
    return commands[name] ~= nil
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
    end)
end)

describe("can do basic debug statement insertion (custom keys)", function()
    before_each(function()
        debugprint.setup({
            keymaps = {
                normal = { plain_below = "zdp" },
            },
        })
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

        assert.equals(notify_message, nil)
    end)
end)

describe("snippet handling", function()
    after_each(teardown)

    it("don't display snippet", function()
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
    end)
end)

describe("will ignore blank lines when calculating snippet", function()
    before_each(function()
        debugprint.setup()
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
    end)
end)

describe("can do variable debug statement insertion", function()
    before_each(function()
        debugprint.setup({
            keymaps = ALWAYS_PROMPT_KEYMAP,
        })
    end)

    after_each(teardown)

    it("can insert a var statement below using the default value", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?q<CR>")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: foo=' .. vim.inspect(foo))",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("can insert a variable statement below", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?q<BS><BS><BS>banana<CR>")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("can insert a variable statement above", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?Q<BS><BS><BS>banana<CR>")

        check_lines({
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "foo",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("entering no name silently ends debugprint operation", function()
        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?q<BS><BS><BS><CR>")

        check_lines({
            "foo",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)
end)

describe("can do various file types", function()
    before_each(function()
        debugprint.setup({
            keymaps = ALWAYS_PROMPT_KEYMAP,
        })
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

        assert.equals(notify_message, nil)
    end)

    it("can handle a .vim file variable", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "vim", 1, 0)

        feedkeys("g?q<BS><BS><BS>banana<CR>")

        check_lines({
            "foo",
            'echo "DEBUGPRINT[1]: ' .. filename .. ':1: banana=" .. banana',
            "bar",
        })

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
    end)

    it("can gracefully handle unknown filetypes", function()
        init_file({
            "foo",
            "bar",
        }, "foo", 1, 0, { filetype = "foo" })

        feedkeys("g?p")

        check_lines({
            "foo",
            "No debugprint configuration for filetype foo; see https://github.com/andrewferrier/debugprint.nvim/blob/main/SHOWCASE.md#modifying-or-adding-filetypes",
            "bar",
        })

        assert.equals(notify_message, nil)
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

            if vim.fn.has("nvim-0.11.0") == 1 then
                -- On NeoVim nightly, this inserts an extra space before the comment
                check_lines({
                    "(fn print-and-add [a b c]",
                    "  ; No debugprint configuration for filetype fennel; see https://github.com/andrewferrier/debugprint.nvim/blob/main/SHOWCASE.md#modifying-or-adding-filetypes",
                    "  (print a)",
                    "  (+ b c))",
                })
            else
                check_lines({
                    "(fn print-and-add [a b c]",
                    "  ;No debugprint configuration for filetype fennel; see https://github.com/andrewferrier/debugprint.nvim/blob/main/SHOWCASE.md#modifying-or-adding-filetypes",
                    "  (print a)",
                    "  (+ b c))",
                })
            end

            assert.equals(notify_message, nil)
        end
    )

    it("don't prompt for a variable name with an unknown filetype", function()
        init_file({
            "foo",
            "bar",
        }, "foo", 1, 0, { filetype = "foo" })

        feedkeys("g?q")
        feedkeys("<CR>")

        check_lines({
            "foo",
            "No debugprint configuration for filetype foo; see https://github.com/andrewferrier/debugprint.nvim/blob/main/SHOWCASE.md#modifying-or-adding-filetypes",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)
end)

describe("can do indenting correctly", function()
    before_each(function()
        debugprint.setup()
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
    end)
end)

describe("add custom filetype with setup()", function()
    before_each(function()
        debugprint.setup({
            keymaps = ALWAYS_PROMPT_KEYMAP,
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

        assert.equals(notify_message, nil)
    end)

    it("can handle variable", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "wibble", 1, 0, { filetype = "wibble" })

        feedkeys("g?q<BS><BS><BS>apple<CR>")

        check_lines({
            "foo",
            "foo('DEBUGPRINT[1]: " .. filename .. ":1: apple=' .. apple)",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)
end)

describe("add custom filetype with add_custom_filetypes()", function()
    before_each(function()
        debugprint.setup()

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

        assert.equals(notify_message, nil)
    end)
end)

describe("move to new line", function()
    before_each(function()
        vim.api.nvim_set_option_value("expandtab", true, {})
    end)

    after_each(teardown)

    it("true below", function()
        debugprint.setup({
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

        assert.equals(notify_message, nil)
    end)

    it("true above", function()
        debugprint.setup({
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

        assert.equals(notify_message, nil)
    end)

    it("false", function()
        debugprint.setup({
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

        assert.equals(notify_message, nil)
    end)
end)

describe("can repeat", function()
    before_each(function()
        debugprint.setup({
            keymaps = ALWAYS_PROMPT_KEYMAP,
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

            assert.equals(notify_message, nil)
        end
    )

    it("can insert a variable statement and repeat", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?q<BS><BS><BS>banana<CR>")
        feedkeys(".")
        feedkeys("g?Q<BS><BS><BS>apple<CR>")
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

        assert.equals(notify_message, nil)
    end)
end)

describe("can repeat with move to line", function()
    after_each(teardown)

    it("true below", function()
        debugprint.setup({
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
    end)

    it("always prompt below", function()
        debugprint.setup({
            keymaps = {
                normal = { variable_below_alwaysprompt = "zxa" },
            },
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

        assert.equals(notify_message, nil)
    end)

    it("always prompt above", function()
        debugprint.setup({
            keymaps = { normal = { variable_above_alwaysprompt = "zxb" } },
        })

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        feedkeys("zxb<BS><BS><BS>apple<CR>")

        check_lines({
            "function x()",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "    local xyz = 3",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 3, 10 })

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
    end)

    it("special case dot expression (c)", function()
        debugprint.setup()

        init_file({
            "int main() {",
            "person.year = 1984;",
            "}",
        }, "c", 2, 10)

        feedkeys("g?v")

        check_lines({
            "int main() {",
            "person.year = 1984;",
            'fprintf(stderr, "DEBUGPRINT[1]: 45.c:2: person.year=%d\\n", person.year);',
            "}",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 10 })

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
    end)
end)

describe("visual selection", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(teardown)

    it("standard", function()
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

        assert.equals(notify_message, nil)
    end)

    it("repeat", function()
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

        assert.equals(notify_message, nil)
    end)

    it("standard line extremes", function()
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

        assert.equals(notify_message, nil)
    end)

    it("reverse", function()
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

        assert.equals(notify_message, nil)
    end)

    it("reverse extremes", function()
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

        assert.equals(notify_message, nil)
    end)

    it("above", function()
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

        assert.equals(notify_message, nil)
    end)

    it("ignore multiline", function()
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

        assert.equals(notify_message, nil)
    end)
end)

describe("motion mode", function()
    after_each(teardown)

    it("standard", function()
        debugprint.setup()

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

        assert.equals(notify_message, nil)
    end)

    it("repeat", function()
        debugprint.setup()

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

        assert.equals(notify_message, nil)
    end)

    it("above", function()
        debugprint.setup()

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

        assert.equals(notify_message, nil)
    end)

    it("repeat below inside word", function()
        debugprint.setup()

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

        assert.equals(notify_message, nil)
    end)

    it("ignore multiline", function()
        debugprint.setup()

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
        debugprint.setup({
            keymaps = ALWAYS_PROMPT_KEYMAP,
            display_counter = false,
        })
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

        assert.equals(notify_message, nil)
    end)

    it("can insert a variable statement below", function()
        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?q<BS><BS><BS>banana<CR>")

        check_lines({
            "foo",
            "print('DEBUGPRINT: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)
end)

describe("check python indenting", function()
    before_each(function()
        debugprint.setup({ keymaps = ALWAYS_PROMPT_KEYMAP })
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
    end)

    it("variable", function()
        local filename = init_file({
            "def xyz():",
            "    x = 1",
            "    y = 2",
        }, "py", 2, 4)

        feedkeys("g?q<CR>")

        check_lines({
            "def xyz():",
            "    x = 1",
            '    print(f"DEBUGPRINT[1]: ' .. filename .. ':2: x={x}")',
            "    y = 2",
        })

        assert.equals(notify_message, nil)
    end)
end)

describe("embedded treesitter langs", function()
    before_each(function()
        debugprint.setup({ keymaps = ALWAYS_PROMPT_KEYMAP })
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
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

        assert.equals(notify_message, nil)
    end)

    it("comment in lua", function()
        local filename = init_file({
            "x = 3",
            "-- abc",
            "a = 2",
        }, "lua", 2, 4)

        feedkeys("g?q<CR>")

        check_lines({
            "x = 3",
            "-- abc",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: abc=' .. vim.inspect(abc))",
            "a = 2",
        })

        assert.equals(notify_message, nil)
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
        assert.True(
            notify_message:find("^`create_keymaps` option is deprecated") == 1
        )

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
        debugprint.setup()
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
            display_counter = function(_)
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

        assert.equals(notify_message, nil)
    end)
end)

describe("check for variations of printtag/display_counter", function()
    after_each(teardown)

    it("regular printtag", function()
        debugprint.setup({ display_counter = false })

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

        assert.equals(notify_message, nil)
    end)

    it("empty printtag with display_counter=false", function()
        debugprint.setup({ print_tag = "", display_counter = false })

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('" .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("empty printtag with display_counter=true", function()
        debugprint.setup({ print_tag = "" })

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("basic DeleteDebugPrints", function()
        assert.equals(notify_message, nil)

        debugprint.setup({ print_tag = "" })

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        feedkeys("g?p")
        vim.cmd("DeleteDebugPrints")

        assert.equals(
            notify_message,
            "WARNING: no print_tag set, cannot delete lines."
        )

        check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('[1]: " .. filename .. ":2 (after local xyz = 3)')",
            "end",
        })
    end)

    it("basic ToggleCommentDebugPrint", function()
        assert.equals(notify_message, nil)

        debugprint.setup({ print_tag = "" })

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 1, 1)

        feedkeys("g?p")
        vim.cmd("ToggleCommentDebugPrints")

        assert.equals(
            notify_message,
            "WARNING: no print_tag set, cannot comment-toggle lines."
        )

        check_lines({
            "function x()",
            "    print('[1]: " .. filename .. ":1 (after function x())')",
            "    local xyz = 3",
            "end",
        })
    end)
end)

describe("variations of display_* options", function()
    after_each(teardown)

    it("no display_location", function()
        debugprint.setup({ display_location = false })

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: (after foo)')",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("no display_location, counter", function()
        debugprint.setup({
            display_location = false,
            display_counter = false,
        })

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT: (after foo)')",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("no display_location, counter, snippet", function()
        debugprint.setup({
            display_location = false,
            display_counter = false,
            display_snippet = false,
        })

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT')",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("no display_location, counter, snippet, print_tag", function()
        debugprint.setup({
            display_location = false,
            display_counter = false,
            display_snippet = false,
            print_tag = "",
        })

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        -- In this case we print the snippet anyway, because otherwise this makes no sense and the plain print statement will print nothing.
        check_lines({
            "foo",
            "print('(after foo)')",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("variable, no display_location", function()
        debugprint.setup({
            display_location = false,
        })

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?v")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: foo=' .. vim.inspect(foo))",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("variable, no display_location, counter, snippet", function()
        debugprint.setup({
            display_location = false,
            display_counter = false,
            display_snippet = false,
        })

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?v")

        check_lines({
            "foo",
            "print('DEBUGPRINT: foo=' .. vim.inspect(foo))",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("variable, no display_location, counter, snippet, print_tag", function()
        debugprint.setup({
            display_location = false,
            display_counter = false,
            display_snippet = false,
            print_tag = "",
        })

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?v")

        check_lines({
            "foo",
            "print('foo=' .. vim.inspect(foo))",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)
end)

describe("allow display_* to be set in filetypes", function()
    after_each(teardown)

    it("display_counter", function()
        debugprint.setup({ filetypes = { bash = { display_counter = false } } })

        local lua_filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. lua_filename .. ":1 (after foo)')",
            "bar",
        })

        local sh_filename = init_file({
            "XYZ=123",
        }, "bash", 1, 1)

        feedkeys("g?v")

        check_lines({
            "XYZ=123",
            '>&2 echo "DEBUGPRINT: ' .. sh_filename .. ':1: XYZ=${XYZ}"',
        })

        assert.equals(notify_message, nil)
    end)

    it("display_location", function()
        debugprint.setup({ filetypes = { lua = { display_location = false } } })

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: (after foo)')",
            "bar",
        })

        local sh_filename = init_file({
            "XYZ=123",
        }, "bash", 1, 1)

        feedkeys("g?v")

        check_lines({
            "XYZ=123",
            '>&2 echo "DEBUGPRINT[2]: ' .. sh_filename .. ':1: XYZ=${XYZ}"',
        })

        assert.equals(notify_message, nil)
    end)

    it("display_snippet", function()
        debugprint.setup({ filetypes = { lua = { display_snippet = false } } })

        local lua_filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. lua_filename .. ":1')",
            "bar",
        })

        local sh_filename = init_file({
            "XYZ=123",
        }, "bash", 1, 1)

        feedkeys("g?p")

        check_lines({
            "XYZ=123",
            '>&2 echo "DEBUGPRINT[2]: ' .. sh_filename .. ':1 (after XYZ=123)"',
        })

        assert.equals(notify_message, nil)
    end)
end)

describe("can support insert mode", function()
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

        feedkeys("o<C-G>p")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":2 (after foo)')",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("can insert a variable statement below", function()
        assert.equals(notify_message, nil)

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("o<C-G>vwibble<CR>")

        check_lines({
            "foo",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: wibble=' .. vim.inspect(wibble))",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("can insert a variable statement below - indented", function()
        assert.equals(notify_message, nil)

        local filename = init_file({
            "    foo",
            "    bar",
        }, "lua", 1, 0)

        feedkeys("o<C-G>vwibble<CR>")

        check_lines({
            "    foo",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: wibble=' .. vim.inspect(wibble))",
            "    bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("don't insert when skipping variable name", function()
        assert.equals(notify_message, nil)

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("o<C-G>v<CR>")

        check_lines({
            "foo",
            "",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)
end)

describe("can disable built-in keymaps/commands", function()
    after_each(teardown)

    it("with nil - does NOT disable", function()
        debugprint.setup({
            keymaps = { normal = { plain_below = nil } },
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

        assert.equals(notify_message, nil)
    end)

    it("with false - does disable", function()
        debugprint.setup({
            keymaps = { normal = { plain_below = false } },
        })

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("with empty string - does disable", function()
        debugprint.setup({
            keymaps = { normal = { plain_below = "" } },
        })

        init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
            "foo",
            "bar",
        })

        assert.equals(notify_message, nil)
    end)

    it("custom command nil - does NOT disable", function()
        assert.equals(notify_message, nil)

        debugprint.setup({ commands = { delete_debug_prints = nil } })
        assert.equals(command_exists("DeleteDebugPrints"), true)

        init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 1)

        feedkeys("g?p")
        vim.cmd("DeleteDebugPrint")

        assert.equals(notify_message, "1 debug line deleted.")

        check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
        })
    end)

    -- These cannot be tested directly because there doesn't seem to be a way to
    -- intercept a Vim-level error
    it("custom command false - does disable", function()
        debugprint.setup({ commands = { delete_debug_prints = false } })
        assert.equals(command_exists("DeleteDebugPrints"), false)
    end)

    it("custom command zero-length string - does disable", function()
        debugprint.setup({ commands = { delete_debug_prints = "" } })
        assert.equals(command_exists("DeleteDebugPrints"), false)
    end)
end)

describe("check that counter persistence works", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(function()
        teardown({ reset_counter = false })
    end)

    it("statement 1", function()
        assert.equals(vim.fn.filereadable(COUNTER_FILE), 0)

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

        assert.equals(vim.fn.filereadable(COUNTER_FILE), 1)

        assert.equals(notify_message, nil)
    end)

    it("statement 2", function()
        assert.equals(vim.fn.filereadable(COUNTER_FILE), 1)

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?P")

        check_lines({
            "print('DEBUGPRINT[2]: " .. filename .. ":1 (before foo)')",
            "foo",
            "bar",
        })

        assert.equals(vim.fn.filereadable(COUNTER_FILE), 1)

        assert.equals(notify_message, nil)
    end)
end)

describe("register support", function()
    before_each(function()
        teardown()
        debugprint.setup()
    end)

    after_each(function()
        teardown()
    end)

    it("can capture one plain statement", function()
        assert.equals(notify_message, nil)

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys('"ag?p')
        assert.equals(notify_message, "Written plain debug line to register a")
        feedkeys("j")
        feedkeys('"ap')

        check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
        })
    end)

    it("can capture one plain statement - no notification", function()
        debugprint.setup({ notify_for_registers = false })
        assert.equals(notify_message, nil)

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys('"ag?p')
        assert.equals(notify_message, nil)
        feedkeys("j")
        feedkeys('"ap')

        check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
        })
    end)

    it("can capture one plain statement above", function()
        assert.equals(notify_message, nil)

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys('"ag?P')
        assert.equals(notify_message, "Written plain debug line to register a")
        feedkeys("j")
        feedkeys('"ap')

        check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (before foo)')",
        })
    end)

    it("can capture two plain statements", function()
        assert.equals(notify_message, nil)

        local filename = init_file({
            "foo",
            "    bar",
        }, "lua", 1, 0)

        feedkeys('"ag?p')
        assert.equals(notify_message, "Written plain debug line to register a")
        feedkeys("j")
        feedkeys('"Ag?p')
        assert.equals(notify_message, "Appended plain debug line to register A")
        feedkeys('"ap')

        check_lines({
            "foo",
            "    bar",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "    print('DEBUGPRINT[2]: " .. filename .. ":2 (after bar)')",
        })
    end)

    it("can reset after two statements", function()
        assert.equals(notify_message, nil)

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys('"ag?p')
        feedkeys("j")
        feedkeys('"Ag?p')
        feedkeys("k")
        feedkeys('"ag?p')
        feedkeys("j")
        feedkeys('"ap')

        check_lines({
            "foo",
            "bar",
            "print('DEBUGPRINT[3]: " .. filename .. ":1 (after foo)')",
        })
    end)

    it("can capture variable statement", function()
        assert.equals(notify_message, nil)

        local filename = init_file({
            "foo = 123",
            "bar",
        }, "lua", 1, 0)

        feedkeys('"ag?v')
        assert.equals(
            notify_message,
            "Written variable debug line (foo) to register a"
        )
        feedkeys("j")
        feedkeys('"ap')

        check_lines({
            "foo = 123",
            "bar",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: foo=' .. vim.inspect(foo))",
        })
    end)

    it("can capture prompt", function()
        debugprint.setup({
            keymaps = {
                normal = { variable_below_alwaysprompt = "zxa" },
            },
        })

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        feedkeys('"azxa<BS><BS><BS>apple<CR>')
        assert.equals(
            notify_message,
            "Written variable debug line (apple) to register a"
        )
        feedkeys("j")
        feedkeys('"ap')

        check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
        })
    end)

    it("motion", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        feedkeys('"ag?o2l')
        assert.equals(
            notify_message,
            "Written variable debug line (xy) to register a"
        )
        feedkeys("j")
        feedkeys('"ap')

        check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xy=' .. vim.inspect(xy))",
        })
    end)

    it("visual", function()
        debugprint.setup({})

        local filename = init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        feedkeys("vll")
        feedkeys('"ag?v')
        assert.equals(
            notify_message,
            "Written variable debug line (xyz) to register a"
        )
        feedkeys("j")
        feedkeys('"ap')

        check_lines({
            "function x()",
            "    local xyz = 3",
            "end",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
        })
    end)
end)

describe("dynamic filetype configuration", function()
    before_each(function()
        teardown()
    end)

    after_each(function()
        teardown()
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

        local filename = init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        feedkeys("g?p")

        check_lines({
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

        local filename = init_file({
            "foo = 123",
            "bar = 456",
        }, "lua", 1, 0)

        feedkeys("g?v")

        check_lines({
            "foo = 123",
            "blah('DEBUGPRINT[1]: "
                .. filename
                .. ":1: foo=lua' .. vim.inspect(foo))",
            "bar = 456",
        })
    end)
end)
