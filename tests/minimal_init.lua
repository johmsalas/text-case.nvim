-- This init file is just for testing with [neotest](https://github.com/nvim-neotest/neotest)
--
-- The normal init files are inside tests/environemnts/*.lua
-- However, Neotest by default looks at tests/minimal_init.lua
--
-- In order to run all tests with Neotest, we need to have a minimal init file that includes
-- all possible configurations (Telescope, LSP, etc), hence this file.

local M = {}

function M.root(root)
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (root or "")
end

function M.init()
  vim.cmd([[set runtimepath=$VIMRUNTIME]])
  vim.opt.runtimepath:append(M.root())
  vim.opt.swapfile = false

  -- This require needs to come after the runtimepath is set
  local feature_flags = require("feature_flags")

  vim.opt.packpath = {
    M.root(".tests/all/site"),
    M.root("tests"),
  }

  if feature_flags.is_feature_available("telescope") then
    vim.cmd([[
      packadd plenary.nvim
      packadd telescope.nvim
      packadd lspconfig.nvim
      runtime plugin/start.vim
    ]])
  else
    vim.cmd([[
      packadd plenary.nvim
      packadd lspconfig.nvim
      runtime plugin/start.vim
    ]])
  end

  require("lspconfig").tsserver.setup({})
end

-- Ensure the required Neovim plugins are installed/cloned
os.execute(M.root("tests/install.sh"))

M.init()
