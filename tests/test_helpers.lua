M = {}

M.get_buf_lines = function()
  local result = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  return result
end

M.execute_keys = function(feedkeys, mode)
  local keys = vim.api.nvim_replace_termcodes(feedkeys, true, false, true)
  vim.api.nvim_feedkeys(keys, mode or "x", false)
end

---@param path string
M.read_file = function(path)
  local fd = vim.loop.fs_open(path, "r", 438)
  local fstat = vim.loop.fs_fstat(fd)
  local contents = vim.loop.fs_read(fd, fstat.size, 0)
  vim.loop.fs_close(fd)
  return contents
end

M.wait_for = function(max_seconds, callback)
  local curr_seconds = 0
  local task_finished = false
  while curr_seconds < max_seconds and not task_finished do
    curr_seconds = curr_seconds + 0.1
    task_finished = callback()
    vim.wait(100, function() end)
  end
end

return M
