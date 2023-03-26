local M = {}

M.find_treesitter_variable = function()
    local function requiref(module)
        require(module)
    end

    local ts_utils_test = pcall(requiref, "nvim-treesitter.ts_utils")

    if not ts_utils_test then
        return nil
    else
        local ts_utils = require("nvim-treesitter.ts_utils")
        -- Once get_node_at_cursor() is in NeoVim core, the nvim-treesitter
        -- dependency can be removed: https://github.com/neovim/neovim/pull/18232
        local node = ts_utils.get_node_at_cursor()

        if node == nil then
            return nil
        else
            local node_type = node:type()

            local variable_name

            if vim.treesitter.get_node_text then
                -- vim.treesitter.query.get_node_text deprecated as of NeoVim
                -- 0.9
                variable_name = vim.treesitter.get_node_text(node, 0)
            else
                variable_name = vim.treesitter.query.get_node_text(node, 0)
            end

            -- lua -> identifier
            -- sh -> variable_name
            if node_type == "identifier" or node_type == "variable_name" then
                return variable_name
            else
                return nil
            end
        end
    end
end

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
        vim.notify(
            "debugprint not supported when multiple lines selected.",
            vim.log.levels.ERROR
        )
        return false
    end

    return vim.api.nvim_buf_get_text(0, line1, col1, line2, col2, {})[1]
end

M.get_operator_selection = function()
    local first_pos, last_pos = vim.fn.getpos("'["), vim.fn.getpos("']")

    local line1 = first_pos[2] - 1
    local line2 = last_pos[2] - 1
    local col1 = first_pos[3] - 1
    local col2 = last_pos[3]

    if line1 ~= line2 then
        vim.notify(
            "debugprint not supported when multiple lines in motion.",
            vim.log.levels.ERROR
        )
        return false
    end

    return vim.api.nvim_buf_get_text(0, line1, col1, line2, col2, {})[1]
end

return M
