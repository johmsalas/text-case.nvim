local M = {}

function M.root(root)
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h:h") .. "/" .. (root or "")
end

-- TODO: Call setup method from the utils file
function M.setup(root_env)
  vim.cmd([[set runtimepath=$VIMRUNTIME]])
  vim.opt.runtimepath:append(M.root())
  vim.opt.packpath = { M.root(root_env) }
end

function M.init()
  M.setup(".tests/minimal")
end

M.init()
