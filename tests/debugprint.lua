local set_lines = function(lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local check_lines = function(lines)
    assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end

local feedkeys = function(keys)
    keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(keys, "mtx", false)
end

local debugprint = require("debugprint")

local write_file = function(filetype)
    vim.api.nvim_set_option_value("filetype", filetype, {})

    local tempfile = vim.fn.tempname() .. "." .. filetype
    vim.cmd("silent w! " .. tempfile)
    return vim.fn.expand("%:t")
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
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            "print('DEBUG[1]: " .. filename .. ":1')",
            "bar",
        })
    end)

    it("can insert a basic statement above first line", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqP")

        check_lines({
            "print('DEBUG[1]: " .. filename .. ":1')",
            "foo",
            "bar",
        })
    end)

    it("can insert a basic statement above first line twice", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqP")
        feedkeys("dqP")

        check_lines({
            "print('DEBUG[1]: " .. filename .. ":1')",
            "print('DEBUG[2]: " .. filename .. ":2')",
            "foo",
            "bar",
        })
    end)

    it("can insert a basic statement below last line", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            "bar",
            "print('DEBUG[1]: " .. filename .. ":2')",
        })
    end)
end)

describe("can do variable debug statement insertion", function()
    before_each(function()
        debugprint.setup({ ignore_treesitter = true })
    end)

    it("can insert a variable statement below", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dQpbanana<CR>")

        check_lines({
            "foo",
            "print('DEBUG[1]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "bar",
        })
    end)

    it("can insert a variable statement above", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dQPbanana<CR>")

        check_lines({
            "print('DEBUG[1]: "
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
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("vim")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            'echo "DEBUG[1]: ' .. filename .. ':1"',
            "bar",
        })
    end)

    it("can handle a .vim file variable", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("vim")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dQpbanana<CR>")

        check_lines({
            "foo",
            'echo "DEBUG[1]: ' .. filename .. ':1: banana=" .. banana',
            "bar",
        })
    end)

    it("can gracefully handle unknown filetypes", function()
        set_lines({
            "foo",
            "bar",
        })

        write_file("foo")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")
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
        set_lines({
            "foo",
            "bar",
        })

        write_file("foo")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dQp")
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
        set_lines({
            "function()",
            "end",
        })

        local filename = write_file("lua")
        vim.api.nvim_set_option_value("shiftwidth", 4, {})
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "function()",
            "    print('DEBUG[1]: " .. filename .. ":1')",
            "end",
        })
    end)

    it("lua - inside function from below", function()
        set_lines({
            "function()",
            "end",
        })

        local filename = write_file("lua")
        vim.api.nvim_set_option_value("shiftwidth", 4, {})
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        feedkeys("dqP")

        check_lines({
            "function()",
            "    print('DEBUG[1]: " .. filename .. ":2')",
            "end",
        })
    end)

    it("lua - above function", function()
        set_lines({
            "function()",
            "end",
        })

        local filename = write_file("lua")
        vim.api.nvim_set_option_value("shiftwidth", 4, {})
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqP")

        check_lines({
            "print('DEBUG[1]: " .. filename .. ":1')",
            "function()",
            "end",
        })
    end)

    it("lua - inside function using tabs", function()
        set_lines({
            "function()",
            "end",
        })

        local filename = write_file("lua")
        vim.api.nvim_set_option_value("expandtab", false, {})
        vim.api.nvim_set_option_value("shiftwidth", 8, {})
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "function()",
            "\tprint('DEBUG[1]: " .. filename .. ":1')",
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
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("wibble")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            "foo('DEBUG[1]: " .. filename .. ":1')",
            "bar",
        })
    end)

    it("can handle variable", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("wibble")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dQpapple<CR>")

        check_lines({
            "foo",
            "foo('DEBUG[1]: " .. filename .. ":1: apple=' .. apple)",
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

        set_lines({
            "foo",
            "bar",
        })
        local filename = write_file("foo")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            "bar('DEBUG[1]: " .. filename .. ":1')",
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

        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            "print('DEBUG[1]: " .. filename .. ":1')",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 0 })
    end)

    it("true above", function()
        debugprint.setup({
            ignore_treesitter = true,
            move_to_debugline = true,
        })

        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqP")

        check_lines({
            "print('DEBUG[1]: " .. filename .. ":1')",
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

        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")

        check_lines({
            "foo",
            "print('DEBUG[1]: " .. filename .. ":1')",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 0 })
    end)
end)

describe("can repeat", function()
    before_each(function()
        debugprint.setup({
            ignore_treesitter = true,
            ignore_treesitter = true,
        })
    end)

    it("can insert a basic statement and repeat", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")
        feedkeys(".")

        check_lines({
            "foo",
            "print('DEBUG[2]: " .. filename .. ":1')",
            "print('DEBUG[1]: " .. filename .. ":1')",
            "bar",
        })
    end)

    it("can insert a basic statement and repeat above", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqP")
        feedkeys(".")

        check_lines({
            "print('DEBUG[1]: " .. filename .. ":1')",
            "print('DEBUG[2]: " .. filename .. ":2')",
            "foo",
            "bar",
        })
    end)

    it(
        "can insert a basic statement and repeat in different directions",
        function()
            set_lines({
                "foo",
                "bar",
            })

            local filename = write_file("lua")
            vim.api.nvim_win_set_cursor(0, { 1, 0 })
            feedkeys("dqP")
            feedkeys(".")
            feedkeys("jdqp")
            feedkeys(".")

            check_lines({
                "print('DEBUG[1]: " .. filename .. ":1')",
                "print('DEBUG[2]: " .. filename .. ":2')",
                "foo",
                "bar",
                "print('DEBUG[4]: " .. filename .. ":4')",
                "print('DEBUG[3]: " .. filename .. ":4')",
            })
        end
    )

    it("can insert a variable statement and repeat", function()
        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dQpbanana<CR>")
        feedkeys(".")
        feedkeys("dQPapple<CR>")
        feedkeys(".")

        check_lines({
            "print('DEBUG[3]: "
                .. filename
                .. ":1: apple=' .. vim.inspect(apple))",
            "print('DEBUG[4]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "foo",
            "print('DEBUG[2]: "
                .. filename
                .. ":1: banana=' .. vim.inspect(banana))",
            "print('DEBUG[1]: "
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

        set_lines({
            "foo",
            "bar",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("dqp")
        feedkeys(".")

        check_lines({
            "foo",
            "print('DEBUG[1]: " .. filename .. ":1')",
            "print('DEBUG[2]: " .. filename .. ":2')",
            "bar",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 3, 0 })
    end)
end)

describe("can handle treesitter identifiers", function()
    it("standard", function()
        debugprint.setup({})

        set_lines({
            "function x() {",
            "local xyz = 3",
            "end",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 2, 6 })
        feedkeys("dQp<CR>")

        check_lines({
            "function x() {",
            "local xyz = 3",
            "print('DEBUG[1]: " .. filename .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 3, 0 })
    end)

    it("non-identifier", function()
        debugprint.setup({})

        set_lines({
            "function x() {",
            "local xyz = 3",
            "end",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 2, 6 })
        feedkeys("dQpapple<CR>")

        check_lines({
            "function x() {",
            "local xyz = 3",
            "print('DEBUG[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 6 })
    end)

    it("disabled at function level", function()
        debugprint.setup({})

        set_lines({
            "function x() {",
            "local xyz = 3",
            "end",
        })

        local filename = write_file("lua")
        vim.api.nvim_win_set_cursor(0, { 2, 6 })
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
            "function x() {",
            "local xyz = 3",
            "print('DEBUG[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 6 })
    end)
end)
