local test_helpers = require("tests.test_helpers")
local textcase = require("textcase")
local spy = require("luassert.spy")
local match = require("luassert.match")

local err_fn = vim.api.nvim_err_writeln

describe("LSP renaming", function()
  describe("when no buffers are attached", function()
    local err_spy = nil

    before_each(function()
      textcase.setup({})

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_command("buffer " .. buf)

      err_spy = spy.new(function() end)
      vim.api.nvim_err_writeln = err_spy
    end)

    after_each(function()
      vim.api.nvim_err_writeln = err_fn
    end)

    it("should show an error message", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, true, { "plain text" })
      test_helpers.execute_keys("<CMD>lua require('textcase').lsp_rename('to_upper_case')<CR>")
      assert.spy(err_spy).was.called_with(match.has_match("No attached Language Servers"))
    end)
  end)

  describe("when there are attached buffers", function()
    local err_spy = nil

    before_each(function()
      textcase.setup({})

      local path = "./tests/textcase/lsp/fixtures/camel-case.ts"
      local cmd = " silent exe 'e " .. path .. "'"
      vim.cmd(cmd)
      vim.bo.filetype = "typescript"

      test_helpers.wait_for_language_server_to_start()

      err_spy = spy.new(function() end)
      vim.api.nvim_err_writeln = err_spy
    end)

    after_each(function()
      vim.api.nvim_err_writeln = err_fn
      vim.cmd("silent exe 'bd! %'")
    end)

    it("should not show an error message", function()
      test_helpers.execute_keys("/variableToBeTested<CR>gaS")
      local content = nil
      test_helpers.wait_for(5 * 1000, function()
        content = test_helpers.get_buf_lines()
        local found_modified_variable = not not string.find(content[2], "variable_to_be_tested")
        return found_modified_variable
      end)

      local expected_code = test_helpers.read_file("./tests/textcase/lsp/fixtures/snake-case.ts")
      assert.are.same(table.concat(content, "\n"), expected_code)

      assert.spy(err_spy).was.not_called()
    end)
  end)
end)
