local M = {}

local utils_buffer = require("debugprint.utils.buffer")

---@return TSNode?
local get_node_at_cursor = function()
    local lang_filetype = vim.api.nvim_get_option_value("filetype", {})

    -- Force parsing, in case needed - appears to be for unit testing
    local ok, parser = pcall(vim.treesitter.get_parser, 0, lang_filetype)
    if ok and parser then
        parser:parse()
    end

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
local get_treesitter_lang_at = function(row, col)
    local success, parser = pcall(vim.treesitter.get_parser, 0)
    if not (success and parser) then
        return nil
    end

    -- parse(true) ensures injected/embedded language trees are available
    parser:parse(true)

    local lang_tree = parser:language_for_range({ row, col, row, col })
    if not lang_tree then
        return nil
    end

    return lang_tree:lang()
end

---@param row integer 0-indexed row
---@param col integer 0-indexed column
---@return string?
local find_variable_via_query = function(row, col)
    local lang = get_treesitter_lang_at(row, col)
    if not lang then
        return nil
    end

    local query = vim.treesitter.query.get(lang, "debugprint")
    if not query then
        return nil
    end

    local ok, parser = pcall(vim.treesitter.get_parser, 0)
    if not ok or not parser then
        return nil
    end

    local trees = parser:parse()
    if not trees or not trees[1] then
        return nil
    end

    local root = trees[1]:root()

    -- Find the largest (most complete) capture containing the cursor position.
    -- When multiple captures overlap (e.g. identifier inside member_expression),
    -- the largest range gives the most useful match at the cursor.
    local best_node = nil
    -- Weight rows more heavily than columns so multi-line nodes are always
    -- considered larger than single-line nodes.
    local ROW_WEIGHT = 100000

    for id, node, _ in query:iter_captures(root, 0, row, row + 1) do
        if query.captures[id] == "variable" then
            local sr, sc, er, ec = node:range()
            if
                (sr < row or (sr == row and sc <= col))
                and (er > row or (er == row and ec > col))
            then
                if best_node == nil then
                    best_node = node
                else
                    local bsr, bsc, ber, bec = best_node:range()
                    local cur_size = (er - sr) * ROW_WEIGHT + (ec - sc)
                    local best_size = (ber - bsr) * ROW_WEIGHT + (bec - bsc)
                    if cur_size > best_size then
                        best_node = node
                    end
                end
            end
        end
    end

    if best_node ~= nil then
        return vim.treesitter.get_node_text(best_node, 0)
    end

    return nil
end

---@return string?
local find_treesitter_variable = function()
    -- Try query-file approach first (e.g. queries/bash/debugprint.scm).
    -- This is the preferred mechanism for file types that provide a query file.
    local cursor = vim.api.nvim_win_get_cursor(0)
    local var = find_variable_via_query(cursor[1] - 1, cursor[2])
    if var ~= nil then
        return var
    end

    -- Fall back to the node-based approach used by all other file types.
    local node_at_cursor = get_node_at_cursor()

    if node_at_cursor == nil then
        return nil
    else
        return vim.treesitter.get_node_text(node_at_cursor, 0)
    end
end

---@param ignore_treesitter boolean
---@return string?
M.get_variable_name = function(ignore_treesitter)
    local variable_name = utils_buffer.get_visual_selection()

    if variable_name == false then
        return nil
    end

    if variable_name == nil and ignore_treesitter ~= true then
        variable_name = find_treesitter_variable()
    end

    if variable_name == nil then
        local word_under_cursor = vim.fn.expand("<cword>")
        variable_name = vim.fn.input("Variable name: ", word_under_cursor)

        if variable_name == nil or variable_name == "" then
            -- Don't show a warning because of this issue:
            -- https://github.com/andrewferrier/debugprint.nvim/issues/91.
            -- Instead just silently end debugprint operation.
            vim.api.nvim_cmd({ cmd = "mode" }, {}) -- Clear command
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

    local treesitter_lang =
        get_treesitter_lang_at(current_line_nr, current_line_col)

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

return M
