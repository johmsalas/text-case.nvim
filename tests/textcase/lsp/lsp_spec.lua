local test_helpers = require("tests.test_helpers")
local textcase = require("textcase")

describe("LSP", function()
  describe("Rename case conversion", function()
    before_each(function()
      textcase.setup({})

      local path = "./tests/textcase/lsp/fixtures/camel-case.ts"
      local cmd = " silent exe 'e " .. path .. "'"
      vim.cmd(cmd)
      vim.bo.filetype = "typescript"

      test_helpers.wait_for_language_server_to_start()
    end)

    after_each(function()
      -- Close the buffer so the next test can open it again.
      vim.cmd("silent exe 'bd! %'")
    end)

    it("Should be triggered on keybinding for snake case", function()
      test_helpers.execute_keys("/variableToBeTested<CR>gaS")
      local content = nil
      test_helpers.wait_for(5 * 1000, function()
        content = test_helpers.get_buf_lines()
        local found_modified_variable = not not string.find(content[2], "variable_to_be_tested")
        return found_modified_variable
      end)

      local expected_code = test_helpers.read_file("./tests/textcase/lsp/fixtures/snake-case.ts")
      assert.are.same(table.concat(content, "\n"), expected_code)
    end)

    it("Should be triggered on keybinding for constant case", function()
      test_helpers.execute_keys("/variableToBeTested<CR>gaN")
      local content = nil
      test_helpers.wait_for(5 * 1000, function()
        content = test_helpers.get_buf_lines()
        local found_modified_variable = not not string.find(content[2], "VARIABLE_TO_BE_TESTED")
        return found_modified_variable
      end)

      local expected_code = test_helpers.read_file("./tests/textcase/lsp/fixtures/constant-case.ts")
      assert.are.same(table.concat(content, "\n"), expected_code)
    end)
  end)

  describe("Renaming according to cursor position", function()
    before_each(function()
      textcase.setup({})

      local path = "./tests/textcase/lsp/fixtures/destructuring.ts"
      local cmd = " silent exe 'e " .. path .. "'"
      vim.cmd(cmd)
      vim.bo.filetype = "typescript"

      test_helpers.wait_for_language_server_to_start_on_destructuring_file()
      test_helpers.execute_keys("gg0")
    end)

    after_each(function()
      -- Close the buffer so the next test can open it again.
      vim.cmd("silent exe 'bd! %'")
    end)

    it("Should convert word when cursor is on its last character", function()
      test_helpers.execute_keys("12lgaN")
      local content = nil
      test_helpers.wait_for(5 * 1000, function()
        content = test_helpers.get_buf_lines()
        local found_modified_variable = not not string.find(content[1], "FOO_VAR")
        return found_modified_variable
      end)

      local expected_code = test_helpers.read_file("./tests/textcase/lsp/fixtures/destructuring-foo-as-constant.ts")
      assert.are.same(table.concat(content, "\n") .. "\n", expected_code)
    end)

    it("Should convert the next word when the cursor isn't on a word", function()
      test_helpers.execute_keys("13lgaN")
      local content = nil
      test_helpers.wait_for(5 * 1000, function()
        content = test_helpers.get_buf_lines()
        local found_modified_variable = not not string.find(content[1], "BAR_VAR")
        return found_modified_variable
      end)

      local expected_code = test_helpers.read_file("./tests/textcase/lsp/fixtures/destructuring-bar-as-constant.ts")
      assert.are.same(table.concat(content, "\n") .. "\n", expected_code)
    end)

    it("Shouldn't modify variables when the cursor isn't on a word and no word is found next", function()
      test_helpers.execute_keys("$gaN")
      local content = nil
      test_helpers.wait_for(5 * 1000, function()
        content = test_helpers.get_buf_lines()
        local found_modified_variable = not not string.find(content[1], "BAR_VAR")
        return found_modified_variable
      end)

      local expected_code = test_helpers.read_file("./tests/textcase/lsp/fixtures/destructuring.ts")
      assert.are.same(table.concat(content, "\n") .. "\n", expected_code)
    end)
  end)
end)
