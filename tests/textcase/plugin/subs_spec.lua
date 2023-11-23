local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("plugin", function()
  before_each(function()
    textcase.setup()

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
  end)

  describe("Subs command", function()
    local test_cases = {
      {
        keys = "Vjj:Subs/lorem_ipsum/elit_sed/<CR>",
        buffer_lines = {
          "LoremIpsum DolorSit amet",
          "lorem_ipsum dolor_sit amet",
          "lorem-ipsum dolor-sit amet",
        },
        expected = {
          "ElitSed DolorSit amet",
          "elit_sed dolor_sit amet",
          "elit-sed dolor-sit amet",
        },
      },
      -- This test case adds a word in the Subs command
      {
        keys = "Vjj:Subs/lorem ipsum/lorem ipsum nunc/<CR>",
        buffer_lines = {
          "LoremIpsum DolorSit amet",
          "lorem_ipsum dolor_sit amet",
          "lorem-ipsum dolor-sit amet",
        },
        expected = {
          "LoremIpsumNunc DolorSit amet",
          "lorem_ipsum_nunc dolor_sit amet",
          "lorem-ipsum-nunc dolor-sit amet",
        },
      },
      {
        keys = "Vjj:Subs/LoremIpsum/LoremIpsumNunc/<CR>",
        buffer_lines = {
          "LoremIpsum DolorSit amet",
          "lorem_ipsum dolor_sit amet",
          "lorem-ipsum dolor-sit amet",
        },
        expected = {
          "LoremIpsumNunc DolorSit amet",
          "lorem_ipsum_nunc dolor_sit amet",
          "lorem-ipsum-nunc dolor-sit amet",
        },
      },
      {
        keys = "Vjj:Subs/LOREM IPSUM/LOREM IPSUM NUNC/<CR>",
        buffer_lines = {
          "LoremIpsum DolorSit amet",
          "LOREM_IPSUM dolor_sit amet",
          "lorem-ipsum dolor-sit amet",
        },
        expected = {
          "LoremIpsumNunc DolorSit amet",
          "LOREM_IPSUM_NUNC dolor_sit amet",
          "lorem-ipsum-nunc dolor-sit amet",
        },
      },
      -- This test case makes sure that we don't replace endlessly if <to> is 2*<from>
      {
        keys = "V:Subs/a/aa<CR>",
        buffer_lines = { "a" },
        expected = { "aa" },
      },
    }

    for _, test_case in ipairs(test_cases) do
      it("should work for keys `" .. test_case.keys .. "`", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, test_case.buffer_lines)

        test_helpers.execute_keys(test_case.keys)

        assert.are.same(test_case.expected, test_helpers.get_buf_lines())
      end)
    end
  end)
end)
