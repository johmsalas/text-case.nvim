local M = {}

M.plugin_name = "textcase.nvim"
M.namespace = "textcase"

M.change_type = {
  LSP_RENAME = "LSP_RENAME",
  CURRENT_WORD = "CURRENT_WORD",
  QUICK_REPLACE = "QUICK_REPLACE",
  VISUAL = "VISUAL",
}

M.visual_mode = {
  NONE = "NONE",
  INLINE = "INLINE",
  LINE = "LINE",
  BLOCK = "BLOCK",
}

return M
