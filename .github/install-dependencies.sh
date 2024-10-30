#! /bin/sh
set -x # enable debugging to see the executed commands

git clone --depth 1 \
    https://github.com/nvim-lua/plenary.nvim \
    ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim

git clone --depth 1 \
    https://github.com/nvim-treesitter/nvim-treesitter \
    ~/.local/share/nvim/site/pack/vendor/start/nvim-treesitter

git clone --depth 1 \
    https://github.com/echasnovski/mini.nvim \
    ~/.local/share/nvim/site/pack/vendor/start/mini.nvim
