local test_helpers = require("tests.test_helpers")
local textcase = require("textcase")
local spy = require("luassert.spy")
local match = require("luassert.match")

local err_fn = vim.api.nvim_err_writeln
local get_active_clients_fn = vim.lsp.get_active_clients
local buf_request_fn = vim.lsp.buf_request
local make_position_params_fn = vim.lsp.util.make_position_params

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
    local buf_request_spy = nil
    local make_position_params_spy = nil

    before_each(function()
      textcase.setup({})

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_command("buffer " .. buf)

      err_spy = spy.new(function() end)
      buf_request_spy = spy.new(function() end)
      make_position_params_spy = spy.new(function()
        return {}
      end)
    end)

    after_each(function()
      vim.api.nvim_err_writeln = err_fn
      vim.lsp.util.make_position_params = make_position_params_fn
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
      vim.lsp.buf_request = buf_request_spy
      vim.lsp.util.make_position_params = make_position_params_spy
      test_helpers.execute_keys("<CMD>lua require('textcase').lsp_rename('to_upper_case')<CR>")
      vim.lsp.get_active_clients = get_active_clients_fn
      vim.lsp.buf_request = buf_request_fn
      vim.lsp.util.make_position_params = make_position_params_fn
      vim.api.nvim_err_writeln = err_fn

      assert.spy(err_spy).was.not_called()
    end)
  end)
end)
