local M = {}

local utils_buffer = require("debugprint.utils.buffer")

---@param lang string?
---@return vim.treesitter.LanguageTree?
local force_parsing_if_possible = function(lang)
    local ok, parser

    if lang ~= nil then
        ok, parser = pcall(vim.treesitter.get_parser, 0, lang)
    else
        ok, parser = pcall(vim.treesitter.get_parser, 0)
    end

    if ok and parser then
        parser:parse(true)
        return parser
    else
        return nil
    end
end

---@return TSNode?
M.get_node_at_cursor = function()
    force_parsing_if_possible(vim.api.nvim_get_option_value("filetype", {}))

    local success, node = pcall(vim.treesitter.get_node, {
        ignore_injections = false,
    })

    -- This will fail if this language is not supported by Treesitter
    if success and node then
        return node
    else
        return nil
    end
end

---@param row integer 0-indexed row
---@param col integer 0-indexed column
---@return string?
M.get_treesitter_lang_at = function(row, col)
    local parser = force_parsing_if_possible()
    if not parser then
        return nil
    end

    local lang_tree = parser:language_for_range({ row, col, row, col })
    if not lang_tree then
        return nil
    end

    return lang_tree:lang()
end

---@return string[]
M.get_effective_filetypes = function()
    local current_line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
    -- Looking at the last column is more accurate because there are some
    -- embeddings (e.g. JS in HTML) where the Treesitter embedding doesn't begin
    -- until the first non-whitespace column
    local current_line_col = vim.fn.col("$")

    local treesitter_lang =
        M.get_treesitter_lang_at(current_line_nr, current_line_col)

    if treesitter_lang then
        local filetypes = vim.treesitter.language.get_filetypes(treesitter_lang)
        -- The order in which filetypes are provided seems to be semi-random
        -- (at least prior to v0.10) so we are sorting them to at least give some
        -- stability.
        table.sort(filetypes)
        assert(vim.tbl_count(filetypes) > 0)
        return filetypes
    else
        return {
            vim.api.nvim_get_option_value("filetype", { scope = "local" }),
        }
    end
end

local MAX_SNIPPET_LENGTH = 40

---@param current_line integer
---@param above boolean
---@return string
M.get_snippet = function(current_line, above)
    local line_contents = ""

    while line_contents == "" do
        line_contents = utils_buffer.get_trimmed_content_of_line(current_line)

        if line_contents == "" then
            if above then
                current_line = current_line + 1
            else
                current_line = current_line - 1
            end

            if current_line < 1 then
                return "(start of file)"
            end

            if current_line > vim.api.nvim_buf_line_count(0) then
                return "(end of file)"
            end
        end
    end

    if line_contents:len() > MAX_SNIPPET_LENGTH then
        line_contents = string.sub(line_contents, 0, MAX_SNIPPET_LENGTH)
            .. "…"
    end

    if above then
        line_contents = "(before " .. line_contents .. ")"
    else
        line_contents = "(after " .. line_contents .. ")"
    end

    return line_contents
end

---@param value any
---@param ... any
---@return any
M.resolve_value = function(value, ...)
    if type(value) == "function" then
        return value(...)
    end
    return value
end

return M
