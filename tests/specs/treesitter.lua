local debugprint = require("debugprint")
local support = require("tests.support")

describe("can handle treesitter identifiers", function()
    after_each(support.teardown)

    it("standard", function()
        debugprint.setup({})

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys("g?v")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: xyz=' .. vim.inspect(xyz))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 10 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("standard (bash)", function()
        debugprint.setup({})

        support.init_file({
            "XYZ=123",
        }, "bash", 1, 1)

        support.feedkeys("g?v")

        support.check_lines({
            "XYZ=123",
            '>&2 echo "DEBUGPRINT[1]: $0:$LINENO: XYZ=${XYZ}"',
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 1 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("non-identifier", function()
        debugprint.setup({})

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 9)

        support.feedkeys("g?v<BS><BS><BS>apple<CR>")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 9 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("always prompt below", function()
        debugprint.setup({
            keymaps = {
                normal = { variable_below_alwaysprompt = "zxa" },
            },
        })

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys("zxa<BS><BS><BS>apple<CR>")

        support.check_lines({
            "function x()",
            "    local xyz = 3",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 10 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("always prompt above", function()
        debugprint.setup({
            keymaps = { normal = { variable_above_alwaysprompt = "zxb" } },
        })

        local filename = support.init_file({
            "function x()",
            "    local xyz = 3",
            "end",
        }, "lua", 2, 10)

        support.feedkeys("zxb<BS><BS><BS>apple<CR>")

        support.check_lines({
            "function x()",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: apple=' .. vim.inspect(apple))",
            "    local xyz = 3",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 3, 10 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("special case dot expression (lua)", function()
        debugprint.setup()

        local filename = support.init_file({
            "function x()",
            "    local xyz = {}",
            "    xyz.abc = 123",
            "end",
        }, "lua", 3, 10)

        support.feedkeys("g?v")

        support.check_lines({
            "function x()",
            "    local xyz = {}",
            "    xyz.abc = 123",
            "    print('DEBUGPRINT[1]: "
                .. filename
                .. ":3: xyz.abc=' .. vim.inspect(xyz.abc))",
            "end",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 3, 10 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("special case dot expression (javascript)", function()
        debugprint.setup()

        local filename = support.init_file({
            "let x = {}",
            "x.abc = 123",
        }, "javascript", 2, 4)

        support.feedkeys("g?v")

        support.check_lines({
            "let x = {}",
            "x.abc = 123",
            'console.warn("DEBUGPRINT[1]: '
                .. filename
                .. ':2: x.abc=", x.abc)',
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 4 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("special case dot expression (c)", function()
        debugprint.setup()

        support.init_file({
            "int main() {",
            "person.year = 1984;",
            "}",
        }, "c", 2, 10)

        support.feedkeys("g?v")
        support.check_lines({
            "int main() {",
            "person.year = 1984;",
            'fprintf(stderr, "DEBUGPRINT[1]: %s:%d: person.year=%d\\n", __FILE__, __LINE__, person.year);',
            "}",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 10 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("special case dot expression (zig)", function()
        debugprint.setup()

        support.init_file({
            "pub fn main() void {",
            "person.year = 1984;",
            "}",
        }, "zig", 2, 10)

        support.feedkeys("g?v")
        support.check_lines({
            "pub fn main() void {",
            "person.year = 1984;",
            'std.debug.print("DEBUGPRINT[1]: {s}:{d}: person.year={any}\\n", .{ @src().file, @src().line, person.year });',
            "}",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 10 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("non-special case variable (python)", function()
        debugprint.setup()

        local filename = support.init_file({
            "x = 1",
        }, "py", 1, 0)

        support.feedkeys("g?v")

        support.check_lines({
            "x = 1",
            'print(f"DEBUGPRINT[1]: ' .. filename .. ':1: x={x}")',
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 0 })

        assert.equals(support.get_notify_message(), nil)
    end)

    -- These two test cases based on https://github.com/andrewferrier/debugprint.nvim/issues/89
    it("non-special case variable (php cursor-on-name)", function()
        debugprint.setup()

        local filename = support.init_file({
            "<?php",
            "$branchCode = 'au';",
            "?>",
        }, "php", 2, 3)

        support.feedkeys("g?v")

        support.check_lines({
            "<?php",
            "$branchCode = 'au';",
            'fwrite(STDERR, "DEBUGPRINT[1]: '
                .. filename
                .. ':2: branchCode=$branchCode\\n");',
            "?>",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 3 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("non-special case variable (php cursor-on-dollar)", function()
        debugprint.setup()

        local filename = support.init_file({
            "<?php",
            "$branchCode = 'au';",
            "?>",
        }, "php", 2, 1)

        support.feedkeys("g?v")

        support.check_lines({
            "<?php",
            "$branchCode = 'au';",
            'fwrite(STDERR, "DEBUGPRINT[1]: '
                .. filename
                .. ':2: branchCode=$branchCode\\n");',
            "?>",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 1 })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
