local M = {}

---@return TSNode?
local get_node_at_cursor = function()
    local success, node = pcall(vim.treesitter.get_node, {
        ignore_injections = false,
    })

    -- This will fail if this language is not supported by Treesitter, e.g.
    -- Powershell/ps1
    if success and node then
        return node
    else
        return nil
    end
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

---@param ignore_treesitter boolean
---@param filetype_config FileTypeConfig
---@return string?
M.get_variable_name = function(ignore_treesitter, filetype_config)
    local variable_name = M.get_visual_selection()

    if variable_name == false then
        return nil
    end

    if variable_name == nil and ignore_treesitter ~= true then
        variable_name = M.find_treesitter_variable(filetype_config)
    end

    if variable_name == nil then
        local word_under_cursor = vim.fn.expand("<cword>")
        variable_name = vim.fn.input("Variable name: ", word_under_cursor)

        if variable_name == nil or variable_name == "" then
            -- Don't show a warning because of this issue:
            -- https://github.com/andrewferrier/debugprint.nvim/issues/91.
            -- Instead just silently end debugprint operation.
            vim.cmd("mode") -- Clear command
            return nil
        end
    end

    return variable_name
end

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

---@return nil
M.NOOP = function() end

---@param func_name string
---@return nil
M.set_callback = function(func_name)
    vim.go.operatorfunc = "v:lua.require'debugprint.utils'.NOOP"
    vim.cmd("normal! g@l")
    vim.go.operatorfunc = func_name
end

---@return string[]
M.get_effective_filetypes = function()
    local current_line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
    -- Looking at the last column is more accurate because there are some
    -- embeddings (e.g. JS in HTML) where the Treesitter embedding doesn't begin
    -- until the first non-whitespace column
    local current_line_col = vim.fn.col("$")

    local success, parser = pcall(vim.treesitter.get_parser, 0)

    if success then
        -- For some reason I don't understand, this parse line is necessary to
        -- make embedded languages work
        parser:parse(true)

        local treesitter_lang = parser
            :language_for_range({
                current_line_nr,
                current_line_col,
                current_line_nr,
                current_line_col,
            })
            :lang()

        local filetypes = vim.treesitter.language.get_filetypes(treesitter_lang)
        assert(vim.tbl_count(filetypes) > 0)
        return filetypes
    else
        return {
            vim.api.nvim_get_option_value("filetype", { scope = "local" }),
        }
    end
end

---@param filetype_config FileTypeConfig
---@return string?
M.find_treesitter_variable = function(filetype_config)
    local node_at_cursor = get_node_at_cursor()

    if node_at_cursor == nil then
        return nil
    else
        ---@type FindTreesitterVariableOpts
        local obj = {
            node = node_at_cursor,
            get_node_text = function(node)
                return vim.treesitter.get_node_text(node, 0)
            end,
        }

        if vim.tbl_get(filetype_config, "find_treesitter_variable") then
            return filetype_config.find_treesitter_variable(obj)
        else
            return obj.get_node_text(obj.node)
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

return M
