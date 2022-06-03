local M = {}

M.plugin_name = 'textcase.nvim'
M.namespace = 'textcase'

M.change_type = {
  LSP_RENAME = 'LSP_RENAME',
  CURRENT_WORD = 'CURRENT_WORD',
}

return M
