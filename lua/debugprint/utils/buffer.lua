local M = {}

---@param line_nr integer
---@return string
M.get_trimmed_content_of_line = function(line_nr)
    local line_contents =
        vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, true)[1]

    -- Remove whitespace and any quoting characters which could potentially
    -- cause a syntax error in the statement being printed, or any characters
    -- which could cause unintended interpolation of expressions
    line_contents = line_contents:gsub("^%s+", "") -- leading
    line_contents = line_contents:gsub("%s+$", "") -- trailing
    line_contents = line_contents:gsub("[\"'\\`%${}]", "")

    return line_contents
end

---@param line_nr integer
---@param move_to_indented_line boolean
---@return nil
M.indent_line = function(line_nr, move_to_indented_line)
    local pos = vim.api.nvim_win_get_cursor(0)
    -- There's probably a better way to do this indent, but I don't know what it is
    vim.cmd(line_nr + 1 .. "normal! ==")

    if not move_to_indented_line then
        vim.api.nvim_win_set_cursor(0, pos)
    end
end

---@param line integer
---@return nil
M.toggle_comment_line = function(line)
    if vim.fn.has("nvim-0.10.0") == 1 then
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd(line .. "norm gcc")
        vim.api.nvim_win_set_cursor(0, pos)
    else
        local status, comment = pcall(require, "mini.comment")

        if status == true then
            comment.toggle_lines(line, line, {})
        else
            vim.notify_once(
                "mini.nvim is required to toggle comment debugprint lines prior to NeoVim 0.10",
                vim.log.levels.ERROR,
                {}
            )
        end
    end
end

---@return string|false|nil
M.get_visual_selection = function()
    local mode = vim.fn.mode():lower()
    if not (mode:find("^v") or mode:find("^ctrl-v")) then
        return nil
    end

    local first_pos, last_pos = vim.fn.getpos("v"), vim.fn.getpos(".")

    local line1 = first_pos[2] - 1
    local line2 = last_pos[2] - 1
    local col1 = first_pos[3] - 1
    local col2 = last_pos[3]

    if line2 < line1 or (line1 == line2 and col2 < col1) then
        local linet = line2
        line2 = line1
        line1 = linet

        local colt = col2
        col2 = col1
        col1 = colt

        col1 = col1 - 1
        col2 = col2 + 1
    end

    if line1 ~= line2 then
        -- Multiple lines are selected; in this case, silently fail to find a
        -- visual selection, since it's unlikely to be what the user wants
        -- anyway, and there's no good way to give them an error (vim.notify()
        -- may fail because of an issue similar to this:
        -- https://github.com/andrewferrier/debugprint.nvim/issues/91).
        return false
    end

    return vim.api.nvim_buf_get_text(0, line1, col1, line2, col2, {})[1]
end

---@return string|false
M.get_operator_selection = function()
    local first_pos, last_pos = vim.fn.getpos("'["), vim.fn.getpos("']")

    local line1 = first_pos[2] - 1
    local line2 = last_pos[2] - 1
    local col1 = first_pos[3] - 1
    local col2 = last_pos[3]

    if line1 ~= line2 then
        -- This seems to work OK with nvim-notify and is not affected by
        -- https://github.com/andrewferrier/debugprint.nvim/issues/91
        vim.notify(
            "debugprint not supported when multiple lines in motion.",
            vim.log.levels.ERROR
        )
        return false
    end

    return vim.api.nvim_buf_get_text(0, line1, col1, line2, col2, {})[1]
end

---@return boolean
M.is_modifiable = function()
    if
        not vim.api.nvim_get_option_value(
            "modifiable",
            { buf = vim.api.nvim_get_current_buf() }
        )
    then
        vim.notify("Buffer is not modifiable.", vim.log.levels.ERROR)
        return false
    else
        return true
    end
end

---@param opts DebugprintCommandOpts
---@return string[],integer
M.get_command_lines_to_handle = function(opts)
    local lines_to_consider
    local initial_line

    -- opts.range appears to be the magic value that indicates a range is passed
    -- in and valid.

    if
        opts
        and (opts.range == 1 or opts.range == 2)
        and opts.line1
        and opts.line2
    then
        lines_to_consider =
            vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
        initial_line = opts.line1
    else
        lines_to_consider = vim.api.nvim_buf_get_lines(0, 0, -1, true)
        initial_line = 1
    end

    return lines_to_consider, initial_line
end

return M
