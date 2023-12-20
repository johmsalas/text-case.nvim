local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("plugin options substitude_command_name", function()
  before_each(function()
    textcase.setup({
      substitude_command_name = "Magic",
    })

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, { "LoremIpsum", "LoremNunc" })
  end)

  it("should execute the custom substitude command with the passed in name", function()
    test_helpers.execute_keys("Vj:Magic/lorem/dolor<CR>")

    assert.are.same({ "DolorIpsum", "DolorNunc" }, test_helpers.get_buf_lines())
  end)

  it("should execute the default substitude command", function()
    test_helpers.execute_keys("Vj:Subs/lorem/dolor<CR>")

    assert.are.same({ "DolorIpsum", "DolorNunc" }, test_helpers.get_buf_lines())
  end)
end)
