local M = {}

function M.root(root)
  local f = debug.getinfo(1, "S").source:sub(3)
  return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (root or "")
end

function M.setup(root_env)
  vim.cmd([[set runtimepath=$VIMRUNTIME]])
  vim.opt.runtimepath:append(M.root())
  vim.opt.packpath = { M.root(root_env) }
end

function M.init()
  -- TODO: Call setup method from the utils file
  M.setup(".tests/telescope")
end

M.init()
