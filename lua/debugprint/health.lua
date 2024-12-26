local M = {}

M.check = function()
    vim.health.start("debugprint.nvim report")

    local global_opts = require("debugprint").get_global_opts()

    if global_opts ~= nil then
        vim.health.ok(
            "debugprint is started with opts " .. vim.inspect(global_opts)
        )
    else
        vim.health.warn("debugprint is not yet started")
    end
end

return M
