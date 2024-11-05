local M = {}

---@param errormsg string
---@return string
M.construct_error_line = function(errormsg)
    local commentstring =
        vim.api.nvim_get_option_value("commentstring", { scope = "local" })

    if string.find(commentstring, "%%s") then
        return vim.fn.substitute(commentstring, "%s", errormsg, "")
    else
        return errormsg
    end
end

return M
