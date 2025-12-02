local utils = require("textcase.shared.utils")
local constants = require("textcase.shared.constants")
local conversion = require("textcase.plugin.conversion")

local M = {}

M.state = {
  register = nil,
  methods_by_method_name = {},
  change_type = nil,
  current_method = nil, -- Since curried vim func operators are not yet supported
  match = nil,
  telescope_previous_mode = nil,
  telescope_previous_visual_region = nil,
  telescope_previous_visual_register = nil,
  telescope_previous_buffer = nil,
}

function M.register_methods(method_table, opts)
  -- TODO: validate method_table
  M.state.methods_by_method_name[method_table.method_name] = method_table
  M.state.methods_by_method_name[method_table.method_name].opts = opts
end

function M.register_keybindings(prefix, method_table, keybindings, opts)
  for _, feature in ipairs({
    "line",
    "eol",
    "visual",
    "operator",
    "lsp_rename",
    "current_word",
  }) do
    if keybindings[feature] ~= nil then
      local mode = "n"
      if feature == "visual" then
        mode = "x"
      end
      local desc = method_table.desc

      if feature == "current_word" then
        desc = "Convert " .. desc
      elseif feature == "lsp_rename" then
        desc = "LSP rename " .. desc
      end

      vim.keymap.set(
        mode,
        prefix .. keybindings[feature],
        "<cmd>lua require('" .. constants.namespace .. "')." .. feature .. "('" .. method_table.method_name .. "')<cr>",
        { desc = desc }
      )
    end
  end

  if keybindings["quick_replace"] ~= nil then
    local keybind = prefix .. keybindings["quick_replace"]
    local desc = "Convert " .. method_table.desc
    local command = "<cmd>lua require('"
      .. constants.namespace
      .. "')."
      .. "quick_replace"
      .. "('"
      .. method_table.method_name
      .. "')<cr>"

    vim.keymap.set("n", keybind, command, { desc = desc })
    vim.keymap.set("x", keybind, command, { desc = desc })
  end
end

function M.register_keys(prefix, method_table, keybindings)
  -- Sugar syntax
  M.register_keybindings(prefix, method_table, {
    line = keybindings[1],
    eol = keybindings[2],
    visual = keybindings[3],
    operator = keybindings[4],
    lsp_rename = keybindings[5],
    current_word = keybindings[6],
  })
end

function MixStringConectors(str)
  return str:gsub("_", "-"):gsub("-", " "):gsub(" ", "_")
end

function M.dispatcher(mode, args)
  local params = vim.split(args, "/")
  local source, dest = params[2], params[3]
  source = MixStringConectors(source)
  dest = MixStringConectors(dest)

  local cursor_pos = vim.fn.getpos(".")
  -- vim.api.nvim_feedkeys("g@", "i", false)

  for _, method in pairs(M.state.methods_by_method_name) do
    local transformed_source = method.apply(source)
    local transformed_dest = method.apply(dest)

    local get_match = utils.get_list(utils.escape_string(transformed_source), mode)
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
  local method = M.state.methods_by_method_name[M.state.current_method]
  local apply = method.apply

  if M.state.change_type == constants.change_type.LSP_RENAME then
    conversion.do_lsp_rename(apply)
  else
    local mode = M.state.telescope_previous_mode or vim.api.nvim_get_mode().mode
    local region = M.state.telescope_previous_visual_region
      or utils.get_visual_region(nil, false, nil, utils.get_mode_at_operator(vmode))
    local should_guess_region = M.state.change_type == constants.change_type.CURRENT_WORD
      or (M.state.change_type == constants.change_type.QUICK_REPLACE and mode == "n")

    if should_guess_region then
      local jumper = method.opts and method.opts.jumper or nil

      if jumper ~= nil then
        local lines = utils.nvim_buf_get_text(
          M.state.telescope_previous_buffer or 0,
          region.start_row,
          region.start_col,
          region.end_row,
          region.end_col
        )
        region = jumper(lines, region)
      end
    end

    if region.mode == constants.visual_mode.BLOCK then
      conversion.do_block_substitution(region.start_row, region.start_col, region.end_row, region.end_col, apply)
    else
      conversion.do_substitution(region.start_row, region.start_col, region.end_row, region.end_col, apply)
    end
  end

  M.state.telescope_previous_mode = nil
  M.state.telescope_previous_visual_region = nil
  M.state.telescope_previous_buffer = nil
  M.state.telescope_previous_visual_register = nil
end

function M.line(case_method)
  M.state.register = vim.v.register
  M.state.current_method = case_method
  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"
  local keys = vim.api.nvim_replace_termcodes(
    string.format("g@:normal! 0v%s$<cr>", vim.v.count > 0 and vim.v.count - 1 .. "j" or ""),
    true,
    false,
    true
  )
  vim.api.nvim_feedkeys(keys, "i", false)
end

function M.eol(case_method)
  M.state.register = vim.v.register
  M.state.current_method = case_method
  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"
  vim.api.nvim_feedkeys("g@$", "i", false)
end

function M.visual(case_method)
  M.state.register = vim.v.register
  M.state.current_method = case_method
  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"

  if M.state.telescope_previous_visual_region ~= nil then
    utils.set_visual_region(M.state.telescope_previous_visual_region)
    if M.state.telescope_previous_visual_region.mode == constants.visual_mode.BLOCK then
      vim.api.nvim_feedkeys("g@`[", "i", false)
    else
      vim.api.nvim_feedkeys("g@`<", "i", false)
    end
  else
    vim.api.nvim_feedkeys("g@`>", "i", false)
  end
end

function M.lsp_rename(case_method)
  M.state.register = vim.v.register
  M.state.current_method = case_method
  M.state.change_type = constants.change_type.LSP_RENAME

  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"

  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.api.nvim_feedkeys("g@", "i", false)
  else
    vim.api.nvim_feedkeys("g@iw", "i", false)
  end
end

function M.current_word(case_method)
  M.state.register = vim.v.register
  M.state.current_method = case_method
  M.state.change_type = constants.change_type.CURRENT_WORD

  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"

  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.api.nvim_feedkeys("g@", "i", false)
  else
    vim.api.nvim_feedkeys("g@aw", "i", false)
  end
end

function M.quick_replace(case_method)
  M.state.register = vim.v.register
  M.state.current_method = case_method
  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"
  M.state.change_type = constants.change_type.QUICK_REPLACE

  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "\22" or mode == "V" then
    M.state.telescope_previous_visual_region = utils.get_visual_region(0, true, nil, utils.get_mode_at_operator(mode))
    M.state.change_type = constants.change_type.VISUAL
    vim.api.nvim_feedkeys("g@", "i", false)
  else
    M.state.change_type = constants.change_type.CURRENT_WORD
    vim.api.nvim_feedkeys("g@aw", "i", false)
  end
end

function M.open_telescope(filter)
  if vim.g.vscode then
    -- In vscode, Telescope isn't available, then Open the commands palette
    require("vscode-neovim").action("workbench.action.quickOpen", { args = { ">Transform to " } })
    return
  end

  local mode = vim.api.nvim_get_mode().mode
  M.state.telescope_previous_mode = mode
  M.state.telescope_previous_buffer = vim.api.nvim_get_current_buf()
  if filter == "quick_change" then
    vim.cmd("Telescope textcase normal_mode_quick_change")
  elseif filter == "lsp_change" then
    vim.cmd("Telescope textcase normal_mode_lsp_change")
  else
    if mode == "n" then
      vim.cmd("Telescope textcase normal_mode")
    else
      M.state.telescope_previous_visual_region = utils.get_visual_region(0, true, nil, utils.get_mode_at_operator(mode))
      vim.cmd("Telescope textcase visual_mode")
    end
  end
end

function M.replace_word_under_cursor(command)
  local current_word = vim.fn.expand("<cword>")
  vim.api.nvim_feedkeys(":" .. command .. "/" .. current_word .. "/", "i", false)
end

function M.replace_selection()
  print("TODO: pending implementation")
end

return M
