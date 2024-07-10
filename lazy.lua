local spec = {
    url = "https://github.com/andrewferrier/debugprint.nvim",
    opts = {},
    -- FIXME: Work around temporary issue with lazy-loading
    -- keys = {
    --     { "g?", mode = "n" },
    --     { "g?", mode = "x" },
    -- },
    -- cmd = {
    --     "ToggleCommentDebugPrints",
    --     "DeleteDebugPrints",
    -- },
    -- lazy = true,
    -- FIXME: Only introduce this line when we are about to release the next stable version otherwise this will cause a yo-yo effect
    -- Use stable versions by default
    -- version = '*',
}

if vim.fn.has('nvim-0.10') == 0 then
    spec.dependencies = {
        "echasnovski/mini.nvim" -- Needed to enable :ToggleCommentDebugPrints for NeoVim 0.9
    }
end

return spec
