local feature_flags = require("feature_flags")
if not feature_flags.is_feature_available("telescope") then
  return
end

local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("Telescope Integration", function()
  before_each(function()
    textcase.setup({})
    require("telescope").load_extension("textcase")

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
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

  describe("visual mode via ga. keymapping", function()
    before_each(function()
      vim.api.nvim_set_keymap("n", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
      vim.api.nvim_set_keymap("v", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
    end)

    local buffer_lines = {
      "LoremIpsum LoremIpsum DolorSit",
      "LoremIpsum LoremIpsum DolorSit",
      "LoremIpsum DolorSit",
    }
    local expected = {
      "LoremIpsum LOREM_IPSUM_DOLOR_SIT",
      "LOREM_IPSUM_LOREM_IPSUM DolorSit",
      "LoremIpsum DolorSit",
    }

    it("Should open Telescope and apply the selected method only for selected block", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, true, buffer_lines)
      test_helpers.execute_keys("wvejga.")
      test_helpers.execute_keys("iconst", "xmt")
      vim.wait(50, function() end)
      test_helpers.execute_keys("<CR>i")
      assert.are.same(expected, test_helpers.get_buf_lines())
    end)
  end)

  describe("visual mode lines via ga. keymapping", function()
    before_each(function()
      vim.api.nvim_set_keymap("n", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
      vim.api.nvim_set_keymap("v", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
    end)

    local buffer_lines = {
      "LoremIpsum LoremIpsum DolorSit",
      "LoremIpsum LoremIpsum DolorSit",
      "LoremIpsum DolorSit",
    }
    local expected = {
      "LOREM_IPSUM_LOREM_IPSUM_DOLOR_SIT",
      "LOREM_IPSUM_LOREM_IPSUM_DOLOR_SIT",
      "LoremIpsum DolorSit",
    }

    it("Should open Telescope and apply the selected method only for selected block", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, true, buffer_lines)
      test_helpers.execute_keys("Vjga.")
      test_helpers.execute_keys("iconst", "xmt")
      vim.wait(50, function() end)
      test_helpers.execute_keys("<CR>i")
      assert.are.same(expected, test_helpers.get_buf_lines())
    end)
  end)

  describe("visual block mode via ga. keymapping", function()
    before_each(function()
      vim.api.nvim_set_keymap("n", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
      vim.api.nvim_set_keymap("v", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
    end)

    describe("when the words are aligned", function()
      local buffer_lines = {
        "LoremIpsum LoremIpsum DolorSit",
        "LoremIpsum LoremIpsum DolorSit",
        "LoremIpsum DolorSit",
      }
      local expected = {
        "LoremIpsum LOREM_IPSUM DolorSit",
        "LoremIpsum LOREM_IPSUM DolorSit",
        "LoremIpsum DolorSit",
      }

      it("Should open Telescope and apply the selected method only for selected block`", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, buffer_lines)
        test_helpers.execute_keys("w<C-V>ejga.")
        test_helpers.execute_keys("iconst", "xmt")
        vim.wait(50, function() end)
        test_helpers.execute_keys("<CR>i")
        assert.are.same(expected, test_helpers.get_buf_lines())
      end)
    end)

    describe("when the words are not aligned", function()
      local buffer_lines = {
        "LoremIpsum LoremIpsum DolorSit",
        "LoremIpsum LoremIpsum DolorSit",
        "Lorem LoremIpsum DolorSit",
        "LoremIpsum DolorSit",
      }
      local expected = {
        "LoremIpsum LoremIpsum DolorSit",
        "LoremIpsum LOREM_IPSUM DolorSit",
        "Lorem LoremIPSUM_DOLOrSit",
        "LoremIpsum DolorSit",
      }

      it("Should open Telescope and apply the selected method only for selected block`", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, buffer_lines)
        test_helpers.execute_keys("jw<C-V>ejga.")
        test_helpers.execute_keys("iconst", "xmt")
        vim.wait(50, function() end)
        test_helpers.execute_keys("<CR>i")
        assert.are.same(expected, test_helpers.get_buf_lines())
      end)
    end)
  end)

  describe("via :Telescope textcase", function()
    -- stylua: ignore start
    local test_cases = {
      { name = "constant", query = "const", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREM_IPSUM DolorSit" } },
    }
    -- stylua: ignore end

    for _, test_case in ipairs(test_cases) do
      it("Should open Telescope and apply `" .. test_case.name .. " case`", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, test_case.buffer_lines)
        test_helpers.execute_keys("<CMD>Telescope textcase<CR>")
        test_helpers.execute_keys("i" .. test_case.query, "xmt")
        vim.wait(50, function() end)
        test_helpers.execute_keys("<CR>i")
        assert.are.same(test_case.expected, test_helpers.get_buf_lines())
      end)
    end
  end)

  describe("via :Telescope textcase normal_mode", function()
    -- stylua: ignore start
    local test_cases = {
      { name = "constant", query = "const", buffer_lines = { "LoremIpsum DolorSit" }, expected = { "LOREM_IPSUM DolorSit" } },
    }
    -- stylua: ignore end

    for _, test_case in ipairs(test_cases) do
      it("Should open Telescope and apply `" .. test_case.name .. " case`", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, test_case.buffer_lines)
        test_helpers.execute_keys("<CMD>Telescope textcase normal_mode<CR>")
        test_helpers.execute_keys("i" .. test_case.query, "xmt")
        vim.wait(50, function() end)
        test_helpers.execute_keys("<CR>i")
        assert.are.same(test_case.expected, test_helpers.get_buf_lines())
      end)
    end
  end)
end)
