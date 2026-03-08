local debugprint = require("debugprint")
local support = require("tests.support")

describe("can handle treesitter queries", function()
    after_each(support.teardown)

    it("standard (bash) via query - variable reference in echo", function()
        debugprint.setup({})

        support.init_file({
            'echo "$FOO"',
        }, "bash", 1, 7)

        support.feedkeys("g?v")

        support.check_lines({
            'echo "$FOO"',
            '>&2 echo "DEBUGPRINT[1]: $0:$LINENO: FOO=${FOO}"',
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 7 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("standard (sh) via query - same grammar as bash", function()
        debugprint.setup({})

        support.init_file({
            "MY_VAR=hello",
        }, "sh", 1, 2)

        support.feedkeys("g?v")

        support.check_lines({
            "MY_VAR=hello",
            '>&2 echo "DEBUGPRINT[1]: $0:$LINENO: MY_VAR=${MY_VAR}"',
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 2 })

        assert.equals(support.get_notify_message(), nil)
    end)

    if vim.fn.has("nvim-0.12.0") == 1 then
        -- This currently only works on NeoVim nightly (0.12)+, because
        -- the ones before don't have a zsh grammar
        it("standard (zsh) via query - same grammar as bash", function()
            debugprint.setup({})

            support.init_file({
                "MY_VAR=hello",
            }, "zsh", 1, 2)

            support.feedkeys("g?v")

            support.check_lines({
                "MY_VAR=hello",
                '>&2 echo "DEBUGPRINT[1]: $0:$LINENO: MY_VAR=${MY_VAR}"',
            })

            assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 2 })

            assert.equals(support.get_notify_message(), nil)
        end)
    end

    it("standard (javascript) via query - plain identifier", function()
        debugprint.setup()

        local filename = support.init_file({
            "let myVar = 42",
        }, "javascript", 1, 4)

        support.feedkeys("g?v")

        support.check_lines({
            "let myVar = 42",
            'console.warn("DEBUGPRINT[1]: '
                .. filename
                .. ':1: myVar=", myVar)',
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 4 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("standard (javascript) via query - member expression", function()
        debugprint.setup()

        local filename = support.init_file({
            "obj.value = 10",
        }, "javascript", 1, 4)

        support.feedkeys("g?v")

        support.check_lines({
            "obj.value = 10",
            'console.warn("DEBUGPRINT[1]: '
                .. filename
                .. ':1: obj.value=", obj.value)',
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 4 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("standard (lua) via query - plain identifier", function()
        debugprint.setup()

        local filename = support.init_file({
            "local myValue = 42",
        }, "lua", 1, 6)

        support.feedkeys("g?v")

        support.check_lines({
            "local myValue = 42",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":1: myValue=' .. vim.inspect(myValue))",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 1, 6 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("standard (lua) via query - dot expression", function()
        debugprint.setup()

        local filename = support.init_file({
            "local t = {}",
            "t.key = 'hello'",
        }, "lua", 2, 2)

        support.feedkeys("g?v")

        support.check_lines({
            "local t = {}",
            "t.key = 'hello'",
            "print('DEBUGPRINT[1]: "
                .. filename
                .. ":2: t.key=' .. vim.inspect(t.key))",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 2 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("standard (c) via query - plain identifier", function()
        debugprint.setup()

        support.init_file({
            "int main() {",
            "int counter = 0;",
            "}",
        }, "c", 2, 4)

        support.feedkeys("g?v")

        support.check_lines({
            "int main() {",
            "int counter = 0;",
            'fprintf(stderr, "DEBUGPRINT[1]: %s:%d: counter=%d\\n", __FILE__, __LINE__, counter);',
            "}",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 4 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("standard (c) via query - field expression", function()
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

    it("standard (zig) via query - plain identifier", function()
        debugprint.setup()

        support.init_file({
            "pub fn main() void {",
            "const counter: u32 = 0;",
            "}",
        }, "zig", 2, 6)

        support.feedkeys("g?v")

        support.check_lines({
            "pub fn main() void {",
            "const counter: u32 = 0;",
            'std.debug.print("DEBUGPRINT[1]: {s}:{d}: counter={any}\\n", .{ @src().file, @src().line, counter });',
            "}",
        })

        assert.are.same(vim.api.nvim_win_get_cursor(0), { 2, 6 })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("standard (zig) via query - field expression", function()
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
end)
