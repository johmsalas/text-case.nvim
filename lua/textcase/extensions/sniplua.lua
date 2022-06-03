local M = {}

function M.from_snip_input(string_convert)
  local ls = require"luasnip"
  local sn = ls.snippet_node
  local i = ls.insert_node
  local t = ls.text_node

  return function(args)
    if args[1][1] == '' then
      return sn(nil, {
        i(1)
      })
    else
      return sn(nil, {
        t(M.flatten_multilines(string_convert)(args))
      })
    end
  end
end

function M.flatten_multilines(string_convert)
  return function(args)
    if (args == nil) then return string_convert('') end

    local output = {}
    for _, lines in ipairs(args) do
      table.insert(output, table.concat(lines, "\n"))
    end

    local text = table.concat(output, "\n\n")

    return string_convert(text)
  end
end

return M
