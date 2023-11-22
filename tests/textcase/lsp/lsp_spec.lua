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

    it("Should be triggered on keybinding", function()
      local path = cur_dir .. "/tests/textcase/lsp/fixtures/component-camel-case.tsx"
      vim.print(path)
      local cmd = " silent exe 'e " .. path .. "'"
      vim.cmd(cmd)
      vim.bo.filetype = "typescriptreact"
      -- allow tsserver start
      vim.wait(200, function() end)
      test_helpers.execute_keys("/variableToBeTested<CR>gaS")

      -- allow tsserver to rename the variable
      vim.wait(200, function() end)
      local content = test_helpers.get_buf_lines()
      assert.is.truthy(string.find(content[4], "variable_to_be_tested"))
      assert.is.truthy(string.find(content[7], "variable_to_be_tested"))
    end)
  end)
end)
