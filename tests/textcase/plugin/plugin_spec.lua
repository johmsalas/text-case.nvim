local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("plugin", function()
  before_each(function()
    textcase.setup()

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
  end)

  describe("keybindings", function()
    -- See ./lua/textcase/plugin/presets.lua for the keybindings
    -- stylua: ignore start
    local test_cases = {
      { keys = "gan", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREM_IPSUM DolorSit" } },
      { keys = "gac", buffer_lines = { "lorem_ipsum dolor_sit" }, expected = { "loremIpsum dolor_sit" } },
      { keys = "gas", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem_ipsum DolorSit" } },
      { keys = "gad", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem-ipsum DolorSit" } },
      { keys = "gap", buffer_lines = { "lorem_ipsum dolor_sit" }, expected = { "LoremIpsum dolor_sit" } },
      { keys = "gau", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREMIPSUM DolorSit" } },
      { keys = "gal", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "loremipsum DolorSit" } },

      { keys = "gaon2w", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREM_IPSUM_DOLOR_SIT" } },
      { keys = "gaoc2w", buffer_lines = { "lorem_ipsum dolor_sit" }, expected = { "loremIpsumDolorSit" } },
      { keys = "gaos2w", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem_ipsum_dolor_sit" } },
      { keys = "gaod2w", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem-ipsum-dolor-sit" } },
      { keys = "gaop2w", buffer_lines = { "lorem_ipsum dolor_sit" }, expected = { "LoremIpsumDolorSit" } },
      { keys = "gaou2w", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREMIPSUM DOLORSIT" } },
      { keys = "gaol2w", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "loremipsum dolorsit" } },
    }
    -- stylua: ignore end

    for _, test_case in ipairs(test_cases) do
      it("should work for keys `" .. test_case.keys .. "`", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, test_case.buffer_lines)

        test_helpers.execute_keys(test_case.keys)

        assert.are.same(test_case.expected, test_helpers.get_buf_lines())
      end)
    end
  end)

  describe("api `current_word` method", function()
    -- stylua: ignore start
    local test_cases = {
      { method_name = "to_constant_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREM_IPSUM DolorSit" } },
      { method_name = "to_camel_case", buffer_lines = { "lorem_ipsum dolor_sit" }, expected = { "loremIpsum dolor_sit" } },
      { method_name = "to_snake_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem_ipsum DolorSit" } },
      { method_name = "to_dash_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem-ipsum DolorSit" } },
      { method_name = "to_pascal_case", buffer_lines = { "lorem_ipsum dolor_sit" }, expected = { "LoremIpsum dolor_sit" } },
      { method_name = "to_upper_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREMIPSUM DolorSit" } },
      { method_name = "to_lower_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "loremipsum DolorSit" } },
      { method_name = "to_dot_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem.ipsum DolorSit" } },
      { method_name = "to_phrase_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "Lorem ipsum DolorSit" } },
      { method_name = "to_title_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "Lorem Ipsum DolorSit" } },
      { method_name = "to_title_dash_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "Lorem-Ipsum DolorSit" } },
      { method_name = "to_path_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem/ipsum DolorSit" } },
    }
    -- stylua: ignore end

    for _, test_case in ipairs(test_cases) do
      it("should work with argument `" .. test_case.method_name .. "`", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, test_case.buffer_lines)

        test_helpers.execute_keys("<CMD>lua require('textcase').current_word('" .. test_case.method_name .. "')<CR>")

        assert.are.same(test_case.expected, test_helpers.get_buf_lines())
      end)
    end
  end)

  describe("api `operator` method", function()
    -- stylua: ignore start
    local test_cases = {
      { method_name = "to_constant_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREM_IPSUM_DOLOR_SIT" } },
      { method_name = "to_camel_case", buffer_lines = { "lorem_ipsum dolor_sit" }, expected = { "loremIpsumDolorSit" } },
      { method_name = "to_snake_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem_ipsum_dolor_sit" } },
      { method_name = "to_dash_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem-ipsum-dolor-sit" } },
      { method_name = "to_pascal_case", buffer_lines = { "lorem_ipsum dolor_sit" }, expected = { "LoremIpsumDolorSit" } },
      { method_name = "to_upper_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREMIPSUM DOLORSIT" } },
      { method_name = "to_lower_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "loremipsum dolorsit" } },
      { method_name = "to_dot_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem.ipsum.dolor.sit" } },
      { method_name = "to_phrase_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "Lorem ipsum dolor sit" } },
      { method_name = "to_title_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "Lorem Ipsum Dolor Sit" } },
      { method_name = "to_title_dash_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "Lorem-Ipsum-Dolor-Sit" } },
      { method_name = "to_path_case", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "lorem/ipsum/dolor/sit" } },
    }
    -- stylua: ignore end

    for _, test_case in ipairs(test_cases) do
      it("should work with argument `" .. test_case.method_name .. "`", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, test_case.buffer_lines)

        test_helpers.execute_keys("<CMD>lua require('textcase').operator('" .. test_case.method_name .. "')<CR>2w")

        assert.are.same(test_case.expected, test_helpers.get_buf_lines())
      end)
    end
  end)

  describe("visuel modes", function()
    local test_cases = {
      {
        keys = "Vjjgan",
        buffer_lines = {
          "LoremIpsum DolorSit amet",
          "lorem_ipsum dolor_sit amet",
          "lorem-ipsum dolor-sit amet",
        },
        expected = {
          "LOREM_IPSUM_DOLOR_SIT_AMET",
          "LOREM_IPSUM_DOLOR_SIT_AMET",
          "LOREM_IPSUM_DOLOR_SIT_AMET",
        },
      },
      {
        keys = "<C-V>eejgan",
        buffer_lines = {
          "LoremIpsum DolorSit amet",
          "lorem_ipsum dolor_sit amet",
          "lorem-ipsum dolor-sit amet",
        },
        expected = {
          "LOREM_IPSUM_DOLOR_SIT amet",
          "LOREM_IPSUM_DOLOR_Sit amet",
          "lorem-ipsum dolor-sit amet",
        },
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

  describe("Subs command", function()
    local test_cases = {
      {
        keys = "Vjj<CMD>Subs/lorem_ipsum/elit_sed/<CR>",
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
    }

    for _, test_case in ipairs(test_cases) do
      it("should work for keys `" .. test_case.keys .. "`", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, test_case.buffer_lines)

        test_helpers.execute_keys(test_case.keys)

        assert.are.same(test_case.expected, test_helpers.get_buf_lines())
      end)
    end
  end)

  -- it("should stringcase line from register", function()
  --   vim.fn.setreg("a", "stringcase", "")
  --   execute_keys('"agsUU')

  --   assert.are.same({ "stringcase", "ipsum", "dolor", "sit", "amet" }, get_buf_lines())
  -- end)

  -- it("should stringcase multiple lines", function()
  --   execute_keys("3gsUU")

  --   assert.are.same({ "LOREM", "IPSUM", "DOLOR", "sit", "amet" }, get_buf_lines())
  -- end)

  -- it("should stringcase multiple lines to eof", function()
  --   execute_keys("2j")
  --   execute_keys("5gSU")

  --   assert.are.same({
  --     "Lorem",
  --     "ipsum",
  --     "Lorem",
  --   }, get_buf_lines())
  -- end)

  -- it("should stringcase to eof", function()
  --   execute_keys("yw")
  --   execute_keys("j3l")
  --   execute_keys("S")

  --   assert.are.same({ "Lorem", "ipsLorem", "dolor", "sit", "amet" }, get_buf_lines())
  -- end)

  -- it("should stringcase to eof from register", function()
  --   vim.fn.setreg("a", "stringcase", "")
  --   execute_keys("4l")
  --   execute_keys('"aS')

  --   assert.are.same({ "Lorestringcase", "ipsum", "dolor", "sit", "amet" }, get_buf_lines())
  -- end)

  -- it("should stringcase string with new lines", function()
  --   execute_keys("y3w")
  --   execute_keys("j")
  --   execute_keys("ss")

  --   assert.are.same({ "Lorem", "Lorem", "ipsum", "dolor", "dolor", "sit", "amet" }, get_buf_lines())
  -- end)

  -- it("should stringcase from operator", function()
  --   execute_keys("yw")
  --   execute_keys("j")
  --   execute_keys("sw")

  --   assert.are.same({ "Lorem", "Lorem", "dolor", "sit", "amet" }, get_buf_lines())
  -- end)

  -- it("should stringcase from operator in multiple lines", function()
  --   execute_keys("yw")
  --   execute_keys("j")
  --   execute_keys("s3w")

  --   assert.are.same({ "Lorem", "Lorem", "amet" }, get_buf_lines())
  -- end)
end)

describe("On stringcase option", function()
  -- it("should be called", function()
  --   local called = false
  --   stringcase.setup({
  --     on_stringcase = function(_)
  --       called = true
  --     end,
  --   })

  --   execute_keys("yw")
  --   execute_keys("gsUU")

  --   assert(called)
  -- end)
end)
