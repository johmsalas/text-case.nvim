local test_helpers = require("tests.test_helpers")
local textcase = require("textcase")

-- Allow Typescript language server to start.
-- Even though the language server is attached, it doesn't mean it is ready
-- to receive requests. Hence, we send a request and wait for response.
-- Then we know the language server is ready.
local wait_for_language_server_to_start = function()
  test_helpers.execute_keys("ww") -- Move to `doSomething`
  local hover = ""
  test_helpers.wait_for(30 * 1000, function()
    -- This prints one "Error detected while processing command line:" but this can be ignored
    vim.lsp.buf_request_all(0, "textDocument/hover", vim.lsp.util.make_position_params(), function(results)
      -- Hover will print the type definition of the variable under the cursor. Hence,
      -- it should contain "doSomething".
      hover = results[1].result.contents.value
    end)
    return string.find(hover, "doSomething")
  end)
end

describe("LSP", function()
  describe("Rename", function()
    before_each(function()
      textcase.setup({})

      local path = "./tests/textcase/lsp/fixtures/camel-case.ts"
      local cmd = " silent exe 'e " .. path .. "'"
      vim.cmd(cmd)
      vim.bo.filetype = "typescript"

      wait_for_language_server_to_start()
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
end)
