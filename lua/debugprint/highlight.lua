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

---@param filetypes debugprint.FileTypeConfig[]
---@param print_tag string
---@param highlight_lines_option boolean|function(integer):boolean
M.setup_highlight = function(filetypes, print_tag, highlight_lines_option)
    if print_tag then
        vim.api.nvim_set_hl(
            0,
            "DebugPrintLine",
            { link = "Debug", default = true }
        )

        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
            callback = function(opts)
                local buffer_filetype = vim.bo[opts.buf].filetype

                local should_highlight

                -- Check if highlighting should be enabled for this buffer
                if type(highlight_lines_option) == "function" then
                    should_highlight = highlight_lines_option(opts.buf)
                else
                    should_highlight = highlight_lines_option
                end

                if should_highlight and filetypes[buffer_filetype] ~= nil then
                    setup_highlight_buffer(print_tag, opts.buf)
                end
            end,
        })
    else
        vim.notify_once(
            "debugprint: highlight_lines is set, but there is no printtag, so nothing will be highlighted.",
            vim.log.levels.WARN
        )
    end
end

return M
