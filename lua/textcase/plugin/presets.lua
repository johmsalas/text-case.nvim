local M = {}

local plugin = require('textcase.plugin.plugin')
local api = require('textcase.plugin.api')
local whichkey = require("textcase.extensions.whichkey")

M.Initialize = function()
  plugin.register_methods(api.to_upper_case)
  plugin.register_methods(api.to_lower_case)
  plugin.register_methods(api.to_snake_case)
  plugin.register_methods(api.to_dash_case)
  plugin.register_methods(api.to_constant_case)
  plugin.register_methods(api.to_dot_case)
  plugin.register_methods(api.to_phrase_case)
  plugin.register_methods(api.to_camel_case)
  plugin.register_methods(api.to_pascal_case)
  plugin.register_methods(api.to_title_case)
  plugin.register_methods(api.to_path_case)
  plugin.register_methods(api.to_upper_phrase_case)
  plugin.register_methods(api.to_lower_phrase_case)

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
    api.to_upper_phrase_case,
    api.to_lower_phrase_case,
  })
end

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
    quick_replace = 'n',
    operator = 'on',
    lsp_rename = 'N',
  })
  plugin.register_keybindings(prefix, api.to_camel_case, {
    prefix = prefix,
    quick_replace = 'c',
    operator = 'oc',
    lsp_rename = 'C',
  })
  plugin.register_keybindings(prefix, api.to_snake_case, {
    prefix = prefix,
    quick_replace = 's',
    operator = 'os',
    lsp_rename = 'S',
  })
  plugin.register_keybindings(prefix, api.to_dash_case, {
    prefix = prefix,
    quick_replace = 'd',
    operator = 'od',
    lsp_rename = 'D',
  })
  plugin.register_keybindings(prefix, api.to_pascal_case, {
    prefix = prefix,
    quick_replace = 'p',
    operator = 'op',
    lsp_rename = 'P',
  })
  plugin.register_keybindings(prefix, api.to_upper_case, {
    prefix = prefix,
    quick_replace = 'u',
    operator = 'ou',
    lsp_rename = 'U',
  })
  plugin.register_keybindings(prefix, api.to_lower_case, {
    prefix = prefix,
    quick_replace = 'l',
    operator = 'ol',
    lsp_rename = 'L',
  })
end

return M
