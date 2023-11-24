local test_helpers = require("tests.test_helpers")
local textcase = require("textcase")

describe("LSP", function()
  describe("Rename", function()
    before_each(function()
      textcase.setup({})
    end)

    it("Should be triggered on keybinding", function()
      local path = "./tests/textcase/lsp/fixtures/component-camel-case.tsx"
      local cmd = " silent exe 'e " .. path .. "'"
      vim.cmd(cmd)
      vim.bo.filetype = "typescriptreact"
      -- allow tsserver start

      local ts_server_started = false
      test_helpers.wait_for(30 * 1000, function()
        vim.cmd("LspInfo")
        ts_server_started = not not vim.fn.search("1 client(s) attached to this buffer")
        test_helpers.execute_keys("q")
        return ts_server_started
      end)

      assert.is.truthy(ts_server_started)
      vim.wait(1000, function() end)

      test_helpers.execute_keys("/variableToBeTested<CR>gaS")
      local content = nil
      M.wait_for(5 * 1000, function()
        content = test_helpers.get_buf_lines()
        local found_modified_variable = not not string.find(content[4], "variable_to_be_tested")
        return found_modified_variable
      end)

      local expected_code = test_helpers.read_file("./tests/textcase/lsp/fixtures/component-snake-case.tsx")
      assert.are.same(table.concat(content, "\n"), expected_code)
    end)
  end)
end)
