local utils = {}
local constants = require("textcase.shared.constants")

function utils.get_mode_at_operator(vmode)
  local visual_mode = nil
  if vmode == "v" then
    visual_mode = constants.visual_mode.INLINE
  elseif vmode == "V" then
    visual_mode = constants.visual_mode.LINE
  elseif vmode == "block" then
    visual_mode = constants.visual_mode.BLOCK
  end

  return visual_mode
end

function Get_visual_mode(forced_mode)
  local mode = forced_mode or vim.api.nvim_get_mode().mode

  if mode == "v" then
    return constants.visual_mode.INLINE
  elseif mode == "V" then
    return constants.visual_mode.LINE
  elseif mode == "\22" then
    return constants.visual_mode.BLOCK
  end

  return constants.visual_mode.NONE
end

function utils.get_visual_region(buffer, updated, forced_mode, detected_mode)
  buffer = buffer or 0
  local sln, eln, visual_mode

  if updated and not forced_mode then
    local spos = vim.fn.getpos("v")
    local epos = vim.fn.getpos(".")
    sln = { spos[2], spos[3] - 1 }
    eln = { epos[2], epos[3] - 1 }

    visual_mode = detected_mode
      or utils.is_same_position(spos, epos) and constants.visual_mode.NONE
      or Get_visual_mode(forced_mode)
  else
    visual_mode = detected_mode or Get_visual_mode(forced_mode)

    if visual_mode == constants.visual_mode.INLINE then
      sln = vim.api.nvim_buf_get_mark(buffer or 0, "<")
      eln = vim.api.nvim_buf_get_mark(buffer or 0, ">")
    elseif visual_mode == constants.visual_mode.LINE then
      sln = vim.api.nvim_buf_get_mark(buffer or 0, "<")
      eln = vim.api.nvim_buf_get_mark(buffer or 0, ">")
    elseif forced_mode then
      sln = vim.api.nvim_buf_get_mark(buffer or 0, "<")
      eln = vim.api.nvim_buf_get_mark(buffer or 0, ">")
    else
      sln = vim.api.nvim_buf_get_mark(buffer or 0, "[")
      eln = vim.api.nvim_buf_get_mark(buffer or 0, "]")
    end
  end

  if visual_mode == constants.visual_mode.LINE then
    sln = { sln[1], 0 }
    eln = { eln[1], vim.fn.getline(eln[1]):len() - 1 }
  end

  -- Make sure we we change start and end if end is higher than start.
  -- This happens when we select from bottom to top or from right to left.
  local start_row = math.min(sln[1], eln[1])
  local start_col = math.min(sln[2] + 1, eln[2] + 1)
  local end_row = math.max(sln[1], eln[1])
  local end_col_1 = math.min(sln[2], vim.fn.getline(sln[1]):len()) + 1
  local end_col_2 = math.min(eln[2], vim.fn.getline(eln[1]):len()) + 1
  local end_col = math.max(end_col_1, end_col_2)

  local region = {
    mode = visual_mode,
    start_row = start_row,
    start_col = start_col,
    end_row = end_row,
    end_col = end_col,
  }

  return region
end

function utils.set_visual_region(visual_mode, buffer)
  local sln = { visual_mode.start_row, visual_mode.start_col - 1 }
  local eln = { visual_mode.end_row, visual_mode.end_col - 1 }

  local start_reg = "<"
  local end_reg = ">"
  if visual_mode.mode == constants.visual_mode.BLOCK then
    start_reg = "["
    end_reg = "]"
  end

  vim.api.nvim_buf_set_mark(buffer or 0, start_reg, sln[1], sln[2], {})
  vim.api.nvim_buf_set_mark(buffer or 0, end_reg, eln[1], eln[2], {})
end

function utils.nvim_buf_get_text(buffer, start_row, start_col, end_row, end_col)
  local lines = vim.api.nvim_buf_get_lines(buffer, start_row, end_row + 1, false)

  lines[vim.tbl_count(lines)] = string.sub(lines[vim.tbl_count(lines)], 0, end_col)
  lines[1] = string.sub(lines[1], start_col + 1)

  return lines
end

local callableTable = {
  __call = function(self, ...)
    return self.apply(...)
  end,
}

function utils.create_wrapped_method(method_name, method, desc)
  local wrapper = {
    desc = desc,
    apply = method,
    method_name = method_name,
  }
  setmetatable(wrapper, callableTable)
  return wrapper
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
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

function utils.map(tbl, f)
  local t = {}

  for k, v in pairs(tbl) do
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
  if pos == nil then
    return true
  end
  return pos[1] == 0 and pos[2] == 0
end

function utils.is_cursor_in_range(point, region)
  if region.mode == constants.visual_mode.NONE then
    return true
  end

  if region.mode == constants.visual_mode.INLINE or region.vmode == constants.visual_mode.LINE then
    local is_between_lines = point[1] > region.start_row and point[1] < region.end_row
    local is_same_start_line_after = point[1] == region.start_row and point[2] >= region.start_col
    local is_same_end_line_before = point[1] == region.end_row and point[2] <= region.end_col

    return is_between_lines or is_same_start_line_after or is_same_end_line_before
  end

  if region.mode == constants.visual_mode.BLOCK then
    local is_inside_square = point[1] >= region.start_row
      and point[1] <= region.end_row
      and point[2] >= region.start_col
      and point[2] <= region.end_col

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
  local trimmable_chars = _trimmable_chars or { " ", "'", '"', "{", "}", "," }
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

  local trimmed_str = string.sub(str, startCount + 1, #chars - endCount) or ""

  return trim_info, trimmed_str
end

-- Gets the position and text of the current word under the cursor
-- If the cursor is located on a word it returns information about that word
-- If the cursor is not on a word, it returns information about the next word
-- The method could have some validation when there is no word to be returned
--   not required at the moment
-- One of the cases where this method is useful is on LSP rename,
--   If there cursor is not on a word, TextDocument/rename acts on the previous
--   word, while vim.fn.expand returns information about the following word
--   By using this method the plugin has a way of referring to the same word
function utils.get_current_word_info()
  local cursor_pos = vim.fn.getpos(".")
  -- This could be customized to read exactly the word under the cursor, ignoring
  -- close words, or even considering words before the cursor. Consult values like Wn and Wb
  local start_the_search_at_cursor_position = "W"
  local word = "\\w"
  local current_word_pos = vim.fn.searchpos(word, start_the_search_at_cursor_position)
  vim.fn.setpos(".", cursor_pos)

  local line = current_word_pos[1] - 1
  local character = current_word_pos[2]

  local position = { line = line, character = character }

  return { position = position, word = vim.fn.expand("<cword>") }
end

function utils.get_list(str, mode)
  -- Assuming forward lookup, if Foo is modified to BarFoo, the cursor will remain in Bar,
  -- using searchpos, the next occurrence of Foo will be the second part of BarFoo which was
  -- already modified, entering an infinite loop, that will result into: BarBarBarBar...BarFoo
  --
  -- for that reason, search should be executed backwards to avoid including an edited match.

  -- TODO: Optimize replacement to run only in a selected region, currently it is running in the whole buffer
  local search_options = "b"
  local limit = 0
  local initial = nil
  local next = vim.fn.searchpos(str, search_options)

  local region = utils.get_visual_region(nil, true, mode)

  while initial == nil or (not utils.is_empty_position(next) and not utils.is_same_position(next, initial)) do
    if not utils.is_empty_position(next) then
      limit = 1 + limit
      if initial == nil then
        initial = { next[1], next[2] }
      end
    end
    next = vim.fn.searchpos(str, search_options)

    if initial == nil then
      initial = false
    end
  end

  local first_call = true

  return function()
    limit = limit - 1
    next = vim.fn.searchpos(str, search_options)

    if utils.is_empty_position(next) then
      return nil
    end

    if first_call then
      first_call = false
      initial = next
      if utils.is_cursor_in_range(initial, region) then
        return initial
      end
    end

    while not utils.is_cursor_in_range(next, region) do
      limit = limit - 1
      next = vim.fn.searchpos(str, search_options)
      if utils.is_empty_position(next) then
        return nil
      end

      if limit < 0 then
        return nil
      end
    end

    if limit < 0 then
      return nil
    end
    if utils.is_same_position(initial, next) then
      return nil
    end

    return next
  end
end

return utils
