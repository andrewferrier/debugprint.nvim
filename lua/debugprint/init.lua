local M = {}

local opts

OPTION_DEFAULTS = {
    create_keymaps = true,
    filetypes = {
        ["lua"] = { "print('", "')" },
    },
}

local counter = 0

local debuginfo = function()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    counter = counter + 1

    return "DEBUG: "
        .. vim.fn.expand("%:t")
        .. ":"
        .. current_line
        .. " ["
        .. counter
        .. "]"
end

local get_fix = function(filetype)
    if vim.tbl_contains(vim.tbl_keys(opts.filetypes), filetype) then
        return opts.filetypes[filetype][1], opts.filetypes[filetype][2]
    else
        vim.notify(
            "Don't have debugprint configuration for filetype " .. filetype,
            vim.log.levels.WARN
        )
        return nil, nil
    end
end

M.debugprint = function(above)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local filetype = vim.api.nvim_get_option_value("filetype", {})
    local indent = string.rep(" ", vim.fn.indent(current_line))
    local prefix, postfix = get_fix(filetype)

    if prefix == nil or postfix == nil then
        return
    else
        local line_to_insert = indent .. prefix .. debuginfo() .. postfix

        local line_to_insert_on

        if above then
            line_to_insert_on = current_line - 1
        else
            line_to_insert_on = current_line
        end

        vim.api.nvim_buf_set_lines(
            0,
            line_to_insert_on,
            line_to_insert_on,
            true,
            { line_to_insert }
        )
    end
end

M.debugprintvar = function(above) end

M.setup = function(o)
    opts = vim.tbl_deep_extend("force", OPTION_DEFAULTS, o or {})

    vim.validate({
        create_keymaps = { opts.create_keymaps, "boolean" },
    })

    if opts.create_keymaps then
        vim.keymap.set("n", "dqp", function()
            M.debugprint(false)
        end)
        vim.keymap.set("n", "dqP", function()
            M.debugprint(true)
        end)
        vim.keymap.set("n", "dQp", function()
            M.debugprintvar(false)
        end)
        vim.keymap.set("n", "dQP", function()
            M.debugprintvar(true)
        end)
    end

    -- Because we want to be idempotent, re-running setup() resets the counter
    counter = 0
end

return M
