local test_helpers = require("tests.test_helpers")
local textcase = require("textcase")
local spy = require("luassert.spy")
local match = require("luassert.match")

local err_fn = vim.api.nvim_err_writeln
local get_active_clients_fn = vim.lsp.get_active_clients
local buf_request_all_fn = vim.lsp.buf_request_all
local buf_request_all_results = {}
local make_position_params_fn = vim.lsp.util.make_position_params
local get_client_by_id_fn = vim.lsp.get_client_by_id
local apply_workspace_edit_fn = vim.lsp.util.apply_workspace_edit

-- The spies override the default behavior of nvim.
-- If the tests are run in parallel there will be unexpected behaviors.
-- That's why the override does not happen into (before/after)_each statements
-- but as close as possible where they are required
describe("LSP renaming", function()
  describe("when no buffers are attached", function()
    local err_spy = nil

    before_each(function()
      textcase.setup({})

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_command("buffer " .. buf)

      err_spy = spy.new(function() end)
    end)

    it("should show an error message", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, true, { "plain text" })

      vim.api.nvim_err_writeln = err_spy
      test_helpers.execute_keys("<CMD>lua require('textcase').lsp_rename('to_upper_case')<CR>")
      vim.api.nvim_err_writeln = err_fn

      assert.spy(err_spy).was.called_with(match.has_match("No attached Language Server"))
    end)
  end)

  describe("LS textDocument/rename failure", function()
    local err_spy = nil
    local buf_request_all_spy = nil
    local make_position_params_spy = nil

    before_each(function()
      textcase.setup({})

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_command("buffer " .. buf)

      err_spy = spy.new(function() end)
      buf_request_all_spy = spy.new(function(buffer, method, params, callback)
        callback(buf_request_all_results)
      end)
      make_position_params_spy = spy.new(function()
        return {}
      end)
    end)

    local disabled_rename_method = function(method)
      if method == "textDocument/rename" then
        return false
      end
      return true
    end

    local all_methods_enabled = function()
      return true
    end

    it("should show an error when the LS do not support textDocument/rename", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, true, { "plain text" })

      local get_clients = function()
        return {
          {
            supports_method = disabled_rename_method,
          },
          {
            supports_method = disabled_rename_method,
          },
        }
      end

      vim.lsp.get_active_clients = get_clients
      vim.api.nvim_err_writeln = err_spy
      test_helpers.execute_keys("<CMD>lua require('textcase').lsp_rename('to_upper_case')<CR>")
      vim.lsp.get_active_clients = get_active_clients_fn
      vim.api.nvim_err_writeln = err_fn

      assert.spy(err_spy).was.called_with(match.has_match("method textDocument/rename is not supported"))
    end)

    it("shouldn't show an error when at least one LS supports textDocument/rename", function()
      local get_clients = function()
        return {
          {
            supports_method = all_methods_enabled,
          },
          {
            supports_method = disabled_rename_method,
          },
        }
      end

      vim.api.nvim_buf_set_lines(0, 0, -1, true, { "plain text" })

      vim.api.nvim_err_writeln = err_spy
      vim.lsp.get_active_clients = get_clients
      vim.lsp.buf_request_all = buf_request_all_spy
      vim.lsp.util.make_position_params = make_position_params_spy
      test_helpers.execute_keys("<CMD>lua require('textcase').lsp_rename('to_upper_case')<CR>")
      vim.lsp.get_active_clients = get_active_clients_fn
      vim.lsp.buf_request_all = buf_request_all_fn
      vim.lsp.util.make_position_params = make_position_params_fn
      vim.api.nvim_err_writeln = err_fn

      assert.spy(buf_request_all_spy).was.called_with(0, "textDocument/rename", match._, match._)
      assert.spy(err_spy).was.not_called()
    end)
  end)

  describe("LS textDocument/rename with multiple language server results", function()
    local err_spy = nil
    local buf_request_all_spy = nil
    local make_position_params_spy = nil
    local get_client_by_id_spy = nil
    local apply_workspace_edit_spy = nil
    local get_clients = nil

    before_each(function()
      textcase.setup({})

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_command("buffer " .. buf)

      err_spy = spy.new(function() end)
      get_client_by_id_spy = spy.new(function(id)
        local clients = {}
        clients["1"] = {
          id = 1,
          offset_encoding = "utf-8",
        }
        clients["2"] = {
          id = 2,
          offset_encoding = "utf-8",
        }
        return clients[id]
      end)
      buf_request_all_spy = spy.new(function(buffer, method, params, callback)
        callback(buf_request_all_results)
      end)
      make_position_params_spy = spy.new(function()
        return {}
      end)
      apply_workspace_edit_spy = spy.new(function()
        return {}
      end)
      get_clients = function()
        return {
          {
            supports_method = function()
              return true
            end,
          },
          {
            supports_method = function()
              return true
            end,
          },
        }
      end

      vim.api.nvim_err_writeln = err_spy
      vim.lsp.get_active_clients = get_clients
      vim.lsp.get_client_by_id = get_client_by_id_spy
      vim.lsp.buf_request_all = buf_request_all_spy
      vim.lsp.util.make_position_params = make_position_params_spy
      vim.lsp.util.apply_workspace_edit = apply_workspace_edit_spy
    end)

    after_each(function()
      vim.lsp.get_active_clients = get_active_clients_fn
      vim.lsp.buf_request_all = buf_request_all_fn
      vim.lsp.get_client_by_id = get_client_by_id_fn
      vim.lsp.util.make_position_params = make_position_params_fn
      vim.lsp.util.apply_workspace_edit = apply_workspace_edit_fn
      vim.api.nvim_err_writeln = err_fn
    end)

    describe("with different amount of changes", function()
      before_each(function()
        buf_request_all_results["1"] = {
          result = {
            changes = {
              ["file1"] = {},
            },
          },
        }
        buf_request_all_results["2"] = {
          result = {
            changes = {
              ["file1"] = {},
              ["file2"] = {},
            },
          },
        }
      end)

      it("should use the results from the language server that touches the most files", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { "plain text" })

        test_helpers.execute_keys("<CMD>lua require('textcase').lsp_rename('to_upper_case')<CR>")

        assert.spy(buf_request_all_spy).was.called_with(0, "textDocument/rename", match._, match._)
        assert.spy(apply_workspace_edit_spy).was.called_with({
          changes = {
            ["file1"] = {},
            ["file2"] = {},
          },
        }, "utf-8")
        assert.spy(err_spy).was.not_called()
      end)
    end)

    describe("with the same amount of changes", function()
      before_each(function()
        buf_request_all_results["1"] = {
          result = {
            changes = {
              ["file1"] = {},
              ["file2"] = {},
            },
          },
        }
        buf_request_all_results["2"] = {
          result = {
            changes = {
              ["file1"] = {},
              ["file2"] = {},
            },
          },
        }
      end)

      it("should use the results from the language server that touches the most files", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { "plain text" })

        test_helpers.execute_keys("<CMD>lua require('textcase').lsp_rename('to_upper_case')<CR>")

        assert.spy(buf_request_all_spy).was.called_with(0, "textDocument/rename", match._, match._)
        assert.spy(apply_workspace_edit_spy).was.called_with({
          changes = {
            ["file1"] = {},
            ["file2"] = {},
          },
        }, "utf-8")
        assert.spy(err_spy).was.not_called()
      end)
    end)
  end)

  describe("LSP changes and documentChanges", function()
    local err_spy = nil
    local buf_request_all_spy = nil
    local make_position_params_spy = nil
    local get_client_by_id_spy = nil
    local apply_workspace_edit_spy = nil
    local get_clients = nil

    before_each(function()
      textcase.setup({})

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_command("buffer " .. buf)

      err_spy = spy.new(function() end)
      get_client_by_id_spy = spy.new(function(id)
        local clients = {}
        clients["1"] = {
          id = 1,
          offset_encoding = "utf-8",
        }
        return clients[id]
      end)
      buf_request_all_spy = spy.new(function(buffer, method, params, callback)
        callback(buf_request_all_results)
      end)
      make_position_params_spy = spy.new(function()
        return {}
      end)
      apply_workspace_edit_spy = spy.new(function()
        return {}
      end)
      get_clients = function()
        return {
          {
            supports_method = function()
              return true
            end,
          },
        }
      end

      vim.api.nvim_err_writeln = err_spy
      vim.lsp.get_active_clients = get_clients
      vim.lsp.get_client_by_id = get_client_by_id_spy
      vim.lsp.buf_request_all = buf_request_all_spy
      vim.lsp.util.make_position_params = make_position_params_spy
      vim.lsp.util.apply_workspace_edit = apply_workspace_edit_spy
    end)

    after_each(function()
      vim.api.nvim_err_writeln = err_fn
      vim.lsp.get_active_clients = get_active_clients_fn
      vim.lsp.get_client_by_id = get_client_by_id_fn
      vim.lsp.buf_request_all = buf_request_all_fn
      vim.lsp.util.make_position_params = make_position_params_fn
      vim.lsp.util.apply_workspace_edit = apply_workspace_edit_fn
    end)

    it("should count `documentChanges` if it is set instead of `changes`", function()
      buf_request_all_results["1"] = {
        result = {
          documentChanges = {
            { "document change 1" },
            { "document change 2" },
          },
        },
      }
      vim.api.nvim_buf_set_lines(0, 0, -1, true, { "plain text" })

      test_helpers.execute_keys("<CMD>lua require('textcase').lsp_rename('to_upper_case')<CR>")

      assert.spy(buf_request_all_spy).was.called_with(0, "textDocument/rename", match._, match._)
      assert.spy(apply_workspace_edit_spy).was.called_with({
        documentChanges = {
          { "document change 1" },
          { "document change 2" },
        },
      }, "utf-8")
      assert.spy(err_spy).was.not_called()
    end)
  end)
end)
