set hidden
set noswapfile

set rtp+=../plenary.nvim
set rtp+=../debugprint.nvim
set rtp+=../nvim-treesitter

runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter.lua

TSInstallSync! lua
