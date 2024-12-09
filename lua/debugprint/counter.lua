local M = {}

local default_counter

-- FIXME: Switch to joinpath for more elegance once we stop supporting <0.10
local DATA_PATH = vim.fn.stdpath("data") .. "/debugprint"
local COUNTER_FILE = DATA_PATH .. "/counter"

---@return string
M.default_display_counter = function()
    if vim.fn.mkdir(DATA_PATH, "p") == 1 then
        if vim.fn.filereadable(COUNTER_FILE) == 1 then
            local counter_lines = vim.fn.readfile(COUNTER_FILE)

            if #counter_lines == 1 then
                default_counter = tonumber(counter_lines[1])
            end
        end
    end

    if default_counter == nil then
        default_counter = 0
    end

    default_counter = default_counter + 1

    if vim.fn.filewritable(DATA_PATH) == 2 then
        vim.fn.writefile({ default_counter }, COUNTER_FILE)
    end

    return "[" .. tostring(default_counter) .. "]"
end

---@return nil
M.reset_debug_prints_counter = function()
    if vim.fn.filewritable(COUNTER_FILE) == 1 then
        vim.fn.delete(COUNTER_FILE)
    end

    default_counter = nil
end

return M
