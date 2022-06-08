local M = {}

local plugin = require('textcase.plugin.plugin')
local api = require('textcase.plugin.api')
local whichkey = require("textcase.extensions.whichkey")

M.setup = function(opts)
  local prefix = opts and opts.prefix or 'ga'

  whichkey.register('v', {
    [prefix] = {
      name = 'text-case',
    }
  })

  whichkey.register('n', {
    [prefix] = {
      name = 'text-case',
      o = {
        name = 'Pending mode operator'
      }
    }
  })

  plugin.register_keybindings(prefix, api.to_constant_case, {
    prefix = prefix,
    current_word = 'n',
    visual = 'n',
    operator = 'on',
    lsp_rename = 'N',
  })
  plugin.register_keybindings(prefix, api.to_camel_case, {
    prefix = prefix,
    current_word = 'c',
    visual = 'c',
    operator = 'oc',
    lsp_rename = 'C',
  })
  plugin.register_keybindings(prefix, api.to_dash_case, {
    prefix = prefix,
    current_word = 'd',
    visual = 'd',
    operator = 'od',
    lsp_rename = 'D',
  })
  plugin.register_keybindings(prefix, api.to_pascal_case, {
    prefix = prefix,
    current_word = 'p',
    visual = 'p',
    operator = 'op',
    lsp_rename = 'P',
  })
  plugin.register_keybindings(prefix, api.to_upper_case, {
    prefix = prefix,
    current_word = 'u',
    visual = 'u',
    operator = 'ou',
    lsp_rename = 'U',
  })
  plugin.register_keybindings(prefix, api.to_lower_case, {
    prefix = prefix,
    current_word = 'l',
    visual = 'l',
    operator = 'ol',
    lsp_rename = 'L',
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
