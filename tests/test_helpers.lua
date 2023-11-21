M = {}

M.get_buf_lines = function()
  local result = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  return result
end

M.execute_keys = function(feedkeys, mode)
  local keys = vim.api.nvim_replace_termcodes(feedkeys, true, false, true)
  vim.api.nvim_feedkeys(keys, mode or "x", false)
end

return M
