exe "lua require('textcase.plugin.presets').Initialize()"

command! -range TextCaseOpenTelescope <line1>,<line2>lua require("textcase").open_telescope()

