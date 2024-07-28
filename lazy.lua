local spec = {
    url = "https://github.com/andrewferrier/debugprint.nvim",
}

if vim.fn.has('nvim-0.10') == 0 then
    spec.dependencies = {
        "echasnovski/mini.nvim" -- Needed to enable :ToggleCommentDebugPrints for NeoVim 0.9
    }
end

return spec
