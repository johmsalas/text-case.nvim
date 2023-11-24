local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("plugin options prefix", function()
  before_each(function()
    textcase.setup({
      prefix = "gp",
    })

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, { "LoremIpsum" })
  end)

  it("should set the default keymappings with the passed in prefix", function()
    test_helpers.execute_keys("gps")

    assert.are.same({ "lorem_ipsum" }, test_helpers.get_buf_lines())
  end)

  it("the default prefix should not work", function()
    test_helpers.execute_keys("gac")

    assert.are.same({ "LoremIpsum" }, test_helpers.get_buf_lines())
  end)
end)
