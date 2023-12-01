local utils = require("textcase.shared.utils")

local M = {}

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

local function is_lower(char)
  return not is_upper(char)
end

local function string_change_case_native(str, direction)
  local result = ""

  if direction == "upper" then
    result = str:upper()
  else
    result = str:lower()
  end

  return result
end

-- According to https://www.utf8-chartable.de/unicode-utf8-table.pl?names=-&utf8=dec
-- the difference between upper and lower case is 0x20 (32).
local upper_to_lower_diff = 0x20
local function string_change_case_special_chars(char, direction)
  -- Create a list of bytes for the current char.
  local bytes = {}
  for byte in char:gmatch(".") do
    table.insert(bytes, byte:byte(1))
  end

  if direction == "upper" then
    if is_lower(char) then
      bytes[2] = bytes[2] - upper_to_lower_diff
    end
  else
    if is_upper(char) then
      bytes[2] = bytes[2] + upper_to_lower_diff
    end
  end

  return string.char(bytes[1], bytes[2])
end

local function split_string_into_chars(str)
  local chars = {}
  for uchar in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
    table.insert(chars, uchar)
  end
  return chars
end

-- This function changes the case of a string. It has to be used instead of
-- string.upper and string.lower because those functions don't work with
-- multi-byte chars.
--
-- NOTE: If Neovim eventually supports UTF-8 string functions, we can use the string.upper/lower
-- functions from there again.
local function string_change_case(str, direction)
  local result = ""

  -- Go char by char and change the case of each char
  for _, char in ipairs(split_string_into_chars(str)) do
    if #char == 1 then
      -- If the char is a single byte, we can use the built-in string.upper and string.lower functions
      result = result .. string_change_case_native(char, direction)
    elseif #char == 2 then
      -- If the char is a multi-byte char, we need to do some extra work
      result = result .. string_change_case_special_chars(char, direction)
    else
      -- If the char is neither a single byte nor a multi-byte char, we just append it to the result
      result = result .. char
    end
  end

  return result
end

-- Use this instead of string.upper to handle multi-byte chars
local string_to_upper = function(str)
  return string_change_case(str, "upper")
end

-- Use this instead of string.lower to handle multi-byte chars
local string_to_lower = function(str)
  return string_change_case(str, "lower")
end

local is_special = function(char)
  local b = char:byte(1)
  return b <= 0x2F or (b >= 0x3A and b <= 0x3F) or (b >= 0x5B and b <= 0x60) or (b >= 0x7B and b <= 0x7F)
end

local toTitle = function(str)
  local chars = split_string_into_chars(str)
  local first_char = chars[1]
  local rest_chars = { unpack(chars, 2) }
  local rest_str = table.concat(rest_chars, "")

  return string_to_upper(first_char) .. string_to_lower(rest_str)
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
    return string_to_lower(parts[1])
  end
  if #parts > 1 then
    return string_to_lower(parts[1]) .. table.concat(utils.map({ unpack(parts, 2) }, toTitle), "")
  end

  return ""
end

function M.to_upper_phrase_case(str)
  return string_to_upper(M.to_dash_case(str)):gsub("-", " ")
end

function M.to_lower_phrase_case(str)
  return string_to_lower(M.to_dash_case(str)):gsub("-", " ")
end

function M.to_phrase_case(str)
  local lower = string_to_lower(M.to_dash_case(str))
  lower = lower:gsub("-", " ")
  return string_to_upper(lower:sub(1, 1)) .. lower:sub(2, #lower)
end

function M.to_lower_case(str)
  return string_to_lower(str)
end

function M.to_upper_case(str)
  return string_to_upper(str)
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
  return table.concat(utils.map(parts, string_to_upper), "_")
end

function M.to_title_dash_case(str)
  local parts = vim.split(M.to_dash_case(str), "-")
  return table.concat(utils.map(parts, toTitle), "-")
end

function M.to_dash_case(str)
  local trim_info, s = utils.trim_str(str)

  local parts = M.to_parts(s)
  local result = table.concat(utils.map(parts, string_to_lower), "-")

  return utils.untrim_str(result, trim_info)
end

return M
