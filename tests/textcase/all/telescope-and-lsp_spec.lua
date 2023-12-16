local feature_flags = require("feature_flags")
if not feature_flags.is_feature_available("telescope") then
  return
end

local test_helpers = require("tests.test_helpers")
local textcase = require("textcase")

describe("Telescope and LSP", function()
  describe("Rename case conversion", function()
    before_each(function()
      textcase.setup({})
      require("telescope").load_extension("textcase")
      vim.api.nvim_set_keymap("n", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })

      local path = "./tests/textcase/all/fixtures/camel-case.ts"
      local cmd = " silent exe 'e " .. path .. "'"
      vim.cmd(cmd)
      vim.bo.filetype = "typescript"

      test_helpers.wait_for_language_server_to_start()
    end)

    after_each(function()
      -- Close the buffer so the next test can open it again.
      vim.cmd("silent exe 'bd! %'")
    end)

    it("Should open Telescope and apply snake case LSP conversion", function()
      test_helpers.execute_keys("/variableToBeTested<CR>")
      test_helpers.execute_keys("ga.")
      test_helpers.execute_keys("ilspsnk", "xmt")
      vim.wait(50, function() end)
      test_helpers.execute_keys("<CR>")
      -- test_helpers.execute_keys("i" .. "lspsnk", "xmt")
      local content = nil
      test_helpers.wait_for(5 * 1000, function()
        content = test_helpers.get_buf_lines()
        local found_modified_variable = not not string.find(content[2], "variable_to_be_tested")
        return found_modified_variable
      end)

      local expected_code = test_helpers.read_file("./tests/textcase/lsp/fixtures/snake-case.ts")
      assert.are.same(expected_code, table.concat(content, "\n"))
    end)
  end)
end)
