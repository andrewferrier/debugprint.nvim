local M = {}

---@param print_tag string
---@param bufnr integer
local setup_highlight_buffer = function(print_tag, bufnr)
    local success, module = pcall(require, "mini.hipatterns")

    if success then
        -- luacheck: ignore 122
        vim.b.minihipatterns_config =
            vim.tbl_deep_extend("keep", vim.b.minihipatterns_config or {}, {
                highlighters = {
                    debugprint = {
                        pattern = "%S.*" .. print_tag .. ".*",
                        group = "DebugPrintLine",
                    },
                },
            })

        module.enable(bufnr)
    end
end

---@param print_tag string
M.setup_highlight = function(print_tag)
    vim.api.nvim_set_hl(0, "DebugPrintLine", { link = "Debug", default = true })

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        callback = function(opts)
            setup_highlight_buffer(print_tag, opts.buf)
        end,
    })
end

return M