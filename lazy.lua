local spec = {
    url = "https://github.com/andrewferrier/debugprint.nvim",
}

if vim.fn.has("nvim-0.10") == 0 then
    -- Mini is needed to enable :ToggleCommentDebugPrints for NeoVim 0.9
    --
    -- It's also needed to enable line highlighting, but since this is an
    -- optional cosmetic extra only, we're not going to include it here so it's
    -- not forced on the user.

    spec.dependencies = {
        "echasnovski/mini.nvim",
    }
end

return spec
