local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("plugin start_replacing_command_with_first_part", function()
  before_each(function()
    textcase.setup()
    vim.api.nvim_set_keymap(
      "n",
      "gar",
      "<cmd>lua require('textcase').start_replacing_command_with_first_part()<CR>",
      {}
    )

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, { "LoremIpsum DolorSit" })
  end)

  it("should select the first part of the current word for the Subs command", function()
    test_helpers.execute_keys("garNunc<CR>")

    assert.are.same({ "NuncIpsum DolorSit" }, test_helpers.get_buf_lines())
  end)
end)
