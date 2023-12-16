local M = {}

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

M.wait_for = function(max_milliseconds, callback)
  local step = 100
  local curr_milliseconds = 0
  local task_finished = false
  while curr_milliseconds < max_milliseconds and not task_finished do
    task_finished = callback()
    vim.wait(step, function() end)
    curr_milliseconds = curr_milliseconds + step
  end
end

-- Allow Typescript language server to start.
-- Even though the language server is attached, it doesn't mean it is ready
-- to receive requests. Hence, we send a request and wait for response.
-- Then we know the language server is ready.
M.wait_for_language_server_to_start = function()
  M.execute_keys("ww") -- Move to `doSomething`
  local hover = ""
  M.wait_for(30 * 1000, function()
    -- This prints one "Error detected while processing command line:" but this can be ignored
    vim.lsp.buf_request_all(0, "textDocument/hover", vim.lsp.util.make_position_params(), function(results)
      -- Hover will print the type definition of the variable under the cursor. Hence,
      -- it should contain "doSomething".
      hover = results[1].result and results[1].result.contents.value
    end)
    return string.find(hover, "doSomething")
  end)
end

-- This method duplicates wait_for_language_server_to_start for
-- the destructuring file. Using Write Everything Twice and
-- avoiding to come up with a wrong abstraction too early
M.wait_for_language_server_to_start_on_destructuring_file = function()
  M.execute_keys("ww") -- Move to `foovar`
  local hover = ""
  M.wait_for(30 * 1000, function()
    -- This prints one "Error detected while processing command line:" but this can be ignored
    vim.lsp.buf_request_all(0, "textDocument/hover", vim.lsp.util.make_position_params(), function(results)
      -- Hover will print the type definition of the variable under the cursor. Hence,
      -- it should contain "fooVar".
      hover = results[1].result.contents.value
    end)
    return string.find(hover, "fooVar")
  end)
end

return M
