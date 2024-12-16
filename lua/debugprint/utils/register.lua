local M = {}

---@return string|nil
M.register_named = function()
    if
        vim.v.register
        and string.find(
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
            vim.v.register
        )
    then
        return vim.v.register
    else
        return nil
    end
end

---@return string|nil
M.register_append = function()
    if
        vim.v.register
        and string.find("ABCDEFGHIJKLMNOPQRSTUVWXYZ", vim.v.register)
    then
        return vim.v.register
    else
        return nil
    end
end

---@param value string
M.set_register = function(value)
    assert(M.register_named ~= nil)
    vim.fn.setreg(vim.v.register, value, "l")
end

return M
