local M = {}

---@return nil
M.NOOP = function() end

---@param value string
M.set_operatorfunc = function(value)
    vim.api.nvim_set_option_value("operatorfunc", value, {})
end

---@param func_name string
---@return nil
M.set_callback = function(func_name)
    M.set_operatorfunc("v:lua.require'debugprint.utils.operator'.NOOP")
    vim.cmd("normal! g@l")
    M.set_operatorfunc(func_name)
end

return M
