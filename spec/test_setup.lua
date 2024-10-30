vim.o.hidden = true
vim.o.swapfile = false

vim.cmd("source spec/minimal.vim")

-- These must be prepended because of this:
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/3092#issue-1288690088
vim.opt.runtimepath:prepend(
    "~/.local/share/nvim/site/pack/vendor/start/nvim-treesitter"
)
vim.opt.runtimepath:prepend("../nvim-treesitter")

if vim.fn.has("nvim-0.10.0") == 0 then
    vim.opt.runtimepath:prepend(
        "~/.local/share/nvim/site/pack/vendor/start/mini.nvim"
    )
    vim.opt.runtimepath:prepend("../mini.nvim")
end

vim.cmd("runtime! plugin/nvim-treesitter.lua")

local install_parser_if_needed = function(filetype)
    if vim.tbl_contains(vim.tbl_keys(vim.fn.environ()), "GITHUB_WORKFLOW") then
        print("Running in GitHub; installing parser " .. filetype .. "...")
        vim.cmd("TSInstallSync! " .. filetype)
    else
        vim.cmd("new")
        vim.cmd("only")
        local ok, _ = pcall(vim.treesitter.get_parser, 0, filetype, {})
        if not ok then
            print("Cannot load parser for " .. filetype .. ", installing...")
            vim.cmd("TSInstallSync! " .. filetype)
        end
    end
end

install_parser_if_needed("bash")
install_parser_if_needed("html")
install_parser_if_needed("javascript")
install_parser_if_needed("lua")
install_parser_if_needed("markdown")
install_parser_if_needed("markdown_inline")
install_parser_if_needed("php")
install_parser_if_needed("python")
