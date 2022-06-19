local plugin = require('textcase.plugin.plugin')
local constants = require("textcase.shared.constants")
local api = require('textcase').api
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function invoke_replacement(prompt_bufnr)
  return function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local change = selection.value
    if type(change) ~= 'table' then return end

    if change.type == constants.change_type.CURRENT_WORD then
      plugin.current_word(change.method_desc)
    elseif change.type == constants.change_type.LSP_RENAME then
      plugin.lsp_rename(change.method_desc)
    elseif change.type == constants.change_type.VISUAL then
      plugin.visual(change.method_desc)
    end
  end
end

local function telescope_normal_mode_change(opts)
  opts = opts or require("telescope.themes").get_cursor()
  local results = {}

  for _, method in pairs({
    api.to_upper_case,
    api.to_lower_case,
    api.to_snake_case,
    api.to_dash_case,
    api.to_constant_case,
    api.to_dot_case,
    api.to_phrase_case,
    api.to_camel_case,
    api.to_pascal_case,
    api.to_title_case,
    api.to_path_case,
  }) do
    local current_word_table = {
      display = 'Convert to ' .. method.desc,
      method_desc = method.desc,
      type = constants.change_type.CURRENT_WORD,
    }

    local lsp_replace_table = {
      display = 'LSP rename ' .. method.desc,
      method_desc = method.desc,
      type = constants.change_type.LSP_RENAME,
    }

    table.insert(results, current_word_table)
    table.insert(results, lsp_replace_table)
  end

  require("telescope.pickers").new(opts, {
    prompt_title = "Text Case",
    finder = require("telescope.finders").new_table({
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = require("telescope.config").values.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      local curried_method = invoke_replacement(prompt_bufnr)
      map("i", "<CR>", curried_method)
      map("n", "<CR>", curried_method)
      return true
    end,
  }):find()
end

local function telescope_visual_mode_change(opts)
  opts = opts or require("telescope.themes").get_cursor()
  local results = {}

  for _, method in pairs({
    api.to_upper_case,
    api.to_lower_case,
    api.to_snake_case,
    api.to_dash_case,
    api.to_constant_case,
    api.to_dot_case,
    api.to_phrase_case,
    api.to_camel_case,
    api.to_pascal_case,
    api.to_title_case,
    api.to_path_case,
  }) do
    local visual_replace_table = {
      display = 'Convert to ' .. method.desc,
      method_desc = method.desc,
      type = constants.change_type.VISUAL,
    }

    table.insert(results, visual_replace_table)
  end

  require("telescope.pickers").new(opts, {
    prompt_title = "Text Case",
    finder = require("telescope.finders").new_table({
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = require("telescope.config").values.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      local curried_method = invoke_replacement(prompt_bufnr)
      map("i", "<CR>", curried_method)
      map("n", "<CR>", curried_method)
      return true
    end,
  }):find()
end

return require("telescope").register_extension({
  exports = {
    normal_mode = telescope_normal_mode_change,
    visual_mode = telescope_visual_mode_change,
  },
})
