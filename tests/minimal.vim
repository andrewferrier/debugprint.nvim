set hidden
set noswapfile

set rtp+=~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
set rtp+=~/.local/share/nvim/site/pack/vendor/start/nvim-treesitter

set rtp+=../plenary.nvim
set rtp+=../nvim-treesitter

set rtp+=.

runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter.lua

TSInstallSync! lua
