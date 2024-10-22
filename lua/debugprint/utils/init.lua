local M = {}

local utils_buffer = require("debugprint.utils.buffer")

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

---@param filetype_config DebugprintFileTypeConfig
---@return string?
local find_treesitter_variable = function(filetype_config)
    local node_at_cursor = get_node_at_cursor()

    if node_at_cursor == nil then
        return nil
    else
        if vim.tbl_get(filetype_config, "find_treesitter_variable") then
            return filetype_config.find_treesitter_variable(node_at_cursor)
        else
            return vim.treesitter.get_node_text(node_at_cursor, 0)
        end
    end
end

---@param ignore_treesitter boolean
---@param filetype_config DebugprintFileTypeConfig
---@return string?
M.get_variable_name = function(ignore_treesitter, filetype_config)
    local variable_name = utils_buffer.get_visual_selection()

    if variable_name == false then
        return nil
    end

    if variable_name == nil and ignore_treesitter ~= true then
        variable_name = find_treesitter_variable(filetype_config)
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

return M
