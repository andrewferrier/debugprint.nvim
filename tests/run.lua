vim.opt.runtimepath:append(
    "~/.local/share/nvim/site/pack/vendor/start/plenary.nvim"
)
vim.opt.runtimepath:append("../plenary.nvim")

require("plenary.test_harness").test_file("tests/debugprint.lua")
