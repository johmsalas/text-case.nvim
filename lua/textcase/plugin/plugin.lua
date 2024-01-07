local utils = require("textcase.shared.utils")
local constants = require("textcase.shared.constants")
local conversion = require("textcase.plugin.conversion")
local stringcase = require("textcase.conversions.stringcase")
local flag_incremental_preview = vim.fn.has("nvim-0.8-dev+374-ge13dcdf16") == 1

local M = {}

M.state = {
  register = nil,
  methods_by_method_name = {},
  change_type = nil,
  current_method = nil, -- Since curried vim func operators are not yet supported
  match = nil,
  substitute = {},
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
        mode = "v"
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
    vim.keymap.set("v", keybind, command, { desc = desc })
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

function M.register_replace_command(command)
  -- The registered command for Subs replacements depends on the
  -- availability of the "incremental command preview" feature
  -- https://github.com/neovim/neovim/pull/18194
  if flag_incremental_preview then
    vim.api.nvim_create_user_command(
      command,
      M.incremental_substitute,
      { nargs = "?", range = "%", addr = "lines", preview = M.incremental_substitute }
    )
  else
    vim.cmd([[
      command! -range -nargs=? ]] .. command .. [[ <line1>,<line2>call TextCaseSubstituteLauncher(<q-args>)
    ]])
  end
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

-- This method is called for previewing the result and also
-- for computing the final result and to modify the buffer
-- with the replacements

-- Sample for preview mode:
-- :Subs/source/dest
-- In this case preview ~= nil and preview_buf ~= nil

-- Sample for final replacement
-- :Subs/source/dest<CR>
-- In this case preview_ns == nil and preview_buf == nil

-- <cmd>h command-preview
function M.incremental_substitute(opts, preview_ns, preview_buf)
  -- preview_ns and preview_buf indicates the buffer to be modified
  local buf = (preview_ns ~= nil) and preview_buf or vim.api.nvim_get_current_buf()

  local range_start_mark = vim.api.nvim_buf_get_mark(buf, "<")
  local range_end_mark = vim.api.nvim_buf_get_mark(buf, ">")

  local visual_mode = "\22" -- Visual block mode as default
  if range_start_mark[2] > 1000000 or range_end_mark[2] > 1000000 then
    -- If one of the mark has a huge value, it means that "the range
    -- goes until the end of lines" aka Visual line mode
    visual_mode = "v" -- Visual line mode
  end

  -- Equivalent to the method TextCaseSubstituteLauncher (start.vim) computing
  -- if it is a multiline selection to use either normal or visual mode.
  --
  -- If the count is -1, it means that the command was NOT called from a visual
  -- mode. We only care about visual modes or normal mode, so we can set the
  -- mode to "n" in that case.
  local mode = opts.count == -1 and "n" or visual_mode
  local params = vim.split(opts.args, "/")
  local source, dest = params[2], params[3]
  source = MixStringConectors(source)
  dest = MixStringConectors(dest or "")

  local cursor_pos = vim.fn.getpos(".")
  vim.api.nvim_buf_clear_namespace(buf, 1, 0, -1)

  -- Create a map from transformed source to method name in order to prevent
  -- double replacements when two methods would yield the same result.
  --
  -- Examples for this are:
  --   - to_lower_case and to_snake_case
  --   - to_upper_case and to_constant_case
  local method_names_by_transform_result = {}
  for _, method in pairs(M.state.methods_by_method_name) do
    local transformed_source = method.apply(source)
    method_names_by_transform_result[transformed_source] = method.method_name
  end
  -- The filtered_method_names list contains all methods that are allowed to be applied.
  -- This is a map for faster lookups.
  local filtered_method_names = {}
  for _, method_name in pairs(method_names_by_transform_result) do
    filtered_method_names[method_name] = true
  end

  for _, method in pairs(M.state.methods_by_method_name) do
    -- Skip methods that would yield the same result as another method
    if filtered_method_names[method.method_name] == true then
      local transformed_source = method.apply(source)
      local transformed_dest = dest == "" and "" or method.apply(dest)

      local get_match = utils.get_list(utils.escape_string(transformed_source), mode)
      for match in get_match do
        local match_is_inside_visual_range = match[1] >= opts.line1 and match[1] <= opts.line2

        if match_is_inside_visual_range then
          if dest ~= "" then
            conversion.replace_matches(match, transformed_source, transformed_dest, false, buf)
          end
          local length = transformed_dest == "" and #transformed_source or #transformed_dest
          if preview_ns ~= nil then
            vim.api.nvim_buf_add_highlight(buf, preview_ns, "Search", match[1] - 1, match[2] - 1, match[2] - 1 + length)
          end
        end
      end
    end
  end

  vim.fn.setpos(".", cursor_pos)

  if preview_ns ~= nil then
    -- 2: Preview is shown and preview window is opened
    return 2
  end
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
  vim.api.nvim_feedkeys("g@iw", "i", false)
end

function M.current_word(case_method)
  M.state.register = vim.v.register
  M.state.current_method = case_method
  M.state.change_type = constants.change_type.CURRENT_WORD

  vim.o.operatorfunc = "v:lua.require'" .. constants.namespace .. "'.operator_callback"
  vim.api.nvim_feedkeys("g@aw", "i", false)
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

function M.start_replacing_command()
  local mode = vim.api.nvim_get_mode().mode
  M.state.telescope_previous_mode = mode
  M.state.telescope_previous_buffer = vim.api.nvim_get_current_buf()

  if mode == "n" then
    local current_word = vim.fn.expand("<cword>")
    vim.api.nvim_feedkeys(":Subs/" .. current_word .. "/", "i", true)
  else
    local region = utils.get_visual_region(0, true)
    local text =
      utils.nvim_buf_get_text(0, region.start_row - 1, region.start_col - 1, region.start_row - 1, region.end_col)

    local clean_range_key = vim.api.nvim_replace_termcodes("<C-u>", true, false, true)
    vim.api.nvim_feedkeys(":" .. clean_range_key .. "Subs/" .. text[1] .. "/", "i", false)
  end
end

-- This function is like start_replacing_command but it only uses <opts.parts_count> parts
-- for the Subs command. For example, if the current word is "LoremIpsumDolorSit" and
-- <opts.parts_count> is 2 and the cursor is on the first part, then the prefille dSubs command
-- will be ":Subs/LoremIpsum/".
--
-- For more examples, see the tests.
--
-- The keybindings to make use of this could be the following:
-- vim.api.nvim_set_keymap("n", "gar", "<cmd>lua require('textcase').start_replacing_command_with_part({ parts_count = 1 })<CR>", {})
-- vim.api.nvim_set_keymap("n", "ga2r", "<cmd>lua require('textcase').start_replacing_command_with_part({ parts_count = 2 })<CR>", {})
-- vim.api.nvim_set_keymap("n", "ga3r", "<cmd>lua require('textcase').start_replacing_command_with_part({ parts_count = 3 })<CR>", {})
--
-- Then you can use "gar" to use the Subs command with the current part of the current word
-- and "ga2r" to use the Subs command with the current part and the next part of the current word.
-- And so on ...
function M.start_replacing_command_with_part(opts)
  local parts_count = opts.parts_count or 1

  local mode = vim.api.nvim_get_mode().mode
  M.state.telescope_previous_mode = mode
  M.state.telescope_previous_buffer = vim.api.nvim_get_current_buf()

  if mode == "n" then
    local current_word = vim.fn.expand("<cword>")
    local cursor_pos = M.get_cursor_position_in_word()
    local parts = stringcase.to_parts(current_word)

    -- Check on which part of the word the cursor is and assign it to current_part_index
    local current_word_pos = 0
    local current_part_index = 0
    for index, part in ipairs(parts) do
      current_word_pos = current_word_pos + #part
      if cursor_pos <= current_word_pos then
        current_part_index = index
        break
      end
    end

    -- Use parts_count to construct the current part
    local subs_first_arg = ""
    for i = 1, parts_count do
      subs_first_arg = subs_first_arg .. " " .. parts[current_part_index + i - 1]
    end

    vim.api.nvim_feedkeys(":Subs/" .. subs_first_arg .. "/", "i", true)
  else
    M.start_replacing_command()
  end
end

function M.get_cursor_position_in_word()
  local current_word = vim.fn.expand("<cword>")
  -- Get the cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  -- local row = cursor_pos[1]
  local col = cursor_pos[2] + 1

  -- Get the current line
  local line = vim.api.nvim_get_current_line()

  -- Find the bounds of the current word
  -- Adjust the pattern as needed to define what you consider a word
  local word_start, word_end = line:find(current_word)

  if word_start and word_end then
    -- Calculate the position in the word
    local pos_in_word = col - word_start + 2 -- Lua is 1-indexed
    return pos_in_word
  else
    return nil -- Cursor is not on a word
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
