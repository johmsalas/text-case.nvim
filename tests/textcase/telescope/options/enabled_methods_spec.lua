local feature_flags = require("feature_flags")
if not feature_flags.is_feature_available("telescope") then
  return
end

local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("Telescope options enabled_methods=...", function()
  before_each(function()
    textcase.setup({
      enabled_methods = { "to_snake_case" },
    })
    require("telescope").load_extension("textcase")

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, { "LoremIpsum" })
  end)

  it("should not register other text-case methods in Telescope", function()
    local query = "to lower case"
    test_helpers.execute_keys("<CMD>TextCaseOpenTelescopeQuickChange<CR>")
    test_helpers.execute_keys("i" .. query, "xmt")
    vim.wait(50, function() end)
    test_helpers.execute_keys("<CR>i")
    assert.are.same({ "LoremIpsum" }, test_helpers.get_buf_lines())
  end)

  it("should still register the enabled text-case methods in Telescope", function()
    local query = "snk" -- to_snake_case
    test_helpers.execute_keys("<CMD>TextCaseOpenTelescopeQuickChange<CR>")
    test_helpers.execute_keys("i" .. query, "xmt")
    vim.wait(50, function() end)
    test_helpers.execute_keys("<CR>i")
    assert.are.same({ "lorem_ipsum" }, test_helpers.get_buf_lines())
  end)
end)
