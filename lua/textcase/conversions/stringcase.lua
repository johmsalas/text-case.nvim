local utils = require("textcase.shared.utils")

local M = {}

local is_special = function(b)
  return b <= 0x2F or (b >= 0x3A and b <= 0x3F) or (b >= 0x5B and b <= 0x60) or (b >= 0x7B and b <= 0x7F)
end

local is_upper = function(b)
  return b >= 0x41 and b <= 0x5A
end

local toTitle = function(str)
  return string.sub(str, 1, 1):upper() .. string.sub(str, 2):lower()
end

function M.to_parts(str)
  local has_lower = str:find("[a-z]") ~= nil

  local parts = {}
  local new_part = true
  for i = 1, str:len() do
    local b = str:byte(i)
    if is_special(b) then
      new_part = true
    else
      if is_upper(b) and has_lower then
        new_part = true
      end

      if new_part then
        table.insert(parts, "")
        new_part = false
      end

      parts[#parts] = parts[#parts] .. str:sub(i, i)
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
    return parts[1]:lower()
  end
  if #parts > 1 then
    return parts[1]:lower() .. table.concat(utils.map({ unpack(parts, 2) }, toTitle), "")
  end

  return ""
end

function M.to_upper_phrase_case(str)
  return M.to_dash_case(str):upper():gsub("-", " ")
end

function M.to_lower_phrase_case(str)
  return M.to_dash_case(str):lower():gsub("-", " ")
end

function M.to_phrase_case(str)
  local lower = M.to_dash_case(str):lower()
  lower = lower:gsub("-", " ")
  return lower:sub(1, 1):upper() .. lower:sub(2, #lower)
end

function M.to_lower_case(str)
  return str:lower()
end

function M.to_upper_case(str)
  return str:upper()
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
  return table.concat(utils.map(parts, string.upper), "_")
end

function M.to_title_dash_case(str)
  local parts = vim.split(M.to_dash_case(str), "-")
  return table.concat(utils.map(parts, toTitle), "-")
end

function M.to_dash_case(str)
  local trim_info, s = utils.trim_str(str)

  local parts = M.to_parts(s)
  local result = table.concat(utils.map(parts, string.lower), "-")

  return utils.untrim_str(result, trim_info)
end

return M
