local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("Coerce word under cursor", function()
  before_each(function()
    textcase.setup()

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
  end)

  describe("keybindings", function()
    -- stylua: ignore start
    local test_cases = {
      { keys = "0gan", buffer_lines = { "Lorem-Ipsum Dolor-Sit" }, expected = { "LOREM_IPSUM Dolor-Sit" } },
      { keys = "03wgan", buffer_lines = { "Lorem-Ipsum Dolor-Sit" }, expected = { "Lorem-Ipsum DOLOR_SIT" } },
      { keys = "04wgan", buffer_lines = { "Lorem-Ipsum Dolor-Sit" }, expected = { "Lorem-Ipsum DOLOR_SIT" } },
      { keys = "05wgan", buffer_lines = { "Lorem-Ipsum Dolor-Sit" }, expected = { "Lorem-Ipsum DOLOR_SIT" } },
    }
    -- stylua: ignore end

    for _, test_case in ipairs(test_cases) do
      it("should work for keys `" .. test_case.keys .. "` on words containing - characters", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, test_case.buffer_lines)

        test_helpers.execute_keys(test_case.keys)

        assert.are.same(test_case.expected, test_helpers.get_buf_lines())
      end)
    end
  end)

  describe("api `current_word` method", function()
    -- stylua: ignore start
    local test_cases = {
      { keys = "0",method_name = "to_constant_case", buffer_lines = { "Lorem-Ipsum Dolor-Sit" }, expected = { "LOREM_IPSUM Dolor-Sit" } },
      { keys = "03w",method_name = "to_constant_case", buffer_lines = { "Lorem-Ipsum Dolor-Sit" }, expected = { "Lorem-Ipsum DOLOR_SIT" } },
      { keys = "04w",method_name = "to_constant_case", buffer_lines = { "Lorem-Ipsum Dolor-Sit" }, expected = { "Lorem-Ipsum DOLOR_SIT" } },
      { keys = "05w",method_name = "to_constant_case", buffer_lines = { "Lorem-Ipsum Dolor-Sit" }, expected = { "Lorem-Ipsum DOLOR_SIT" } },
    }
    -- stylua: ignore end

    for _, test_case in ipairs(test_cases) do
      it("should work with argument `" .. test_case.method_name .. "` on words containing - characters", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, test_case.buffer_lines)

        test_helpers.execute_keys(test_case.keys)
        test_helpers.execute_keys("<CMD>lua require('textcase').current_word('" .. test_case.method_name .. "')<CR>")

        assert.are.same(test_case.expected, test_helpers.get_buf_lines())
      end)
    end
  end)
end)
