local M = {}

function M.root(root)
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h:h") .. "/" .. (root or "")
end

function M.init()
  vim.cmd([[set runtimepath=$VIMRUNTIME]])
  vim.opt.runtimepath:append(M.root())
  vim.opt.swapfile = false

  -- This require needs to come after the runtimepath is set
  local feature_flags = require("feature_flags")

  if feature_flags.is_feature_available("telescope") then
    vim.opt.packpath = {
      M.root(".tests/telescope/site"),
      M.root("tests"),
    }

    vim.cmd([[
    packadd plenary.nvim
    packadd telescope.nvim
    runtime plugin/start.vim
  ]])
  else
    -- If the feature is not available, we still need to load plenary and the plugin
    -- to run the tests. In the actual test file, we will check if the feature is available
    -- and return early if it is not.
    vim.opt.packpath = { M.root(".tests/minimal/site") }
    vim.cmd([[
      packadd plenary.nvim
      runtime plugin/start.vim
    ]])
  end
end

M.init()
