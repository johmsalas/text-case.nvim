#!/bin/bash
set -e

GITHUB="https://github.com"
GITHUB_PLENARY="$GITHUB/nvim-lua/plenary.nvim"
GITHUB_TELESCOPE="$GITHUB/nvim-telescope/telescope.nvim"
GITHUB_LSPCONFIG="$GITHUB/neovim/nvim-lspconfig"
GITHUB_WHICHKEY="$GITHUB/nvim-telescope/folke/which-key.nvim"

SCRIPT_FILE=$(readlink -f "${BASH_SOURCE[0]}")
REPO_DIR=$(dirname "$(dirname "$SCRIPT_FILE")")

TEST_MINIMAL_DIR="$REPO_DIR/.tests/minimal/site/pack/deps/start"
TEST_TELESCOPE_DIR="$REPO_DIR/.tests/telescope/site/pack/deps/start"
TEST_LSP_DIR="$REPO_DIR/.tests/lsp/site/pack/deps/start"
TEST_ALL_DIR="$REPO_DIR/.tests/all/site/pack/deps/start"

# The Tests Runner runs tests for all the environments
# TODO: Support running subset of tests

clone() {
	repo=$1
	dest=$2
	if [ ! -d "$dest" ]; then
		git clone --depth 1 "$repo" "$dest"
	else
		echo "$1 already cloned"
	fi
}

create_symlink() {
	src=$1
	dest=$2
	if [ ! -d "$dest" ]; then
		ln -s "$src" "$dest"
	else
		echo "$2 already exists"
	fi
}

mkdir -p $TEST_ALL_DIR
clone $GITHUB_PLENARY "$TEST_ALL_DIR/plenary.nvim"
clone $GITHUB_TELESCOPE "$TEST_ALL_DIR/telescope.nvim"
clone $GITHUB_LSPCONFIG "$TEST_ALL_DIR/lspconfig.nvim"

mkdir -p $TEST_MINIMAL_DIR
create_symlink "$TEST_ALL_DIR/plenary.nvim" "$TEST_MINIMAL_DIR/plenary.nvim"
nvim --headless -u tests/environments/minimal.lua -c "PlenaryBustedDirectory tests/textcase/conversions {minimal_init = 'tests/environments/minimal.lua', sequential = true}"
nvim --headless -u tests/environments/minimal.lua -c "PlenaryBustedDirectory tests/textcase/plugin {minimal_init = 'tests/environments/minimal.lua', sequential = true}"

mkdir -p $TEST_LSP_DIR
create_symlink "$TEST_ALL_DIR/plenary.nvim" "$TEST_LSP_DIR/plenary.nvim"
create_symlink "$TEST_ALL_DIR/lspconfig.nvim" "$TEST_LSP_DIR/lspconfig.nvim"
nvim --headless -u tests/environments/lsp.lua -c "PlenaryBustedDirectory tests/textcase/lsp {minimal_init = 'tests/environments/lsp.lua', sequential = true}"

mkdir -p $TEST_TELESCOPE_DIR
create_symlink "$TEST_ALL_DIR/plenary.nvim" "$TEST_TELESCOPE_DIR/plenary.nvim"
create_symlink "$TEST_ALL_DIR/telescope.nvim" "$TEST_TELESCOPE_DIR/telescope.nvim"
nvim --headless -u tests/environments/telescope.lua -c "PlenaryBustedDirectory tests/textcase/telescope/telescope_spec.lua {minimal_init = 'tests/environments/telescope.lua', sequential = true}"

# "all" is run at the end because it uses other environments as fallbacks
nvim --headless -u tests/environments/all.lua -c "PlenaryBustedDirectory tests/textcase/all/ {minimal_init = 'tests/environments/all.lua', sequential = true}"
