local utils = require("textcase.shared.utils")
local constants = require("textcase.shared.constants")
local conversion = require("textcase.plugin.conversion")
local config = require("textcase.plugin.config")

local M = {}

M.state = {
  register = nil,
  methods_by_desc = {},
  methods_by_command = {},
  change_type = nil,
  current_method = nil, -- Since curried vim func operators are not yet supported
  match = nil,
}

function M.register_keybindings(method_table, keybindings, opts)
  -- TODO: validate method_table
  M.state.methods_by_desc[method_table.desc] = method_table
  M.state.methods_by_desc[method_table.desc].opts = opts

  for _, feature in ipairs({
    'line',
    'eol',
    'visual',
    'operator',
    'lsp_rename',
    'current_word',
  }) do
    if keybindings[feature] ~= nil then
      local mode = 'n'
      if feature == 'visual' then
        mode = 'v'
      end
      vim.api.nvim_set_keymap(
        mode,
        keybindings[feature],
        "<cmd>lua require('" .. constants.namespace .. "')." .. feature .. "('" .. method_table.desc .. "')<cr>",
        { noremap = true }
      )
    end
  end
end

function M.register_keys(method_table, keybindings)
  -- Sugar syntax
  M.register_keybindings(method_table, {
    line = keybindings[1],
    eol = keybindings[2],
    visual = keybindings[3],
    operator = keybindings[4],
    lsp_rename = keybindings[5],
    current_word = keybindings[6],
  })
end

local function trim_space(opts, preview_ns, preview_buf)
  local line1 = opts.line1
  local line2 = opts.line2
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, 0)
  local new_lines = {}
  local preview_buf_line = 0
  for i, line in ipairs(lines) do
    local startidx, endidx = string.find(line, '%s+$')
    if startidx ~= nil then
      -- Highlight the match if in command preview mode
      if preview_ns ~= nil then
        vim.api.nvim_buf_add_highlight(
          buf, preview_ns, 'Substitute', line1 + i - 2, startidx - 1,
          endidx
        )
        -- Add lines and highlight to the preview buffer
        -- if inccommand=split
        if preview_buf ~= nil then
          local prefix = string.format('|%d| ', line1 + i - 1)
          vim.api.nvim_buf_set_lines(
            preview_buf, preview_buf_line, preview_buf_line, 0,
            { prefix .. line }
          )
          vim.api.nvim_buf_add_highlight(
            preview_buf, preview_ns, 'Substitute', preview_buf_line,
            #prefix + startidx - 1, #prefix + endidx
          )
          preview_buf_line = preview_buf_line + 1
        end
      end
    end
    if not preview_ns then
      new_lines[#new_lines + 1] = string.gsub(line, '%s+$', '')
    end
  end
  -- Don't make any changes to the buffer if previewing
  if not preview_ns then
    vim.api.nvim_buf_set_lines(buf, line1 - 1, line2, 0, new_lines)
  end
  -- When called as a preview callback, return the value of the
  -- preview type
  if preview_ns ~= nil then
    return 2
  end
end

function M.register_replace_command(command, method_keys)
  -- TODO: validate command
  M.state.methods_by_command[command] = {}

  for _, method in ipairs(method_keys) do
    table.insert(M.state.methods_by_command[command], method)
  end

  -- if vim.has("v0.9.0-dev+359-g9745941ef") == 1 then
  --   vim.api.nvim_create_user_command(
  --     command,
  --     trim_space,
  --     { nargs = '1', range = '0', addr = 'lines', preview = trim_space }
  --   )
  -- else
  vim.cmd([[
      command! -nargs=1 -bang -bar -range=0 ]] .. command .. [[ :lua require("]] .. constants.namespace .. [[").dispatcher( "]] .. command .. [[" ,<q-args>)
    ]])
  -- end
end

function M.clear_match(command_namespace)
  if nil ~= M.state.match then
    vim.fn.matchdelete(M.state.match)
    M.state.match = nil
  end

  vim.cmd([[
    augroup ]] .. command_namespace .. [[ClearMatch
      autocmd!
    augroup END
  ]])
end

local function add_match(command, str)
  local command_namespace = constants.namespace .. command
  M.state.match = vim.fn.matchadd(
    command_namespace,
    vim.fn.escape(str, "\\"),
    2
  )

  vim.cmd([[
    augroup ]] .. command_namespace .. [[ClearMatch
      autocmd!
      autocmd InsertEnter,WinLeave,BufLeave * lua require("]] .. constants.namespace .. [[").clear_match("]] .. command_namespace .. [[")
      autocmd CursorMoved * lua require("]] .. constants.namespace .. [[").clear_match("]] .. command_namespace .. [[")
    augroup END
  ]])
end

function M.dispatcher(command, args)
  local params = vim.split(args, '/')
  local source, dest = params[2], params[3]

  -- TODO: Hightlight matches
  -- stringcase.state.match = vim.fn.matchadd("Search", vim.fn.escape(source, "\\"), 2)
  local cursor_pos = vim.fn.getpos(".")

  for _, method in ipairs(M.state.methods_by_command[command]) do
    local transformed_source = method.apply(source)
    local transformed_dest = method.apply(dest)

    add_match(command, transformed_source)

    local get_match = utils.get_list(utils.escape_string(transformed_source))
    for match in get_match do
      conversion.replace_matches(match, transformed_source, transformed_dest, false)
    end
  end

  vim.fn.setpos(".", cursor_pos)
end

function M.operator(method_key)
  M.state.register = vim.v.register
  M.state.current_method = method_key
  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"
  vim.api.nvim_feedkeys("g@", "i", false)
end

function M.operator_callback(vmode)
  local method = M.state.methods_by_desc[M.state.current_method]
  local apply = method.apply

  if M.state.change_type == constants.change_type.LSP_RENAME then
    conversion.do_lsp_rename(apply)
  else
    local region = utils.get_region(vmode)

    if M.state.change_type == constants.change_type.CURRENT_WORD then
      local jumper = method.opts and method.opts.jumper or nil

      if jumper ~= nil then
        local lines = utils.nvim_buf_get_text(
          0,
          region.start_row,
          region.start_col,
          region.end_row,
          region.end_col
        )
        region = jumper(lines, region)
      end
    end

    vim.pretty_print(region)

    conversion.do_substitution(
      region.start_row,
      region.start_col,
      region.end_row,
      region.end_col,
      apply
    )
  end
end

function M.line(case_desc)
  M.state.register = vim.v.register
  M.state.current_method = case_desc
  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"
  local keys = vim.api.nvim_replace_termcodes(
    string.format("g@:normal! 0v%s$<cr>", vim.v.count > 0 and vim.v.count - 1 .. "j" or ""),
    true,
    false,
    true
  )
  vim.api.nvim_feedkeys(keys, "i", false)
end

function M.eol(case_desc)
  M.state.register = vim.v.register
  M.state.current_method = case_desc
  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"
  vim.api.nvim_feedkeys("g@$", "i", false)
end

function M.visual(case_desc)
  M.state.register = vim.v.register
  M.state.current_method = case_desc
  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"
  vim.api.nvim_feedkeys("g@`>", "i", false)
end

function M.lsp_rename(case_desc)
  M.state.register = vim.v.register
  M.state.current_method = case_desc
  M.state.change_type = constants.change_type.LSP_RENAME

  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"
  vim.api.nvim_feedkeys("g@aW", "i", false)
end

function M.current_word(case_desc)
  M.state.register = vim.v.register
  M.state.current_method = case_desc
  M.state.change_type = constants.change_type.CURRENT_WORD

  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"
  vim.api.nvim_feedkeys("g@aw", "i", false)
end

function M.replace_word_under_cursor(command)
  local current_word = vim.fn.expand('<cword>')
  vim.api.nvim_feedkeys(":" .. command .. '/' .. current_word .. '/', "i", false)
end

function M.replace_selection()
  print('TODO: pending implementation')
end

return M
