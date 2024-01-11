local utils = require("textcase.shared.utils")

local M = {}

local is_upper = function(char)
  if vim.fn.toupper(char) == vim.fn.tolower(char) then
    return false
  end

  return vim.fn.toupper(char) == char
end

local function split_string_into_chars(str)
  local chars = {}
  if str == "" or str == nil then
    return chars
  end

  for uchar in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
    table.insert(chars, uchar)
  end
  return chars
end

local is_special = function(char)
  local b = char:byte(1)
  return b <= 0x2F or (b >= 0x3A and b <= 0x3F) or (b >= 0x5B and b <= 0x60) or (b >= 0x7B and b <= 0x7F)
end

local toTitle = function(str)
  if str == nil or str == "" then
    return ""
  end

  local chars = split_string_into_chars(str)
  local first_char = chars[1]
  local rest_chars = { unpack(chars, 2) }
  local rest_str = table.concat(rest_chars, "")

  return vim.fn.toupper(first_char) .. vim.fn.tolower(rest_str)
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
    return vim.fn.tolower(parts[1])
  end
  if #parts > 1 then
    return vim.fn.tolower(parts[1]) .. table.concat(utils.map({ unpack(parts, 2) }, toTitle), "")
  end

  return ""
end

function M.to_upper_phrase_case(str)
  return vim.fn.toupper(M.to_dash_case(str)):gsub("-", " ")
end

function M.to_lower_phrase_case(str)
  return vim.fn.tolower(M.to_dash_case(str)):gsub("-", " ")
end

function M.to_phrase_case(str)
  local lower = vim.fn.tolower(M.to_dash_case(str))
  lower = lower:gsub("-", " ")
  return vim.fn.toupper(lower:sub(1, 1)) .. lower:sub(2, #lower)
end

function M.to_lower_case(str)
  return vim.fn.tolower(str)
end

function M.to_upper_case(str)
  return vim.fn.toupper(str)
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
  return table.concat(utils.map(parts, vim.fn.toupper), "_")
end

function M.to_title_dash_case(str)
  local parts = vim.split(M.to_dash_case(str), "-")
  return table.concat(utils.map(parts, toTitle), "-")
end

function M.to_dash_case(str)
  local trim_info, s = utils.trim_str(str)

  local parts = M.to_parts(s)
  local result = table.concat(utils.map(parts, vim.fn.tolower), "-")

  return utils.untrim_str(result, trim_info)
end

return M
