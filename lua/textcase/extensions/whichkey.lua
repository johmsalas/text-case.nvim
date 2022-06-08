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
    }
  }

  pcall(
    require("which-key").register,
    mappings,
    opts[mode]
  )
end

return M
