local debugprint = require("debugprint")
local support = require("tests.support")

describe("can do various file types", function()
    before_each(function()
        debugprint.setup({
            keymaps = support.ALWAYS_PROMPT_KEYMAP,
        })
    end)

    after_each(support.teardown)

    it("can handle a .vim file", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "vim", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            'echo "DEBUGPRINT[1]: ' .. filename .. ':1 (after foo)"',
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can handle a .vim file variable", function()
        local filename = support.init_file({
            "foo",
            "bar",
        }, "vim", 1, 0)

        support.feedkeys("g?q<BS><BS><BS>banana<CR>")

        support.check_lines({
            "foo",
            'echo "DEBUGPRINT[1]: ' .. filename .. ':1: banana=" .. banana',
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can handle a file where ext != filetype", function()
        local filename = support.init_file({
            "const Foo: FunctionalComponent = () => {",
            "    return <div>Hello World!</div>;",
            "};",
        }, "tsx", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "const Foo: FunctionalComponent = () => {",
            '    console.warn("DEBUGPRINT[1]: '
                .. filename
                .. ':1 (after const Foo: FunctionalComponent = () => )")',
            "    return <div>Hello World!</div>;",
            "};",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can gracefully handle unknown filetypes", function()
        support.init_file({
            "foo",
            "bar",
        }, "foo", 1, 0, { filetype = "foo" })

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "No debugprint configuration for filetype foo; see https://github.com/andrewferrier/debugprint.nvim/blob/main/SHOWCASE.md#modifying-or-adding-filetypes",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it(
        "can gracefully handle known filetypes we don't have a config for: fennel",
        function()
            support.init_file({
                "(fn print-and-add [a b c]",
                "  (print a)",
                "  (+ b c))",
            }, "fnl", 1, 0)

            support.feedkeys("g?p")

            if vim.fn.has("nvim-0.11.0") == 1 then
                -- On NeoVim nightly, this inserts an extra space before the comment
                support.check_lines({
                    "(fn print-and-add [a b c]",
                    "  ; No debugprint configuration for filetype fennel; see https://github.com/andrewferrier/debugprint.nvim/blob/main/SHOWCASE.md#modifying-or-adding-filetypes",
                    "  (print a)",
                    "  (+ b c))",
                })
            else
                support.check_lines({
                    "(fn print-and-add [a b c]",
                    "  ;No debugprint configuration for filetype fennel; see https://github.com/andrewferrier/debugprint.nvim/blob/main/SHOWCASE.md#modifying-or-adding-filetypes",
                    "  (print a)",
                    "  (+ b c))",
                })
            end

            assert.equals(support.get_notify_message(), nil)
        end
    )

    it("don't prompt for a variable name with an unknown filetype", function()
        support.init_file({
            "foo",
            "bar",
        }, "foo", 1, 0, { filetype = "foo" })

        support.feedkeys("g?q")
        support.feedkeys("<CR>")

        support.check_lines({
            "foo",
            "No debugprint configuration for filetype foo; see https://github.com/andrewferrier/debugprint.nvim/blob/main/SHOWCASE.md#modifying-or-adding-filetypes",
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
