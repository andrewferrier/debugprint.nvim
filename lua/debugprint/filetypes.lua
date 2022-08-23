local shell = {
    left = 'echo "',
    right = '"',
    mid_var = "${",
    right_var = '}"',
}

local js = {
    left = 'console.log("',
    right = '")',
    mid_var = '", ',
    right_var = ")",
}

return {
    ["bash"] = shell,
    ["c"] = {
        left = 'printf("',
        right = '");',
        mid_var = '%d", ',
        right_var = ");",
    },
    ["cpp"] = {
        left = 'std::cout << "',
        right = '" << std::endl;',
        mid_var = '" << ',
        right_var = " << std::endl;",
    },
    ["dart"] = {
        left = 'print("',
        right = '");',
        mid_var = "${",
        right_var = '}");',
    },
    ["go"] = {
        left = 'fmt.Printf("',
        right = '")',
        mid_var = '%+v\\n", ',
        right_var = ")",
    },
    ["java"] = {
        left = 'System.out.println("',
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
        left = 'echo "',
        right = '\\n";',
        mid_var = "$",
        right_var = '\\n";',
    },
    ["python"] = {
        left = 'print(f"',
        right = '")',
        mid_var = "{",
        right_var = '}")',
    },
    ["ruby"] = {
        left = 'puts "',
        right = '"',
        mid_var = "#{",
        right_var = '}"',
    },
    ["rust"] = {
        left = 'println!("',
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
