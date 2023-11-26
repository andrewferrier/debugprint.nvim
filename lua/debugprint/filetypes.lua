-- For most of these default configurations, we're aiming to log at a
-- 'debug'-style level of logging. For more console-oriented languages (e.g.
-- shell/python), we log to stderr, as this is often a standard way of producing
-- output which isn't part of the main program. For others (e.g. JavaScript), we
-- use a language-specific way, i.e. console.debug().
--
-- In general, we're trying to avoid the user of debugprint having to modify
-- their imports or other libraries in order to use any of these statements.
-- However, in a few cases, that might be needed. Any potential improvements to
-- this welcome.

local shell = {
    left = '>&2 echo "',
    right = '"',
    mid_var = "${",
    right_var = '}"',
}

local docker = vim.deepcopy(shell)

docker.left = "RUN " .. docker.left

local js = {
    left = 'console.debug("',
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
    ["python"] = {
        left = 'print(f"',
        right = '", file=sys.stderr)',
        mid_var = "{",
        right_var = '}", file=sys.stderr)',
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
