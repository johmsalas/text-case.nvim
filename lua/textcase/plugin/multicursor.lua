local M = {}

local case_variations = require("textcase.conversions.case-variations")
local utils = require("textcase.shared.utils")

-- Variables for occurrence tracking
local base_search = nil
local occurrence_locations = {}
local current_occurrence_index = 1
local previous_occurrences = {}
local highlight_group = "MyHighlightGroup"

local ns = vim.api.nvim_create_namespace(highlight_group)
utils.define_highlight_group(highlight_group)

function M.get_occurrence_locations()
  return occurrence_locations
end

function M.set_occurrence(index, value)
  local item = occurrence_locations[index]

  local line = item.lineno - 1
  local start_idx = item.start - 1
  local end_idx = start_idx + #item.text
  vim.api.nvim_buf_clear_namespace(0, -1, line - 1, line - 2)
  vim.api.nvim_buf_set_text(0, line, start_idx, line, end_idx, { value })
  occurrence_locations[index].text = value
  occurrence_locations[index].end_ = end_idx

  local start_pos = { line + 1, start_idx }
  local end_pos = { line + 1, end_idx }
  utils.apply_highlight_to_range(0, highlight_group, start_pos, end_pos)
end

local function dec(value)
  return value - 1
end

function M.add_occurrence(occurrence)
  local buf = vim.api.nvim_get_current_buf()
  local start = occurrence.start
  local end_ = occurrence.end_
  local line = occurrence.lineno

  local id = vim.api.nvim_buf_set_extmark(buf, ns, dec(line), dec(start), {
    -- virt_text = { { ch_at_curpos, "Cursor" } },
    -- virt_text_pos = "overlay",
    hl_mode = "combine",
    -- priority = self.priority.cursor,
  })

  occurrence.id = id
  occurrence.buf = buf
  local start_pos = { line, dec(start) }
  local end_pos = { line, dec(end_) }

  utils.apply_highlight_to_range(0, highlight_group, start_pos, end_pos)
  return table.insert(occurrence_locations, occurrence)
end

-- Function to escape special characters for regex
local function escape_for_pattern(str)
  local escaped_str, _ = str:gsub("([%.%+%[%]%(%)%*%?%^%$%%])", "%%%1")
  return escaped_str
end

local function initialize_multicursor()
  vim.api.nvim_exec(
    [[
        augroup TextCaseMultiCursor
          autocmd!
          autocmd InsertLeave * lua require('textcase.plugin.multicursor').reset()
        augroup END
      ]],
    false
  )
end

-- Unified function to find, highlight, and navigate occurrences
function M.find_highlight_and_navigate()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

  if base_search == nil then
    if vim.fn.mode() == "v" then
      local region = utils.get_visual_region(0, true)
      base_search =
        utils.nvim_buf_get_text(0, region.start_row - 1, region.start_col - 1, region.start_row - 1, region.end_col)[1]

      -- local lineno = region.start_row
      local initial_occurrence = {
        lineno = region.start_row,
        start = region.start_col,
        end_ = region.end_col + 1,
        case = "uppercase",
        text = base_search,
      }
      -- local start_idx = region.start_col
      -- local end_idx = region.end_col
      M.add_occurrence(initial_occurrence)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

      -- local start_pos = { lineno, start_idx - 1 }
      -- local end_pos = { lineno, end_idx }
      -- utils.apply_highlight_to_range(0, highlight_group, start_pos, end_pos)
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

  -- Find occurrences in the buffer
  local next = vim.fn.searchpos(word_pattern)
  -- local next = nil
  -- vim.print(word_pattern)
  -- vim.print(next)
  local found_occurrence = nil
  local end_idx = nil
  if next ~= nil and next[1] > 0 and next[2] > 0 then
    local lineno = next[1]
    local start_idx = next[2]
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
  end

  -- vim.print("found_occurrence")
  -- vim.print(found_occurrence)

  if found_occurrence then
    M.add_occurrence(found_occurrence)
    -- vim.schedule_wrap(function()
    local length = #found_occurrence.text
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>v" .. dec(length) .. "l", true, false, true), "n", false)
    -- end)
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
function M.clear_highlights()
  vim.cmd("hi clear " .. highlight_group)
end

-- Function to clear highlights and reset tracking
function M.reset()
  vim.cmd("hi clear " .. highlight_group)
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
vim.api.nvim_set_keymap(
  "n",
  "<leader><esc>",
  '<cmd>lua require("textcase.plugin.multicursor").reset()<CR>',
  { noremap = true, silent = true }
)

return M
