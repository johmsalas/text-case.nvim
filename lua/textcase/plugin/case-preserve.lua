local M = {}

local multicursor = require("textcase.plugin.multicursor")
local stringcase = require("textcase.conversions.stringcase")

-- Variables to store initially inserted and canceled text
local initial_insert_text = {}
local canceled_text = {}
local user_action = true

-- Variable to track whether inserting while preserving case is active
local inserting_preserving_case_active = false

-- Function to start inserting while preserving case
function M.start_inserting_preserving_case()
  if not inserting_preserving_case_active then
    initial_insert_text = {}
    canceled_text = {}
    inserting_preserving_case_active = true

    -- clean multicursor locations
    local cursors = multicursor.get_occurrence_locations()
    local line_number = vim.api.nvim_win_get_cursor(0)[1]
    for i, cursor in ipairs(cursors) do
      if cursor.lineno ~= line_number then
        -- vim.print("cursor")
        -- vim.print(cursor)
        multicursor.set_occurrence(i, "")
      end
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>bvec", true, false, true), "n", false)
    vim.api.nvim_exec(
      [[
        augroup InsertPreservingCase
          autocmd!
          autocmd TextChangedI * lua require('textcase').insert_preserving_case()
          autocmd InsertLeave * lua require('textcase').leave_insert_mode()
        augroup END
      ]],
      false
    )
  end
end

-- Function to stop inserting while preserving case
function M.stop_inserting_preserving_case()
  if inserting_preserving_case_active then
    vim.api.nvim_exec(
      [[
            augroup InsertPreservingCase
                autocmd!
            augroup END
        ]],
      false
    )
    inserting_preserving_case_active = false
  end
end

function M.compute_inserted_diff(initial_text, current_line)
  local initial_text_length = #initial_text
  local current_text_length = #current_line

  -- Find the start of the difference
  local start_diff_index = nil
  for i = 1, math.min(initial_text_length, current_text_length) do
    if current_line:sub(i, i) ~= initial_text:sub(i, i) then
      start_diff_index = i
      break
    end
  end

  if not start_diff_index then
    -- No difference found or the current_line is a substring of initial_text
    return ""
  end

  -- Find the end of the difference
  local end_diff_index = start_diff_index
  while end_diff_index <= current_text_length do
    local offset = end_diff_index - start_diff_index + 1
    if
      initial_text:sub(start_diff_index, start_diff_index + offset)
      == current_line:sub(end_diff_index + 1, end_diff_index + 1 + offset)
    then
      break
    end
    end_diff_index = end_diff_index + 1
  end

  return current_line:sub(start_diff_index, end_diff_index)
end

-- Function to handle inserting while preserving case
function M.insert_preserving_case()
  if user_action then
    if #initial_insert_text == 0 then
      initial_insert_text = vim.api.nvim_get_current_line()
    end

    -- local char = vim.api.nvim_get_vvar("char")
    -- if char == "" then
    -- return
    -- end -- Handling edge case for empty char

    -- vim.v.char = ""

    vim.schedule(function()
      local line_number = vim.api.nvim_win_get_cursor(0)[1]
      local current_line = vim.api.nvim_get_current_line()
      local diff_text = M.compute_inserted_diff(initial_insert_text, current_line)
      -- vim.print("----------------------------")
      -- vim.print(initial_insert_text)
      -- vim.print(current_line)
      -- vim.print(diff_text)
      local transformed_text = stringcase.to_camel_case(diff_text)
      local cursors = multicursor.get_occurrence_locations()
      -- multicursor.clear_highlights()
      for i, cursor in ipairs(cursors) do
        -- vim.print("cursor")
        -- vim.print(cursor)
        if cursor.lineno ~= line_number then
          -- vim.print(cursor.lineno)
          user_action = false
          multicursor.set_occurrence(i, transformed_text)
          user_action = true
        end
      end
    end)
  else
    user_action = true
  end
end

-- Function to handle leaving insert mode
function M.leave_insert_mode()
  -- Get the text that was canceled during insert mode
  canceled_text = { initial_insert_text }
  multicursor.clear_highlights_and_reset()

  -- Reset the initial_insert_text variable
  initial_insert_text = {}

  -- Optionally, replace canceled_text with another text
  local replacement_text = "Replacement Text"

  -- Replace the canceled text with replacement text
  -- local line = vim.fn.line(".")
  -- vim.api.nvim_set_current_line(
  --   vim.api.nvim_get_current_line():gsub(vim.fn.escape(canceled_text[1], "/"), vim.fn.escape(replacement_text, "/"))
  -- )
end

-- function M.start_changing_word_preserving_case()
--   local current_word_info = utils.get_current_word_info()
--   -- local case = utils.attemp_to_read_used_text_case(current_word_info.word)
--   local case = "constant_case"
--   M.start_inserting_preserving_case()
--   vim.api.nvim_feedkeys("ciw", "i", false)
-- end

vim.api.nvim_set_keymap(
  "v",
  "gax",
  '<cmd>lua require("textcase").start_inserting_preserving_case()<CR>',
  { noremap = true, silent = true }
)

return M
