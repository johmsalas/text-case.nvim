#!/bin/sh

GITHUB="https://github.com"
GITHUB_PLENARY="$GITHUB/nvim-lua/plenary.nvim"
GITHUB_TELESCOPE="$GITHUB/nvim-telescope/telescope.nvim"
GITHUB_WHICHKEY="$GITHUB/nvim-telescope/folke/which-key.nvim"

SCRIPT_FILE=$(readlink -f "${BASH_SOURCE[0]}")
REPO_DIR=$(dirname "$(dirname "$script_file")")

TEST_MINIMAL_DIR="$REPO_DIR/.tests/minimal/site/pack/deps/start"
TEST_TELESCOPE_DIR="$REPO_DIR/.tests/telescope/site/pack/deps/start"
TEST_LSP_DIR="$REPO_DIR/.tests/lsp/site/pack/deps/start"
TEST_WHICHKEY_DIR="$REPO_DIR/.tests/whichkey/site/pack/deps/start"

# The Tests Runner runs tests for all the environments
# TODO: Support running subset of tests

clone() {
  repo=$1
  dest=$2
  if [ ! -d "$dest" ] ; then
    git clone --depth 1 "$repo" "$dest"
  else
    echo "$1 already cloned"
  fi
}

mkdir -p $TEST_MINIMAL_DIR
clone $GITHUB_PLENARY "$TEST_MINIMAL_DIR/plenary.nvim"
nvim --headless -u tests/environments/minimal.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/environments/minimal.lua', sequential = true}"

# mkdir -p $TEST_LSP_DIR
# git clone --depth 1 $GITHUB_PLENARY "$TEST_LSP_DIR/plenary.nvim"
# nvim --headless -u tests/environments/lsp.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/environments/lsp.lua', sequential = true}"
#
# # TODO: Skip if github version is lower than the version required by Telescope
# mkdir -p $TEST_TELESCOPE_DIR
# git clone --depth 1 $GITHUB_PLENARY "$TEST_TELESCOPE_DIR/plenary.nvim"
# git clone --depth 1 $GITHUB_TELESCOPE "$TEST_TELESCOPE_DIR/telescope.nvim"
# nvim --headless -u tests/environments/telescope.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/environments/telescope.lua', sequential = true}"
#
# mkdir -p $TEST_WHICHKEY_DIR
# git clone --depth 1 $GITHUB_PLENARY "$TEST_TELESCOPE_DIR/plenary.nvim"
# git clone --depth 1 $GITHUB_WHICHKEY "$TEST_WHICHKEY_DIR/whichkey.nvim"
# nvim --headless -u tests/environments/which-key.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/environments/which-key.lua', sequential = true}"
