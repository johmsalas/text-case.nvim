exe "lua require('textcase').init()"

command! -range TextCaseOpenTelescope <line1>,<line2>lua require("textcase").open_telescope()
command! -range TextCaseOpenTelescopeQuickChange <line1>,<line2>lua require("textcase").open_telescope('quick_change')
command! -range TextCaseOpenTelescopeLSPChange <line1>,<line2>lua require("textcase").open_telescope('lsp_change')

command! -range TextCaseStartReplacingCommand <line1>,<line2>lua require("textcase").start_replacing_command()


function! TextCaseSubstituteLauncher(...) range
  " Stores the first argument as a global variable
  let g:TextCaseSubsArgs = a:1
  
  " Then it invokes the dispatcher in visual mode if multiple lines
  " are selected, otherwise normal mode is passed

  if a:firstline == a:lastline
    " if a single line is selected
    lua require'textcase'.dispatcher('n', vim.g.TextCaseSubsArgs)
  elseif a:firstline == 1 && a:lastline == line("$")
    " if all the file is selected
    lua require'textcase'.dispatcher('n', vim.g.TextCaseSubsArgs)
  else
    " A range of multiple lines is selected
    lua require'textcase'.dispatcher('\22', vim.g.TextCaseSubsArgs)
  endif
endfunction

