local debugprint = require("debugprint")
local support = require("tests.support")

local LUA_TS_EXPR = "(function()local s,u=vim.uv.gettimeofday()"
    .. "return os.date('%H:%M:%S',s)..('%.3f'):format(u/1e6):sub(2)end)()"

local PYTHON_TS_EXPR =
    "__import__('datetime').datetime.now().strftime('%H:%M:%S.%f')[:12]"

local JS_TS_EXPR = "(d=>d.toTimeString().slice(0,8)"
    .. '+"."+String(d.getMilliseconds()).padStart(3,"0"))(new Date())'

local RUST_TS_EXPR = 'chrono::Local::now().format("%H:%M:%S%.3f")'

describe("display_timestamp", function()
    after_each(support.teardown)

    it("is off by default - lua plain", function()
        debugprint.setup()

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })
    end)

    it("lua plain with timestamp", function()
        debugprint.setup({ display_timestamp = true, display_location = false })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print(" .. LUA_TS_EXPR .. "..': '..'DEBUGPRINT[1]: (after foo)')",
            "bar",
        })
    end)

    it("lua variable with timestamp", function()
        debugprint.setup({
            display_timestamp = true,
            display_location = false,
        })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?v")

        support.check_lines({
            "foo",
            "print("
                .. LUA_TS_EXPR
                .. "..': '..'DEBUGPRINT[1]: foo=' .. vim.inspect(foo))",
            "bar",
        })
    end)

    it("python plain with timestamp", function()
        debugprint.setup({
            display_timestamp = true,
            display_location = false,
        })

        support.init_file({
            "foo",
            "bar",
        }, "py", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            'print(f"{' .. PYTHON_TS_EXPR .. '}: DEBUGPRINT[1]: (after foo)")',
            "bar",
        })
    end)

    it("python variable with timestamp", function()
        debugprint.setup({
            display_timestamp = true,
            display_location = false,
        })

        support.init_file({
            "foo",
            "bar",
        }, "py", 1, 0)

        support.feedkeys("g?v")

        support.check_lines({
            "foo",
            'print(f"{' .. PYTHON_TS_EXPR .. '}: DEBUGPRINT[1]: foo={foo}")',
            "bar",
        })
    end)

    it("javascript plain with timestamp", function()
        debugprint.setup({
            display_timestamp = true,
            display_location = false,
        })

        support.init_file({
            "foo",
            "bar",
        }, "js", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "console.warn("
                .. JS_TS_EXPR
                .. '+": "+"DEBUGPRINT[1]: (after foo)")',
            "bar",
        })
    end)

    it("javascript variable with timestamp", function()
        debugprint.setup({
            display_timestamp = true,
            display_location = false,
        })

        support.init_file({
            "foo",
            "bar",
        }, "js", 1, 0)

        support.feedkeys("g?v")

        support.check_lines({
            "foo",
            "console.warn("
                .. JS_TS_EXPR
                .. '+": "+"DEBUGPRINT[1]: foo=", foo)',
            "bar",
        })
    end)

    it("rust plain with timestamp", function()
        debugprint.setup({
            display_timestamp = true,
            display_location = false,
        })

        support.init_file({
            "foo",
            "bar",
        }, "rs", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            'eprintln!("{}: DEBUGPRINT[1]: (after foo)", '
                .. RUST_TS_EXPR
                .. ", file!(), line!());",
            "bar",
        })
    end)

    it("rust variable with timestamp", function()
        debugprint.setup({
            display_timestamp = true,
            display_location = false,
        })

        support.init_file({
            "foo",
            "bar",
        }, "rs", 1, 0)

        support.feedkeys("g?v")

        support.check_lines({
            "foo",
            'eprintln!("{}: DEBUGPRINT[1]: foo={:#?}", '
                .. RUST_TS_EXPR
                .. ", file!(), line!(), foo);",
            "bar",
        })
    end)

    it("unsupported language silently omits timestamp", function()
        debugprint.setup({ display_timestamp = true })

        support.init_file({
            "foo",
            "bar",
        }, "sh", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            '>&2 echo "DEBUGPRINT[1]: $0:$LINENO (after foo)"',
            "bar",
        })
    end)

    it("per-filetype override: global true, filetype false", function()
        debugprint.setup({
            display_timestamp = true,
            filetypes = { ["lua"] = { display_timestamp = false } },
        })

        local filename = support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print('DEBUGPRINT[1]: " .. filename .. ":1 (after foo)')",
            "bar",
        })
    end)

    it("per-filetype override: global false, filetype true", function()
        debugprint.setup({
            display_timestamp = false,
            display_location = false,
            filetypes = { ["lua"] = { display_timestamp = true } },
        })

        support.init_file({
            "foo",
            "bar",
        }, "lua", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            "print(" .. LUA_TS_EXPR .. "..': '..'DEBUGPRINT[1]: (after foo)')",
            "bar",
        })
    end)

    it("custom filetype with function-based left", function()
        debugprint.setup({
            display_timestamp = true,
            display_location = false,
            filetypes = {
                ["myft"] = {
                    left = function(opts)
                        if opts.display_timestamp then
                            return 'myprint(my_ts() + ": " + "'
                        end
                        return 'myprint("'
                    end,
                    right = '")',
                    mid_var = '" + ',
                    right_var = ")",
                },
            },
        })

        support.init_file({
            "foo",
            "bar",
        }, "myft", 1, 0, { filetype = "myft" })

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            'myprint(my_ts() + ": " + "DEBUGPRINT[1]: (after foo)")',
            "bar",
        })
    end)
end)
