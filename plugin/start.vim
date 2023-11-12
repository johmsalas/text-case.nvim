exe "lua require('textcase').init()"

command! -range TextCaseOpenTelescope <line1>,<line2>lua require("textcase").open_telescope()
command! -range TextCaseOpenTelescopeQuickChange <line1>,<line2>lua require("textcase").open_telescope('quick_change')
command! -range TextCaseOpenTelescopeLSPChange <line1>,<line2>lua require("textcase").open_telescope('lsp_change')

command! -range TextCaseStartReplacingCommand <line1>,<line2>lua require("textcase").start_replacing_command()


function! TextCaseSubstituteLauncher(...) range
  let g:TextCaseSubsArgs = a:1

  if a:firstline == a:lastline
    lua require'textcase'.dispatcher('n', vim.g.TextCaseSubsArgs)
  elseif a:firstline == 1 && a:lastline == line("$")
    lua require'textcase'.dispatcher('n', vim.g.TextCaseSubsArgs)
  else
    lua require'textcase'.dispatcher('\22', vim.g.TextCaseSubsArgs)
  endif
endfunction

