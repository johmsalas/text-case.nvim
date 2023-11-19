local M = {}

function M.setup(root_env)
  vim.cmd([[set runtimepath=$VIMRUNTIME]])
  vim.opt.runtimepath:append(M.root())
  vim.opt.packpath = { M.root(root_env) }
end

return M
