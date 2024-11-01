set rtp+=~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
set rtp+=../plenary.nvim

if !has("nvim-0.10.0")
    set rtp+=~/.local/share/nvim/site/pack/vendor/start/mini.nvim
    set rtp+=../mini.nvim
endif

runtime! plugin/plenary.vim
