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

function M.waitFor(max_time, callback)
  local max_seconds = max_time
  local curr_seconds = 0
  local task_finished = false
  while curr_seconds < max_seconds and not task_finished do
    curr_seconds = curr_seconds + 0.5
    task_finished = callback()
    vim.wait(500, function() end)
  end
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

      local ts_server_started = false
      M.waitFor(30, function()
        vim.cmd("LspInfo")
        ts_server_started = not not vim.fn.search("1 client(s) attached to this buffer")
        test_helpers.execute_keys("q")
        return ts_server_started
      end)

      assert.is.truthy(ts_server_started)
      vim.wait(1000, function() end)

      test_helpers.execute_keys("/variableToBeTested<CR>gaS")
      local content = nil
      M.waitFor(5000, function()
        content = test_helpers.get_buf_lines()
        local found_modified_variable = not not string.find(content[4], "variable_to_be_tested")
        return found_modified_variable
      end)

      local expected_code = M.read_file("./tests/textcase/lsp/fixtures/component-snake-case.tsx")
      assert.are.same(table.concat(content, "\n"), expected_code)
    end)
  end)
end)
