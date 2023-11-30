local utils = require("textcase.shared.utils")

local M = {}

-- This function takes a string and applies a keybinding to it. This is done by
-- creating a temporary buffer and open this buffer in a temporary window. There is no
-- other way to apply a keybinding to a string.
local function apply_keybinding_to_string(str, keybinding)
  -- Create a temporary buffer and open a window. A window is needed to apply the keybinding.
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" .. str })
  local win = vim.api.nvim_open_win(buf, true, { relative = "editor", width = 80, height = 20, row = 10, col = 10 })

  -- Apply the keybinding
  -- The <ESC> is needed for Telescope to work
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "x", false)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keybinding, true, false, true), "x", false)

  local modified_str = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  vim.api.nvim_win_close(win, true)
  vim.api.nvim_buf_delete(buf, { force = true })

  return table.concat(modified_str, "\n")
end

-- "some-string":upper() does not handle unicode characters like á => Á
-- while "gU" does. This function is a workaround for that.
local function vim_string_to_upper(str)
  return apply_keybinding_to_string(str, "VgU")
end

-- See vim_string_to_upper
local function vim_string_to_lower(str)
  return apply_keybinding_to_string(str, "Vgu")
end

local is_special = function(char)
  local b = char:byte(1)
  return b <= 0x2F or (b >= 0x3A and b <= 0x3F) or (b >= 0x5B and b <= 0x60) or (b >= 0x7B and b <= 0x7F)
end

-- Check the bytes of a char for upper case characters. We only consider chars
-- with one or two bytes.
--
-- For list of bytes in decimal see
-- https://www.utf8-chartable.de/unicode-utf8-table.pl?names=-&utf8=dec
local is_upper = function(char)
  local bytes = { char:byte(1, -1) }

  local single_byte_upper = #bytes == 1 and (bytes[1] >= 0x41 and bytes[1] <= 0x5A)
  local dual_byte_upper = #bytes == 2
    and (bytes[1] >= 0xC0 and bytes[1] <= 0xC5)
    and (bytes[2] >= 0x80 and bytes[2] <= 0x9D)

  return single_byte_upper or dual_byte_upper
end

local function split_string_into_chars(str)
  local chars = {}
  for uchar in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
    table.insert(chars, uchar)
  end
  return chars
end

local toTitle = function(str)
  local chars = split_string_into_chars(str)
  local first_char = chars[1]
  local rest_char = { unpack(chars, 2) }
  local rest_str = table.concat(rest_char, "")
  return vim_string_to_upper(first_char) .. vim_string_to_lower(rest_str)
end

function M.to_parts(str)
  local has_lower = str:find("[a-z]") ~= nil

  local parts = {}
  local new_part = true
  for _, char in ipairs(split_string_into_chars(str)) do
    if is_special(char) then
      new_part = true
    else
      if is_upper(char) and has_lower then
        new_part = true
      end

      if new_part then
        table.insert(parts, "")
        new_part = false
      end

      parts[#parts] = parts[#parts] .. char
    end
  end

  return parts
end

function M.to_pascal_case(str)
  local parts = vim.split(M.to_dash_case(str), "-")
  return table.concat(utils.map(parts, toTitle), "")
end

function M.to_camel_case(str)
  local parts = vim.split(M.to_dash_case(str), "-")
  if #parts == 1 then
    return vim_string_to_lower(parts[1])
  end
  if #parts > 1 then
    return vim_string_to_lower(parts[1]) .. table.concat(utils.map({ unpack(parts, 2) }, toTitle), "")
  end

  return ""
end

function M.to_upper_phrase_case(str)
  return vim_string_to_upper(M.to_dash_case(str)):gsub("-", " ")
end

function M.to_lower_phrase_case(str)
  return vim_string_to_lower(M.to_dash_case(str)):gsub("-", " ")
end

function M.to_phrase_case(str)
  local lower = vim_string_to_lower(M.to_dash_case(str))
  lower = lower:gsub("-", " ")
  return vim_string_to_upper(lower:sub(1, 1)) .. lower:sub(2, #lower)
end

function M.to_lower_case(str)
  return vim_string_to_lower(str)
end

function M.to_upper_case(str)
  return vim_string_to_upper(str)
end

function M.to_title_case(str)
  local parts = vim.split(M.to_dash_case(str), "-")
  return table.concat(utils.map(parts, toTitle), " ")
end

function M.to_snake_case(str)
  local parts = vim.split(M.to_dash_case(str), "-")
  return table.concat(parts, "_")
end

function M.to_dot_case(str)
  local parts = vim.split(M.to_dash_case(str), "-")
  return table.concat(parts, ".")
end

function M.to_path_case(str)
  local parts = vim.split(M.to_dash_case(str), "-")
  return table.concat(parts, "/")
end

function M.to_constant_case(str)
  local parts = vim.split(M.to_dash_case(str), "-")
  return table.concat(utils.map(parts, vim_string_to_upper), "_")
end

function M.to_title_dash_case(str)
  local parts = vim.split(M.to_dash_case(str), "-")
  return table.concat(utils.map(parts, toTitle), "-")
end

function M.to_dash_case(str)
  local trim_info, s = utils.trim_str(str)

  local parts = M.to_parts(s)
  local result = table.concat(utils.map(parts, vim_string_to_lower), "-")

  return utils.untrim_str(result, trim_info)
end

return M
