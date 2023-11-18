#!/bin/sh

# The Tests Runner runs tests for all the environments

mkdir -p ~/.local/share/nvim/site/pack/vendor/start
git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
git clone --depth 1 https://github.com/nvim-telescope/telescope.nvim ~/.local/share/nvim/site/pack/vendor/start/telescope.nvim

nvim --headless -u tests/environments/minimal.vim -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/environments/minimal.vim', sequential = true}"

nvim --headless -u tests/environments/lsp.vim -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/environments/lsp.vim', sequential = true}"

nvim --headless -u tests/environments/telescope.vim -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/environments/telescope.vim', sequential = true}"
