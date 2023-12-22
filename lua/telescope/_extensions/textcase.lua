local plugin = require("textcase.plugin.plugin")
local utils = require("textcase.shared.utils")
local presets = require("textcase.plugin.presets")
local constants = require("textcase.shared.constants")
local api = require("textcase").api
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function invoke_replacement(prompt_bufnr)
  return function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    if not selection then
      return
    end
    local change = selection.value
    if type(change) ~= "table" then
      return
    end

    if change.type == constants.change_type.CURRENT_WORD then
      plugin.current_word(change.method_name)
    elseif change.type == constants.change_type.LSP_RENAME then
      plugin.lsp_rename(change.method_name)
    elseif change.type == constants.change_type.VISUAL then
      plugin.visual(change.method_name)
    end
  end
end

local function Create_resulting_cases(prefix_text, conversion_type)
  local results = {}

  for _, method in pairs(utils.get_text_cases(presets)) do
    if presets.options.enabled_methods_set[method.method_name] then
      table.insert(results, {
        display = prefix_text .. method.desc,
        method_name = method.method_name,
        type = conversion_type,
      })
    end
  end

  return results
end

local function telescope_normal_mode_quick_change(opts)
  opts = opts or require("telescope.themes").get_cursor()
  local results = Create_resulting_cases("Convert to ", constants.change_type.CURRENT_WORD)

  require("telescope.pickers")
    .new(opts, {
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
    })
    :find()
end

local function telescope_normal_mode_lsp_change(opts)
  opts = opts or require("telescope.themes").get_cursor()
  local results = Create_resulting_cases("LSP rename ", constants.change_type.LSP_RENAME)

  require("telescope.pickers")
    .new(opts, {
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
    })
    :find()
end

local function telescope_normal_mode_change(opts)
  opts = opts or require("telescope.themes").get_cursor()
  local resultsQuickConversion = Create_resulting_cases("Convert to ", constants.change_type.CURRENT_WORD)
  local resultsLSPConversion = Create_resulting_cases("LSP rename ", constants.change_type.LSP_RENAME)

  local results = {}
  local k = 1
  for _, v in pairs(resultsQuickConversion) do
    results[k] = v
    k = k + 1
  end
  for _, v in pairs(resultsLSPConversion) do
    results[k] = v
    k = k + 1
  end

  require("telescope.pickers")
    .new(opts, {
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
    })
    :find()
end

local function telescope_visual_mode_change(opts)
  opts = opts or require("telescope.themes").get_cursor()

  local results = Create_resulting_cases("Convert to ", constants.change_type.VISUAL)

  require("telescope.pickers")
    .new(opts, {
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
    })
    :find()
end

return require("telescope").register_extension({
  exports = {
    normal_mode = telescope_normal_mode_change,
    visual_mode = telescope_visual_mode_change,
    normal_mode_quick_change = telescope_normal_mode_quick_change,
    normal_mode_lsp_change = telescope_normal_mode_lsp_change,
    textcase = telescope_normal_mode_change,
  },
})
