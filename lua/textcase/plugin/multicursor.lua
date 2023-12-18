local M = {}

local case_variations = require("textcase.conversions.case-variations")
local utils = require("textcase.shared.utils")

-- Variables for occurrence tracking
local base_search = nil
local occurrence_locations = {}
local current_occurrence_index = 1
local previous_occurrences = {}
local highlight_group = "MyHighlightGroup"

utils.define_highlight_group(highlight_group)

function M.get_occurrence_locations()
  return occurrence_locations
end

function M.set_occurrence(index, value)
  local item = occurrence_locations[index]
  vim.api.nvim_buf_set_text(0, item.lineno - 1, item.start - 1, item.lineno - 1, item.start + #item.text, { value })
  occurrence_locations[index].text = value
  occurrence_locations[index].end_ = item.start + #item.text

  local start_idx = item.start
  local end_idx = item.end_
  local start_pos = { item.lineno, start_idx - 1 }
  local end_pos = { item.lineno, end_idx }
  utils.apply_highlight_to_range(0, highlight_group, start_pos, end_pos)
end

-- Function to escape special characters for regex
local function escape_for_pattern(str)
  local escaped_str, _ = str:gsub("([%-%.%+%[%]%(%)%*%?%^%$%%])", "%%%1")
  return escaped_str
end

-- Unified function to find, highlight, and navigate occurrences
function M.find_highlight_and_navigate()
  if base_search == nil then
    if vim.fn.mode() == "v" then
      local region = utils.get_visual_region(0, true)
      base_search =
        utils.nvim_buf_get_text(0, region.start_row - 1, region.start_col - 1, region.start_row - 1, region.end_col)[1]

      local lineno = region.start_row
      local initial_occurrence = {
        lineno = region.start_row,
        start = region.start_col,
        end_ = region.end_col,
        case = "uppercase",
        text = base_search,
      }
      local start_idx = region.start_col
      local end_idx = region.end_col
      table.insert(occurrence_locations, initial_occurrence)
      local start_pos = { lineno, start_idx - 1 }
      local end_pos = { lineno, end_idx }
      utils.apply_highlight_to_range(0, highlight_group, start_pos, end_pos)
    else
      base_search = utils.get_current_word_with_casings()
    end
  end

  local variations = case_variations.get_word_casing_variations(base_search)
  local escaped_variations = {}
  for _, variation in ipairs(variations) do
    table.insert(escaped_variations, escape_for_pattern(variation))
  end
  local word_pattern = table.concat(escaped_variations, "\\|")
  vim.print(word_pattern)

  -- Find occurrences in the buffer
  local next = vim.fn.searchpos(word_pattern)
  local lineno = next[1]
  local start_idx = next[2]
  local found_occurrence = nil
  local end_idx = nil
  if next ~= nil then
    local content = utils.nvim_buf_get_text(0, lineno - 1, start_idx - 1, lineno - 1, -1)[1]
    -- vim.print("content")
    -- vim.print(content)
    for _, variation in ipairs(variations) do
      -- vim.print("variation")
      -- vim.print(variation)
      if utils.start_with(content, variation) then
        end_idx = next[2] + #variation
        found_occurrence = {
          lineno = lineno,
          start = start_idx,
          end_ = end_idx,
          case = "uppercase",
          text = variation,
        }
        break
      end
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>ve", true, false, true), "n", false)
  end

  -- vim.print("found_occurrence")
  -- vim.print(found_occurrence)

  if found_occurrence then
    local start_pos = { lineno, start_idx - 1 }
    local end_pos = { lineno, end_idx - 1 }
    table.insert(occurrence_locations, found_occurrence)
    utils.apply_highlight_to_range(0, highlight_group, start_pos, end_pos)
  end
end

function M.highlight_occurrences()
  M.find_highlight_and_navigate()
end

-- Function to navigate to the next occurrence
function M.next_occurrence()
  M.find_highlight_and_navigate()
  -- if current_occurrence_index > #occurrence_locations then
  --   return
  -- end
  --
  -- local pos = occurrence_locations[current_occurrence_index]
  -- vim.fn.cursor(pos[1], pos[2])
  -- table.insert(previous_occurrences, pos)
  -- current_occurrence_index = current_occurrence_index + 1
end

-- Function to skip the current occurrence
function M.skip_current_occurrence()
  if current_occurrence_index > #occurrence_locations then
    return
  end

  table.remove(occurrence_locations, current_occurrence_index)
  M.highlight_occurrences() -- Re-highlight after skipping an occurrence
end

-- Function to remove the last matched item and return to the previous
function M.remove_last_matched_item()
  if #previous_occurrences > 0 then
    table.remove(previous_occurrences)
    current_occurrence_index = current_occurrence_index - 1
    M.highlight_occurrences() -- Re-highlight after removing an occurrence
  end
end

-- Function to clear highlights and reset tracking
function M.clear_highlights_and_reset()
  vim.cmd("syntax clear " .. highlight_group)
  occurrence_locations = {}
  current_occurrence_index = 1
  previous_occurrences = {}
end

-- Key mappings
vim.api.nvim_set_keymap(
  "n",
  "<C-d>",
  '<cmd>lua require("textcase").highlight_occurrences()<CR>',
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<C-s>",
  '<cmd>lua require("textcase").skip_current_occurrence()<CR>',
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "v",
  "<C-d>",
  '<cmd>lua require("textcase").highlight_occurrences()<CR>',
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<C-D>",
  '<cmd>lua require("textcase").remove_last_matched_item()<CR>',
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<Esc>",
  '<cmd>lua require("textcase").clear_highlights_and_reset()<CR>',
  { noremap = true, silent = true }
)

return M
