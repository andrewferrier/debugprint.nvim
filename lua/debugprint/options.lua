local M = {}

local GLOBAL_OPTION_DEFAULTS = {
    create_keymaps = true,
    create_commands = true,
    display_counter = true,
    display_snippet = true,
    move_to_debugline = false,
    ignore_treesitter = false,
    filetypes = require("debugprint.filetypes"),
    print_tag = "DEBUGPRINT",
}

local validate_global_opts = function(o)
    vim.validate({
        create_keymaps = { o.create_keymaps, "boolean" },
        create_commands = { o.create_commands, "boolean" },
        display_counter = { o.display_counter, "boolean" },
        display_snippet = { o.display_snippet, "boolean" },
        move_to_debugline = { o.move_to_debugline, "boolean" },
        ignore_treesitter = { o.ignore_treesitter, "boolean" },
        filetypes = { o.filetypes, "table" },
        print_tag = { o.print_tag, "string" },
    })
end

local FUNCTION_OPTION_DEFAULTS = {
    above = false,
    variable = false,
    ignore_treesitter = false,
}

local validate_function_opts = function(o)
    vim.validate({
        above = { o.above, "boolean" },
        variable = { o.above, "boolean" },
        ignore_treesitter = { o.ignore_treesitter, "boolean" },
    })
end

M.get_and_validate_global_opts = function(opts)
    local global_opts = vim.tbl_deep_extend(
        "force",
        vim.deepcopy(GLOBAL_OPTION_DEFAULTS),
        opts or {}
    )

    validate_global_opts(global_opts)

    return global_opts
end

M.get_and_validate_function_opts = function(opts)
    local func_opts = vim.tbl_deep_extend(
        "force",
        vim.deepcopy(FUNCTION_OPTION_DEFAULTS),
        opts or {}
    )

    validate_function_opts(func_opts)

    return func_opts
end

return M
