local utils = require("textcase.shared.utils")
local lsp = vim.lsp

local flag_buf_request_all = vim.fn.has("nvim-0.10") == 1

local M = {}

function M.replace_matches(match, source, dest, try_lsp, buf)
  if utils.is_empty_position(match) then
    return
  end
  buf = buf or 0

  local row, start_col = match[1] - 1, match[2] - 1
  local source_end_col = start_col + string.len(source)
  local current = utils.nvim_buf_get_text(buf, row, start_col, row, source_end_col)
  if current[1] == source then
    if try_lsp then
      -- not used yet, hard coded to false
      local params = lsp.util.make_position_params()
      params.newName = dest
      lsp.buf_request(buf, "textDocument/rename", params)
    else
      vim.api.nvim_buf_set_text(buf, row, start_col, row, source_end_col, { dest })
    end
  end
end

function M.do_substitution(start_row, start_col, end_row, end_col, method, buf)
  buf = buf or 0
  local lines = utils.nvim_buf_get_text(buf, start_row - 1, start_col - 1, end_row - 1, end_col)

  local transformed = utils.map(lines, method)

  local cursor_pos = vim.fn.getpos(".")
  vim.api.nvim_buf_set_text(buf, start_row - 1, start_col - 1, end_row - 1, end_col, transformed)
  local new_cursor_pos = cursor_pos
  if cursor_pos[1] ~= start_row or (cursor_pos[2] < start_col) then
    new_cursor_pos = { 0, start_row, start_col }
  end
  vim.fn.setpos(".", new_cursor_pos)
end

function M.do_block_substitution(start_row, start_col, end_row, end_col, method)
  local cursor_pos = vim.fn.getpos(".")

  local s_col = start_col - 1
  local e_col = end_col

  for row = start_row - 1, end_row - 1 do
    local line_text = vim.fn.getline(row + 1)
    local line_e_col = math.min(line_text:len() - 1, e_col)
    if line_text:len() > 0 then
      local lines = utils.nvim_buf_get_text(0, row, s_col, row, line_e_col)
      local transformed = utils.map(lines, method)
      vim.api.nvim_buf_set_text(0, row, s_col, row, line_e_col, transformed)
    end
  end

  local new_cursor_pos = cursor_pos
  if cursor_pos[1] ~= start_row or (cursor_pos[2] < start_col) then
    new_cursor_pos = { 0, start_row, start_col }
  end
  vim.fn.setpos(".", new_cursor_pos)
end

function M.do_lsp_rename(method)
  local did_apply_lsp_rename = false

  local lsp_clients = vim.lsp.get_active_clients()

  local lsp_handler_rename = vim.lsp.handlers["textDocument/rename"]
  local handleLSPRenameFinished = function(applied_lsp_rename, reason)
    reason = reason or "LSP rename failed. Verify attached Language Servers support it."
    if not applied_lsp_rename then
      vim.api.nvim_err_writeln(reason)
    end
  end

  local current_word = vim.fn.expand("<cword>")
  local params = lsp.util.make_position_params()
  params.newName = method(current_word)
  if flag_buf_request_all then
    lsp.buf_request_all(0, "textDocument/rename", params, function(results)
      for _, res in pairs(results or {}) do
        if res.result and vim.tbl_count(res.result.changes) > 0 then
          -- TODO: Call default handler
          -- lsp_handler_rename(res.result.err, result, context)
          did_apply_lsp_rename = true
        end
      end
      handleLSPRenameFinished(did_apply_lsp_rename)
    end)
  else
    local processed_clients = 0
    local clients_count = vim.tbl_count(lsp_clients)
    lsp.buf_request(0, "textDocument/rename", params, function(err, result, context)
      lsp_handler_rename(err, result, context)

      processed_clients = processed_clients + 1
      if not err then
        did_apply_lsp_rename = true
      end

      -- On LSP Async Renaming happens when there are attached clients
      if processed_clients == clients_count then
        handleLSPRenameFinished(did_apply_lsp_rename)
      end
    end)

    -- On LSP Sync Renaming happens when there are no attached clients
    if clients_count == 0 then
      handleLSPRenameFinished(false, "LSP rename failed. No attached Language Servers found.")
    end
  end
end

return M
