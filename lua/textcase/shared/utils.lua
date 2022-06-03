local utils = {}

function utils.get_region(vmode)
  local sln, eln
  if vmode:match("[vV]") then
    sln = vim.api.nvim_buf_get_mark(0, "<")
    eln = vim.api.nvim_buf_get_mark(0, ">")
  else
    sln = vim.api.nvim_buf_get_mark(0, "[")
    eln = vim.api.nvim_buf_get_mark(0, "]")
  end

  return {
    start_row = sln[1],
    start_col = sln[2],
    end_row = eln[1],
    end_col = math.min(eln[2], vim.fn.getline(eln[1]):len() - 1),
  }
end

function utils.nvim_buf_get_text(buffer, start_row, start_col, end_row, end_col)
  local lines = vim.api.nvim_buf_get_lines(buffer, start_row, end_row + 1, true)

  lines[vim.tbl_count(lines)] = string.sub(lines[vim.tbl_count(lines)], 0, end_col)
  lines[1] = string.sub(lines[1], start_col + 1)

  return lines
end

function utils.create_wrapped_method(desc, method)
  return {
    desc = desc,
    apply = method
  }
end

function utils.get_default_register()
  local clipboardFlags = vim.split(vim.api.nvim_get_option("clipboard"), ",")

  if vim.tbl_contains(clipboardFlags, "unnamedplus") then
    return "+"
  end

  if vim.tbl_contains(clipboardFlags, "unnamed") then
    return "*"
  end

  return '"'
end

function utils.tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function utils.map(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

function utils.escape_string(str)
  local output = str
  output = output:gsub("%.", "\\.")
  return output
end

function utils.is_same_position(a, b)
  return a[1] == b[1] and a[2] == b[2]
end

function utils.is_empty_position(pos)
  if (pos == nil) then return true end
  return pos[1] == 0 and pos[2] == 0
end

function utils.is_cursor_in_range(point, start_point, end_point)
  if utils.is_empty_position(start_point) or utils.is_empty_position(end_point) then return true end
  local mode = vim.fn.visualmode()

  if mode == 'v' then
    local is_between_lines = point[1] > start_point[1] and point[1] < end_point[1]
    local is_same_start_line_after = point[1] == start_point[1] and point[2] >= start_point[2]
    local is_same_end_line_before = point[1] == end_point[1] and point[2] <= end_point[2]

    return is_between_lines or is_same_start_line_after or is_same_end_line_before
  end

  if mode == "\22" then
    local is_inside_square = point[1] >= start_point[1] and point[1] <= end_point[1]
      and point[2] >= start_point[2] and point[2] <= end_point[2]

    return is_inside_square
  end
end

function utils.untrim_str(str, trim_info)
  return trim_info.start_trim .. str .. trim_info.end_trim
end

function utils.trim_str(str, _trimmable_chars)
  local chars = vim.split(str, "")
  local startCount = 0
  local endCount = 0
  local trimmable_chars = _trimmable_chars or { ' ', '\'', '"', '{', '}', ',' }
  local trimmable_chars_by_char = {}

  for i = 1, #trimmable_chars, 1 do
    local trim_char = trimmable_chars[i]
    trimmable_chars_by_char[trim_char] = trim_char
  end

  local isTrimmable = function(char)
    return trimmable_chars_by_char[char]
  end

  for i = 1, #chars, 1 do
    local char = chars[i]
    if isTrimmable(char) then
      startCount = startCount + 1
    else
      break
    end
  end

  for i = #str, startCount + 1, -1 do
    local char = chars[i]
    if isTrimmable(char) then
      endCount = endCount + 1
    else
      break
    end
  end

  local trim_info = {
    start_trim = string.sub(str, 1, startCount),
    end_trim = string.sub(str, #chars - endCount + 1),
  }

  local trimmed_str = string.sub(
    str,
    startCount + 1,
    #chars - endCount
  ) or ''

  return trim_info, trimmed_str
end

function utils.get_list(str)
  local limit = 0
  local initial = nil
  local next = vim.fn.searchpos(str)
  local selection_start = vim.api.nvim_buf_get_mark(0, "<")
  local selection_end = vim.api.nvim_buf_get_mark(0, ">")

  while
    initial == nil or (
      not utils.is_empty_position(next)
      and not utils.is_same_position(next, initial)
    )
  do
    if not utils.is_empty_position(next) then
      limit = 1 + limit
      if initial == nil then
        initial = {next[1], next[2]}
      end
    end
    next = vim.fn.searchpos(str)

    if initial == nil then initial = false end
  end

  local first_call = true

  return function()
    limit = limit - 1
    next = vim.fn.searchpos(str)
    if utils.is_empty_position(next) then return nil end
    if first_call then
      first_call = false
      if utils.is_cursor_in_range(initial, selection_start, selection_end) then return initial end
    end

    while
      not utils.is_cursor_in_range(next, selection_start, selection_end)
    do
      limit = limit - 1
      next = vim.fn.searchpos(str)
      if utils.is_empty_position(next) then return nil end

      if limit < 0 then return nil end
    end

    if limit < 0 then return nil end
    if utils.is_same_position(initial, next) then return nil end

    return next
  end
end

return utils

