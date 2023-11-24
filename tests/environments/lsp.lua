local M = {}

function M.root(root)
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h:h") .. "/" .. (root or "")
end

function M.init()
  vim.cmd([[set runtimepath=$VIMRUNTIME]])
  vim.opt.runtimepath:append(M.root())
  vim.opt.swapfile = false
  vim.opt.packpath = {
    M.root(".tests/lsp/site"),
    M.root("tests"),
  }
  vim.cmd([[
    packadd plenary.nvim
    packadd lspconfig.nvim
    runtime plugin/start.vim
  ]])

  require("lspconfig").tsserver.setup({})
end

M.init()
