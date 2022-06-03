local M = {}

local plugin = require('textcase.plugin.plugin')
local api = require('textcase.plugin.api')

M.setup = function(opts)
  local prefix = opts and opts.prefix or 'cr'

  plugin.register_keybindings(api.to_constant_case, {
    current_word = prefix .. 'n',
    visual = prefix .. 'n',
    operator = prefix .. 'on',
    lsp_rename = prefix .. 'N',
  })
  plugin.register_keybindings(api.to_camel_case, {
    current_word = prefix .. 'c',
    visual = prefix .. 'c',
    operator = prefix .. 'oc',
    lsp_rename = prefix .. 'C',
  })
  plugin.register_keybindings(api.to_dash_case, {
    current_word = prefix .. 'd',
    visual = prefix .. 'd',
    operator = prefix .. 'od',
    lsp_rename = prefix .. 'D',
  })
  plugin.register_keybindings(api.to_pascal_case, {
    current_word = prefix .. 'p',
    visual = prefix .. 'p',
    operator = prefix .. 'op',
    lsp_rename = prefix .. 'P',
  })
  plugin.register_keybindings(api.to_upper_case, {
    current_word = prefix .. 'u',
    visual = prefix .. 'u',
    operator = prefix .. 'ou',
    lsp_rename = prefix .. 'U',
  })
  plugin.register_keybindings(api.to_lower_case, {
    current_word = prefix .. 'l',
    visual = prefix .. 'l',
    operator = prefix .. 'ol',
    lsp_rename = prefix .. 'L',
  })

  plugin.register_replace_command('Subs', {
    api.to_upper_case,
    api.to_lower_case,
    api.to_snake_case,
    api.to_dash_case,
    api.to_constant_case,
    api.to_dot_case,
    api.to_phrase_case,
    api.to_camel_case,
    api.to_pascal_case,
    api.to_title_case,
    api.to_path_case,
  })
end

return M
