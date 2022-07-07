exe "lua require('textcase.plugin.presets').Initialize()"

command! -range TextCaseOpenTelescope <line1>,<line2>lua require("textcase").open_telescope()
command! -range TextCaseOpenTelescopeQuickChange <line1>,<line2>lua require("textcase").open_telescope('quick_change')
command! -range TextCaseOpenTelescopeLSPChange <line1>,<line2>lua require("textcase").open_telescope('lsp_change')

