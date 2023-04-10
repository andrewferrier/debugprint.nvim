local shell = {
    left = '>&2 echo "',
    right = '"',
    mid_var = "${",
    right_var = '}"',
}

local docker = vim.deepcopy(shell)

docker.left = "RUN " .. docker.left

local js = {
    left = 'console.log("',
    right = '")',
    mid_var = '", ',
    right_var = ")",
}

-- still printing to stdout: dart, lua, make, vim

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
    ["lua"] = {
        left = "print('",
        right = "')",
        mid_var = "' .. vim.inspect(",
        right_var = "))",
    },
    ["make"] = {
        left = '\t@echo "',
        right = '"',
        mid_var = '"$(',
        right_var = ")",
    },
    ["php"] = {
        left = 'fwrite(STDERR, "',
        right = '\\n");',
        mid_var = "$",
        right_var = '\\n");',
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
        mid_var = '{}", ',
        right_var = ");",
    },
    ["sh"] = shell,
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
