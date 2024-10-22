local M = {}

---@return nil
M.NOOP = function() end

---@param func_name string
---@return nil
M.set_callback = function(func_name)
    vim.go.operatorfunc = "v:lua.require'debugprint.utils.operator'.NOOP"
    vim.cmd("normal! g@l")
    vim.go.operatorfunc = func_name
end

return M
