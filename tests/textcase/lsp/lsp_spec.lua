local test_helpers = require("tests.test_helpers")
local textcase = require("textcase")

local cur_dir = vim.fn.expand("%:p:h")

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
      local path = cur_dir .. "/tests/textcase/lsp/fixtures/component-camel-case.tsx"
      vim.print(path)
      local cmd = " silent exe 'e " .. path .. "'"
      vim.cmd(cmd)
      test_helpers.execute_keys("/variableToBeTested<CR>")

      vim.cmd([[
        lua require('textcase').lsp_rename('to_snake_case')
      ]])
      vim.wait(200, function() end)
      assert.are.same({ "aa" }, test_helpers.get_buf_lines())
    end)
  end)
end)
