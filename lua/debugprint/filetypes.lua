-- For most of these default configurations, debugprint.nvim aims to log at a
-- 'debug'-style level of logging. For more console-oriented languages (e.g.
-- shell), it logs to stderr, as this is often a standard way of producing
-- output which isn't part of the main program. In some cases, however, it
-- deviates from these principles, in particular to avoid the user of debugprint
-- having to modify their imports to make sure the statements can be
-- added/removed standalone, or to ensure that the statements are visible by
-- default. Explanations are given below in comments below in some cases.

local shell = {
    left = '>&2 echo "',
    right = '"',
    mid_var = "${",
    right_var = '}"',
}

local docker = vim.deepcopy(shell)

docker.left = "RUN " .. docker.left

-- Use console.warn() rather than console.debug() so that messages are visible
-- by default in browser consoles. console.warn() will send to stderr with
-- NodeJS.
local js = {
    left = 'console.warn("',
    right = '")',
    mid_var = '", ',
    right_var = ")",
}

return {
    ["bash"] = shell,
    ["c"] = {
        left = 'fprintf(stderr, "',
        right = '\\n");',
        mid_var = '%d\\n", ',
        right_var = ");",
    },
    ["cmake"] = {
        left = 'message(DEBUG "',
        right = '")',
        mid_var = "${",
        right_var = '}")',
    },
    ["cpp"] = {
        left = 'std::cerr << "',
        right = '" << std::endl;',
        mid_var = '" << ',
        right_var = " << std::endl;",
    },
    ["cs"] = {
        left = 'System.Console.Error.WriteLine($"',
        right = '")',
        mid_var = "{",
        right_var = '}");',
    },
    ["dart"] = {
        left = 'print("',
        right = '");',
        mid_var = "${",
        right_var = '}");',
    },
    ["dockerfile"] = docker,
    ["fish"] = {
        left = 'echo "',
        right = '" 1>&2',
        mid_var = "$",
        right_var = '" 1>&2',
    },
    ["go"] = {
        left = 'fmt.Fprintf(os.Stderr, "',
        right = '\\n")',
        mid_var = '%+v\\n", ',
        right_var = ")",
    },
    ["java"] = {
        left = 'System.err.println("',
        right = '");',
        mid_var = '" + ',
        right_var = ");",
    },
    ["javascript"] = js,
    ["javascriptreact"] = js,
    ["kotlin"] = {
        left = 'println("',
        right = '")',
        mid_var = "$",
        right_var = '")',
    },
    ["lua"] = {
        left = "print('",
        right = "')",
        mid_var = "' .. vim.inspect(",
        right_var = "))",
    },
    ["make"] = {
        left = '\t@echo >&2 "',
        right = '"',
        mid_var = '"$(',
        right_var = ")",
    },
    ["perl"] = {
        left = 'print STDERR "',
        right = '\\n";',
        mid_var = "$",
        right_var = '\\n";',
    },
    ["php"] = {
        left = 'fwrite(STDERR, "',
        right = '\\n");',
        mid_var = "$",
        right_var = '\\n");',
    },
    ["ps1"] = {
        left = 'Write-Error "',
        right = '"',
        mid_var = "$",
        right_var = '"',
    },
    -- Don't print to stderr by default, because it requires 'import sys'
    ["python"] = {
        left = 'print(f"',
        right = '")',
        mid_var = "{",
        right_var = '}")',
    },
    ["r"] = {
        left = 'cat(paste("',
        right = '"), file=stderr())',
        mid_var = '", ',
        right_var = "), file=stderr())",
    },
    ["ruby"] = {
        left = 'STDERR.puts "',
        right = '"',
        mid_var = "#{",
        right_var = '}"',
    },
    ["rust"] = {
        left = 'eprintln!("',
        right = '");',
        mid_var = '{:#?}", ',
        right_var = ");",
    },
    ["sh"] = shell,
    ["swift"] = {
        left = 'debugPrint("',
        right = '")',
        mid_var = "\\(",
        right_var = ')")',
    },
    ["typescript"] = js,
    ["typescriptreact"] = js,
    ["vim"] = {
        left = 'echo "',
        right = '"',
        mid_var = '" .. ',
        right_var = "",
    },
    ["zsh"] = shell,
}
