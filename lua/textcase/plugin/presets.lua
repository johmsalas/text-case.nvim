local M = {}
M.options = {}

local plugin = require("textcase.plugin.plugin")
local api = require("textcase.plugin.api")
local whichkey = require("textcase.extensions.whichkey")
local all_methods = {
  "to_upper_case",
  "to_lower_case",
  "to_snake_case",
  "to_dash_case",
  "to_title_dash_case",
  "to_constant_case",
  "to_dot_case",
  "to_phrase_case",
  "to_camel_case",
  "to_pascal_case",
  "to_title_case",
  "to_path_case",
  "to_upper_phrase_case",
  "to_lower_phrase_case",
}

-- Setup default keymappings for the plugin but only for the methods that are enabled.
local function setup_default_keymappings()
  whichkey.register("v", {
    [M.options.prefix] = {
      name = "text-case",
    },
  })

  whichkey.register("n", {
    [M.options.prefix] = {
      name = "text-case",
      o = {
        name = "Pending mode operator",
      },
    },
  })

  local default_keymapping_definitions = {
    { method_name = "to_constant_case", quick_replace = "n", operator = "on", lsp_rename = "N" },
    { method_name = "to_camel_case", quick_replace = "c", operator = "oc", lsp_rename = "C" },
    { method_name = "to_snake_case", quick_replace = "s", operator = "os", lsp_rename = "S" },
    { method_name = "to_dash_case", quick_replace = "d", operator = "od", lsp_rename = "D" },
    { method_name = "to_pascal_case", quick_replace = "p", operator = "op", lsp_rename = "P" },
    { method_name = "to_upper_case", quick_replace = "u", operator = "ou", lsp_rename = "U" },
    { method_name = "to_lower_case", quick_replace = "l", operator = "ol", lsp_rename = "L" },
    { method_name = "to_title_case", quick_replace = "t", operator = "ot", lsp_rename = "T" },
    { method_name = "to_dot_case", quick_replace = "o", operator = "oo", lsp_rename = "O" },
    { method_name = "to_path_case", quick_replace = "a", operator = "oa", lsp_rename = "A" },
  }

  for _, keymapping_definition in ipairs(default_keymapping_definitions) do
    if M.options.enabled_methods_set[keymapping_definition.method_name] then
      plugin.register_keybindings(M.options.prefix, api[keymapping_definition.method_name], {
        prefix = M.options.prefix,
        quick_replace = keymapping_definition.quick_replace,
        operator = keymapping_definition.operator,
        lsp_rename = keymapping_definition.lsp_rename,
      })
    end
  end
end

local function register_replace_command(substitude_command_name)
  for _, method_name in ipairs(all_methods) do
    plugin.register_methods(api[method_name])
  end

  plugin.register_replace_command(substitude_command_name)
end

M.Initialize = function()
  register_replace_command("Subs")
end

-- Set all methods as default in case the setup function is not called.
M.enabled_methods_set = all_methods

M.setup = function(opts)
  M.options.prefix = opts and opts.prefix or "ga"

  if opts and opts.substitude_command_name ~= nil then
    -- Register the substitude command with the passed in name again.
    -- This is needed because we don't require the user to call the setup function.
    register_replace_command(opts.substitude_command_name)
  end

  M.options.default_keymappings_enabled = true
  if opts and opts.default_keymappings_enabled ~= nil then
    M.options.default_keymappings_enabled = opts.default_keymappings_enabled
  end

  M.options.enabled_methods = opts and opts.enabled_methods or all_methods
  -- Turn the enabled_methods into a set for faster lookup
  M.options.enabled_methods_set = {}
  for _, method_name in ipairs(M.options.enabled_methods) do
    M.options.enabled_methods_set[method_name] = true
  end

  if M.options.default_keymappings_enabled then
    setup_default_keymappings()
  end
end

return M
