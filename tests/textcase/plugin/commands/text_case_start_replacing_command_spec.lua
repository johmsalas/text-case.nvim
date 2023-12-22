local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("plugin commands TextCaseStartReplacingCommand", function()
  before_each(function()
    textcase.setup()
    vim.api.nvim_set_keymap("n", "gar", "<cmd>TextCaseStartReplacingCommand<CR>", {})

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, { "LoremIpsum DolorSit" })
  end)

  describe("TextCaseStartReplacingWithFirstPartCommand", function()
    it("should select the first part of the current word for the Subs command", function()
      test_helpers.execute_keys("garNunc<CR>")

      assert.are.same({ "Nunc DolorSit" }, test_helpers.get_buf_lines())
    end)
  end)
end)
