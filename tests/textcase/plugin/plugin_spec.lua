local stringcase = require("textcase.plugin.plugin")

local function get_buf_lines()
  local result = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  return result
end

local function execute_keys(feedkeys)
  local keys = vim.api.nvim_replace_termcodes(feedkeys, true, false, true)
  vim.api.nvim_feedkeys(keys, "x", false)
end

describe("stringcase", function()
  before_each(function()
    stringcase.setup()

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)

    vim.api.nvim_set_keymap("n", "gsUU", "<cmd>lua require('stringcase').line('uppercase')<cr>", { noremap = true })
    vim.api.nvim_set_keymap("n", "gSU", "<cmd>lua require('stringcase').eol('uppercase')<cr>", { noremap = true })
    vim.api.nvim_set_keymap("n", "gsU", "<cmd>lua require('stringcase').operator('uppercase')<cr>", { noremap = true })

    vim.api.nvim_buf_set_lines(0, 0, -1, true, {
      "Lorem",
      "ipsum",
      "dolor",
      "sit",
      "amet",
    })
  end)

  -- it("should stringcase line", function()
  --   execute_keys("yw")
  --   execute_keys("j")
  --   execute_keys("gsUU")

  --   assert.are.same({ "Lorem", "IPSUM", "dolor", "sit", "amet" }, get_buf_lines())
  -- end)

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
