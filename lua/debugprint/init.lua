local M = {}

local opts

OPTION_DEFAULTS = {
    create_keymaps = true,
    filetypes = require('debugprint.filetypes'),
}

local counter = 0

local debuginfo = function(variable_name)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    counter = counter + 1

    local line = "DEBUG: "
        .. vim.fn.expand("%:t")
        .. ":"
        .. current_line
        .. " ["
        .. counter
        .. "]"

    if variable_name ~= nil then
        line = line .. ": " .. variable_name .. "="
    end

    return line
end

local get_fix = function(filetype)
    if vim.tbl_contains(vim.tbl_keys(opts.filetypes), filetype) then
        return opts.filetypes[filetype]
    else
        vim.notify(
            "Don't have debugprint configuration for filetype " .. filetype,
            vim.log.levels.WARN
        )
        return nil
    end
end

local indent_line = function(current_line)
    local pos = vim.api.nvim_win_get_cursor(0)
    -- There's probably a better way to do this indent, but I don't know what it is
    vim.cmd(current_line + 1 .. "normal! ==")
    vim.api.nvim_win_set_cursor(0, pos)
end

M.debugprint = function(o)
    local funcopts = vim.tbl_deep_extend(
        "force",
        { above = false, variable = false },
        o or {}
    )

    vim.validate({
        above = { funcopts.above, "boolean" },
    })

    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local filetype = vim.api.nvim_get_option_value("filetype", {})
    local fixes = get_fix(filetype)

    if fixes == nil then
        return
    end

    local line_to_insert
    local line_to_insert_on

    if funcopts.variable then
        local variable_name = vim.fn.input("Variable name: ")

        line_to_insert = fixes.left
            .. debuginfo(variable_name)
            .. fixes.mid_var
            .. variable_name
            .. fixes.right_var
    else
        line_to_insert = fixes.left .. debuginfo() .. fixes.right
    end

    if funcopts.above then
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

    indent_line(line_to_insert_on)
end

M.setup = function(o)
    opts = vim.tbl_deep_extend("force", OPTION_DEFAULTS, o or {})

    vim.validate({
        create_keymaps = { opts.create_keymaps, "boolean" },
    })

    if opts.create_keymaps then
        vim.keymap.set("n", "dqp", function()
            M.debugprint()
        end)
        vim.keymap.set("n", "dqP", function()
            M.debugprint({ above = true })
        end)
        vim.keymap.set("n", "dQp", function()
            M.debugprint({ variable = true })
        end)
        vim.keymap.set("n", "dQP", function()
            M.debugprint({ above = true, variable = true })
        end)
    end

    -- Because we want to be idempotent, re-running setup() resets the counter
    counter = 0
end

M.add_custom_filetypes = function(filetypes)
    vim.validate({
        filetypes = { filetypes, "table" },
    })

    opts.filetypes = vim.tbl_deep_extend("force", opts.filetypes, filetypes)
end

return M
