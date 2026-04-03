local M = {}

local utils = require("debugprint.utils")
local utils_buffer = require("debugprint.utils.buffer")

---@param row integer 0-indexed row
---@param col integer 0-indexed column
---@return string?
local find_variable_via_query = function(row, col)
    local lang = utils.get_treesitter_lang_at(row, col)
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
    -- When multiple captures overlap, the largest range gives the most useful match at the cursor.
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
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]
    local var = find_variable_via_query(row, col)
    if var ~= nil then
        return var
    end

    -- If the language has a query file but find_variable_via_query found no
    -- capture, return nil so we don't use treesitter at all. Only fall through
    -- to the generic node-text path for languages that have no query file.
    local lang = utils.get_treesitter_lang_at(row, col)
    if lang and vim.treesitter.query.get(lang, "debugprint") then
        return nil
    end

    -- Fall back to the node-based approach used by file types without a query
    -- file.
    local node_at_cursor = utils.get_node_at_cursor()

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

return M
