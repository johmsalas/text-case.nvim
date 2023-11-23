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
      local cmd = " silent exe 'e " .. path .. "'"
      vim.cmd(cmd)
      vim.bo.filetype = "typescriptreact"
      -- allow tsserver start

      local max_seconds = 30
      local curr_seconds = 0
      local ts_server_started = false
      vim.print("Starting LSP Server")
      while curr_seconds < max_seconds and not ts_server_started do
        curr_seconds = curr_seconds + 0.5
        vim.wait(500, function() end)
        vim.cmd("LspInfo")
        ts_server_started = vim.fn.search("1 client(s) attached to this buffer")
        test_helpers.execute_keys("q")
      end

      assert.is.truthy(ts_server_started)
      vim.print("LSP Server started after " .. curr_seconds .. " seconds")
      -- remove
      vim.wait(200, function() end)
      test_helpers.execute_keys("/variableToBeTested<CR>gaS")
      --
      -- -- allow tsserver to rename the variable
      vim.wait(2000, function() end)
      local content = test_helpers.get_buf_lines()
      assert.are.same(content, "aaaa")
      vim.wait(2000, function() end)
    end)
  end)
end)
