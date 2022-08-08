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
    right_var = ')',
}

return {
    ["bash"] = shell,
    ["javascript"] = js,
    ["lua"] = {
        left = "print('",
        right = "')",
        mid_var = "' .. vim.inspect(",
        right_var = "))",
    },
    ["make"] = {
        left = '@echo "',
        right = '"',
        mid_var = '"$(',
        right_var = ")",
    },
    ["sh"] = shell,
    ["typescript"] = js,
    ["vim"] = {
        left = 'echo "',
        right = '"',
        mid_var = '" .. ',
        right_var = "",
    },
    ["zsh"] = shell,
}
