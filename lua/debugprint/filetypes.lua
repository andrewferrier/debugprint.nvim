return {
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
    ["vim"] = {
        left = 'echo "',
        right = '"',
        mid_var = '" .. ',
        right_var = "",
    },
}
