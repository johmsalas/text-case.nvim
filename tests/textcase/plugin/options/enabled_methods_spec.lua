local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("plugin options default_keymappings=false", function()
  before_each(function()
    textcase.setup({
      enabled_methods = { "to_snake_case" },
    })

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, { "LoremIpsum" })
  end)

  it("should not register other keymappings", function()
    test_helpers.execute_keys("gal")

    assert.are.same({ "LoremIpsum" }, test_helpers.get_buf_lines())
  end)

  it("should still register the enabled key mapping", function()
    test_helpers.execute_keys("gas")

    assert.are.same({ "lorem_ipsum" }, test_helpers.get_buf_lines())
  end)
end)
