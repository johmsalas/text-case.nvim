local M = {}

function M.register(mode, mappings)
  local opts = {
    n = {
      mode = "n",
      buffer = nil,
      silent = true,
      noremap = true,
      nowait = true,
    },
    v = {
      mode = "v",
      buffer = nil,
      silent = true,
      noremap = true,
      nowait = true,
    },
  }

  local ok, whichkey = pcall(require, "which-key")
  if ok then
    whichkey.register(mappings, opts[mode])
  end
end

return M
