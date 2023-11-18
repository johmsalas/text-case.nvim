local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("plugin options default_keymappings_enabled=false", function()
  before_each(function()
    textcase.setup({
      default_keymappings_enabled = false,
    })

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, { "LoremIpsum" })
  end)

  it("should not register keymappings", function()
    test_helpers.execute_keys("gac")

    assert.are.same({ "LoremIpsum" }, test_helpers.get_buf_lines())
  end)

  it("should still be able to execute methods directly", function()
    test_helpers.execute_keys("<CMD>lua require('textcase').current_word('to_snake_case')<CR>")

    assert.are.same({ "lorem_ipsum" }, test_helpers.get_buf_lines())
  end)
end)
