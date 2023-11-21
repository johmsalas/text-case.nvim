local test_helpers = require("tests.test_helpers")
local textcase = require("textcase")

---@param path string
function M.read_file(path)
  local fd = vim.loop.fs_open(path, "r", 438)
  local fstat = vim.loop.fs_fstat(fd)
  local contents = vim.loop.fs_read(fd, fstat.size, 0)
  vim.loop.fs_close(fd)
  return contents
end

describe("LSP", function()
  describe("Rename", function()
    before_each(function()
      textcase.setup({})
    end)

    it("Should work", function()
      local code = M.read_file("./tests/textcase/lsp/fixtures/component-camel-case.tsx")
      local lines = {}
      for line in code:gmatch("[^\r\n]+") do
        table.insert(lines, line)
      end
      vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
      test_helpers.execute_keys("/variableToBeTested<CR>")
      test_helpers.execute_keys("gaS")
      assert.are.same({ "aa" }, test_helpers.get_buf_lines())
    end)
  end)
end)
