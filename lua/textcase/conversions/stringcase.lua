local utils = require('textcase.shared.utils')

local M = {}

local codes = {
  a = string.byte('a'),
  z = string.byte('z'),
  A = string.byte('A'),
  Z = string.byte('Z'),
}

local toTitle = function(str)
  return string.sub(str, 1, 1):upper() .. string.sub(str, 2):lower()
end

function M.to_pascal_case(str)
  local parts = vim.split(M.to_dash_case(str), '-')
  return table.concat(utils.map(parts, toTitle), "")
end

function M.to_camel_case(str)
  local parts = vim.split(M.to_dash_case(str), '-')
  if #parts == 1 then return parts[1]:lower() end
  if #parts > 1 then
    return parts[1]:lower() ..
        table.concat(
          utils.map(
            { unpack(parts, 2) },
            toTitle
          )
          , "")
  end

  return ''
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
  local parts = vim.split(M.to_dash_case(str), '-')
  return table.concat(utils.map(parts, toTitle), " ")
end

function M.to_snake_case(str)
  local parts = vim.split(M.to_dash_case(str), '-')
  return table.concat(parts, "_")
end

function M.to_dot_case(str)
  local parts = vim.split(M.to_dash_case(str), '-')
  return table.concat(parts, ".")
end

function M.to_path_case(str)
  local parts = vim.split(M.to_dash_case(str), '-')
  return table.concat(parts, "/")
end

function M.to_constant_case(str)
  local parts = vim.split(M.to_dash_case(str), '-')
  return table.concat(utils.map(parts, string.upper), "_")
end

function Smart_analysis(str)
  local has_lower_case_characters = false
  local has_upper_case_characters = false
  local separators_dict = {}
  local separators = {}

  for current in str:gmatch "." do
    local code = string.byte(current)
    local is_lower = code >= codes.a and code <= codes.z
    local is_upper = code >= codes.A and code <= codes.Z

    if is_lower then has_lower_case_characters = true end
    if is_upper then has_upper_case_characters = true end

    if current == "." or current == '-' or current == '_' or current == ' ' then
      if separators_dict[current] == nil then
        separators_dict[current] = current
        table.insert(separators, current)
      end
    end
  end

  return has_lower_case_characters, has_upper_case_characters, separators
end

function M.to_dash_case(str)
  local previous = nil
  local items = {}

  local ends_with_space = string.sub(str, -1) == " "
  local has_lower_case_characters, _, separators = Smart_analysis(str)

  for current in str:gmatch "." do
    local previous_code = previous and string.byte(previous) or 0
    local current_code = string.byte(current)

    local is_previous_lower = previous_code >= codes.a and previous_code <= codes.z
    local is_previous_upper = previous_code >= codes.A and previous_code <= codes.Z
    local is_current_lower = current_code >= codes.a and current_code <= codes.z
    local is_current_upper = current_code >= codes.A and current_code <= codes.Z

    local is_previous_alphabet = is_previous_lower or is_previous_upper
    local current_can_continue_word = is_current_lower or (
        is_current_upper and not has_lower_case_characters and #separators > 0
        )

    if previous == nil or (
        is_previous_alphabet and not current_can_continue_word
        ) then
      table.insert(items, "")
    end

    if is_current_upper or is_current_lower then
      items[#items] = items[#items] .. current
    end

    previous = current
  end

  local result = table.concat(utils.map(
    { unpack(items, 1, ends_with_space and (#items - 1) or #items) },
    string.lower
  ), "-") .. (ends_with_space and ' ' or '')
  return result
end

return M
