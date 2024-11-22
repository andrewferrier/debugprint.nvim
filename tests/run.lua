vim.opt.runtimepath:append(
    "~/.local/share/nvim/site/pack/vendor/start/plenary.nvim"
)
vim.opt.runtimepath:append("../plenary.nvim")

if vim.fn.has("nvim-0.10.0") ~= 1 then
    vim.opt.runtimepath:append(
        "~/.local/share/nvim/site/pack/vendor/start/mini.nvim"
    )
    vim.opt.runtimepath:append("../mini.nvim")
end

require("plenary.test_harness").test_file("tests/debugprint.lua")
