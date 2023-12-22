local M = {}

local presets = require("textcase.plugin.presets")
local utils = require("textcase.shared.utils")

local function to_camel_case(str)
  return str
    :gsub("[_%.%-/](%w)", function(x)
      return x:upper()
    end)
    :gsub("^%l", string.upper)
end

-- Function to generate casing variations of a given word
function M.get_word_casing_variations(word)
  local variations = {}

  for _, method in pairs(utils.get_text_cases(presets)) do
    if presets.options.enabled_methods_set[method.method_name] then
      table.insert(variations, method(word))
    end
  end

  return variations
end

return M
