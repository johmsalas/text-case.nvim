local M = {}

local stringcase = require("textcase.conversions.stringcase")

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

  -- Lowercase
  table.insert(variations, word:lower())

  -- CamelCase
  table.insert(variations, stringcase.to_camel_case(word))

  -- Uppercase
  table.insert(variations, word:upper())

  return variations
end

return M
