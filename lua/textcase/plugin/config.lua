local config = {}

config.options = {}

local function with_defaults(options)
  return {
    operator_prefix = options.operator_prefix or nil,
    lsp_operator_prefix = options.lsp_operator_prefix or nil,
    search_replace_prefix = options.search_replace_prefix or nil,
    conversions = options.conversions or {},
  }
end

function config.setup(options)
  config.options = with_defaults(options or {})
  return config.options
end

return config
