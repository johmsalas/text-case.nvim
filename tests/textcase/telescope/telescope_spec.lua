local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("Telescope Integration", function()
  before_each(function()
    textcase.setup({})
    require("telescope").load_extension("textcase")
  end)

  describe("Quick Change in Normal mode", function()
    -- stylua: ignore start
    local test_cases = {
      { name = "constant", query = "const", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREM_IPSUM DolorSit" } },
      { name = "camel", query = "cam", buffer_lines = { "lorem_ipsum dolor_sit" }, expected = { "loremIpsum dolor_sit" } },
      { name = "snake", query = "snk", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem_ipsum DolorSit" } },
      { name = "dash", query = "dsh", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem-ipsum DolorSit" } },
      { name = "pascal", query = "psc", buffer_lines = { "lorem_ipsum dolor_sit" }, expected = { "LoremIpsum dolor_sit" } },
      { name = "upper", query = "uppr", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREMIPSUM DolorSit" } },
      { name = "lower", query = "low", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "loremipsum DolorSit" } },
    }
    -- stylua: ignore end

    for _, test_case in ipairs(test_cases) do
      it("Should open Telescope and apply `" .. test_case.name .. " case`", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, test_case.buffer_lines)
        test_helpers.execute_keys("<CMD>TextCaseOpenTelescopeQuickChange<CR>")
        test_helpers.execute_keys("i" .. test_case.query, "xmt")
        vim.wait(50, function() end)
        test_helpers.execute_keys("<CR>i")
        assert.are.same(test_case.expected, test_helpers.get_buf_lines())
      end)
    end
  end)
end)
