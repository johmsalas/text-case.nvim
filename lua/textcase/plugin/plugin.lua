local repeat_methods = require("strings.repeat.methods")
local substitute_methods = require("strings.substitute.methods")

-- return substitute_methods
return vim.tbl_extend("force", substitute_methods, repeat_methods, {
  register_methods_in_repeat = repeat_methods.register_methods,
  register_methods_in_substitute = substitute_methods.register_methods,
  repeat_methods = nil,
})
