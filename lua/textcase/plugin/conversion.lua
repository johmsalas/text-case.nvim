local utils = require("textcase.shared.utils")
local lsp = vim.lsp

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
  local lsp_clients = vim.lsp.get_active_clients()
  local clients_count = vim.tbl_count(lsp_clients)

  local handleLSPRenameFinished = function(applied_lsp_rename, reason)
    if not applied_lsp_rename then
      vim.api.nvim_err_writeln(reason)
    end
  end

  local is_lsp_rename_supported = false
  for _, client in pairs(lsp_clients or {}) do
    if client.supports_method("textDocument/rename") then
      is_lsp_rename_supported = true
    end
  end

  -- On LSP Sync Renaming happens when there are no attached clients
  if clients_count == 0 then
    handleLSPRenameFinished(false, "LSP rename failed. No attached Language Server found.")
  elseif not is_lsp_rename_supported then
    handleLSPRenameFinished(
      false,
      "method textDocument/rename is not supported by any of the servers registered for the current buffer"
    )
  else
    local current_word = vim.fn.expand("<cword>")
    local params = lsp.util.make_position_params()
    params.newName = method(current_word)

    lsp.buf_request_all(0, "textDocument/rename", params, function(results)
      local total_files = 0
      for client_id, response in pairs(results) do
        if not response.error then
          local client = vim.lsp.get_client_by_id(client_id)
          vim.lsp.util.apply_workspace_edit(response.result, client.offset_encoding)

          -- after the edits are applied, the files are not saved automatically.
          -- let's remind ourselves to save those...
          -- TODO: This will be modified to include only one of the clients count
          total_files = vim.tbl_count(response.result.changes)
        end
      end
      print(string.format("Changed %s file%s. To save them run ':wa'", total_files, total_files > 1 and "s" or ""))
    end)
  end
end

return M
