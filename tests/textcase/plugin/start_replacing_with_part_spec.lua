local textcase = require("textcase")
local test_helpers = require("tests.test_helpers")

describe("plugin start_replacing_command_with_part", function()
  before_each(function()
    textcase.setup()
    vim.api.nvim_set_keymap("n", "gar", "<cmd>lua require('textcase').start_replacing_command_with_part(1)<CR>", {})
    vim.api.nvim_set_keymap("n", "ga2r", "<cmd>lua require('textcase').start_replacing_command_with_part(2)<CR>", {})

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, { "LoremIpsum DolorSit" })
  end)

  describe("for 1 part", function()
    before_each(function()
      vim.api.nvim_buf_set_lines(0, 0, -1, true, { "LoremIpsum DolorSit" })
    end)

    describe("when the cursor is on the first part of the current word", function()
      it("should select the first part of the current word for the Subs command", function()
        test_helpers.execute_keys("garNunc<CR>")

        assert.are.same({ "NuncIpsum DolorSit" }, test_helpers.get_buf_lines())
      end)
    end)

    describe("when the cursor is on the second part of the current word", function()
      describe("when the cursor is on the first letter", function()
        it("should select the first part of the current word for the Subs command", function()
          test_helpers.execute_keys("fIgarNunc<CR>")

          assert.are.same({ "LoremNunc DolorSit" }, test_helpers.get_buf_lines())
        end)
      end)

      describe("when the cursor is on the a middle letter", function()
        it("should select the first part of the current word for the Subs command", function()
          test_helpers.execute_keys("fpgarNunc<CR>")

          assert.are.same({ "LoremNunc DolorSit" }, test_helpers.get_buf_lines())
        end)
      end)

      describe("when the cursor is on the last letter", function()
        it("should select the first part of the current word for the Subs command", function()
          test_helpers.execute_keys("fmgarNunc<CR>")

          assert.are.same({ "LoremNunc DolorSit" }, test_helpers.get_buf_lines())
        end)
      end)
    end)
  end)

  describe("for 2 parts", function()
    before_each(function()
      vim.api.nvim_buf_set_lines(0, 0, -1, true, { "LoremIpsumEst DolorSit" })
    end)

    describe("when the cursor is on the first part of the current word", function()
      it("should select the first part of the current word for the Subs command", function()
        test_helpers.execute_keys("ga2rNunc<CR>")

        assert.are.same({ "NuncEst DolorSit" }, test_helpers.get_buf_lines())
      end)
    end)

    describe("when the cursor is on the second part of the current word", function()
      describe("when the cursor is on the first letter", function()
        it("should select the first part of the current word for the Subs command", function()
          test_helpers.execute_keys("fIga2rNunc<CR>")

          assert.are.same({ "LoremNunc DolorSit" }, test_helpers.get_buf_lines())
        end)
      end)

      describe("when the cursor is on the a middle letter", function()
        it("should select the first part of the current word for the Subs command", function()
          test_helpers.execute_keys("fpga2rNunc<CR>")

          assert.are.same({ "LoremNunc DolorSit" }, test_helpers.get_buf_lines())
        end)
      end)

      describe("when the cursor is on the last letter", function()
        it("should select the first part of the current word for the Subs command", function()
          test_helpers.execute_keys("fmga2rNunc<CR>")

          assert.are.same({ "LoremNunc DolorSit" }, test_helpers.get_buf_lines())
        end)
      end)
    end)
  end)
end)
