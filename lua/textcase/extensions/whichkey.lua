local M = {}

function M.register_prefix(mode, prefix, name)
  local ok, whichkey = pcall(require, "which-key")
  if ok then
    if whichkey.add then
      -- whichkey.register() is deprecated in favor of whichkey.add()
      whichkey.add({
        prefix,
        group = name,
        mode = mode,
        buffer = nil,
        silent = true,
        noremap = true,
        nowait = true,
      })
    else
      -- fallback to whichkey.register() if whichkey.add() is unavailable
      whichkey.register({ [prefix] = { name = name } }, {
        mode = mode,
        buffer = nil,
        silent = true,
        noremap = true,
        nowait = true,
      })
    end
  end
end

return M
