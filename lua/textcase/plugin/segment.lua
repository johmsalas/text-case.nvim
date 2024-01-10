local M = {}

-- Function to find segments similar to Vim's 'w' but with camelCase support
M.find_segments = function(line)
  local segments = {}
  local start = 1
  local is_upper = function(char)
    return char:match("%u")
  end
  local is_word_char = function(char)
    return char:match("[%w_]")
  end

  for i = 1, #line do
    local char = line:sub(i, i)
    local next_char = line:sub(i + 1, i + 1)

    -- Start a new segment on word boundaries and camelCase transitions
    if
      (is_upper(next_char) and not is_upper(char) and is_word_char(char))
      or (not is_word_char(char) and is_word_char(next_char))
    then
      table.insert(segments, { start = start, finish = i })
      start = i + 1
    end
  end

  -- Add the last segment
  if start <= #line then
    table.insert(segments, { start = start, finish = #line })
  end

  return segments
end

M.jump_to_next_segment = function()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line_num = cursor_pos[1]
  local col = cursor_pos[2] + 1
  local total_lines = vim.api.nvim_buf_line_count(0)

  local found_next_segment = false

  while current_line_num <= total_lines and not found_next_segment do
    local line = vim.api.nvim_buf_get_lines(0, current_line_num - 1, current_line_num, false)[1]
    local segments = M.find_segments(line)

    for _, segment in ipairs(segments) do
      if current_line_num == cursor_pos[1] and segment.start <= col then
        -- Skip segments before the cursor on the current line
      else
        vim.api.nvim_win_set_cursor(0, { current_line_num, segment.start - 1 })
        found_next_segment = true
        break
      end
    end

    current_line_num = current_line_num + 1
  end

  if not found_next_segment then
    -- If no next segment found, stay at the current position
    vim.api.nvim_win_set_cursor(0, { current_line_num - 1, col - 1 })
  end
end

-- Function to jump to the previous camelCase segment
M.jump_to_previous_segment = function()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor_pos[1]
  local col = cursor_pos[2] + 1
  local line = vim.api.nvim_buf_get_lines(0, current_line - 1, current_line, false)[1]
  local segments = M.find_segments(line)

  -- Adjust to include the first segment if it starts with lowercase
  if #segments > 0 and segments[1].start >= 2 then
    table.insert(segments, 1, { start = 1, finish = segments[1].start - 1 })
  end

  local previousSegment = nil
  for i = #segments, 1, -1 do
    if segments[i].finish < col then
      previousSegment = segments[i]
      break
    end
  end

  if previousSegment then
    vim.api.nvim_win_set_cursor(0, { current_line, previousSegment.start - 1 })
  else
    -- Jump to the last segment of the previous line if there is one
    if current_line > 1 then
      line = vim.api.nvim_buf_get_lines(0, current_line - 1, current_line, false)[1]
      vim.api.nvim_win_set_cursor(0, { current_line - 1, 0 })
      local prev_line_segments = M.find_segments(line)
      if #prev_line_segments > 0 then
        local last_segment = prev_line_segments[#prev_line_segments]
        vim.api.nvim_win_set_cursor(0, { current_line - 1, last_segment.start - 1 })
      end
    else
      -- If no previous segment or line, stay at the current position
      vim.api.nvim_win_set_cursor(0, { current_line, col - 1 })
    end
  end
end

function M.select_nth_camelcase_segment(_)
  vim.api.nvim_command("normal v")
  M.jump_to_next_segment()
end

return M
