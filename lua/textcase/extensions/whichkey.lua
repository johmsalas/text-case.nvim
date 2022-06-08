local M = {}

M.state = {
  queue_normal_mappings = {},
  queue_visual_mappings = {},
}

function M.add(opts)
  local queue_ref = opts.mode == 'n' and M.state.queue_normal_mappings or M.state.queue_visual_mappings
  queue_ref[opts.keybind] = { opts.command, opts.desc }
end

function M.register_batch(prefix)
  local normal_opts = {
    mode = "n",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = true,
  }
  local visual_opts = {
    mode = "v",
    prefix = "<leader>",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = true,
  }

  local normal_mapping = {
    [prefix] = {
      name = "text-case",
      o = {
        name = "Pending mode"
      }
    }
  }
  local visual_mapping = {
    [prefix] = M.state.queue_visual_mappings
  }

  -- build mapping dictionary for which key
  for keybind, command_and_desc in pairs(M.state.queue_normal_mappings) do
    if #keybind == 2 and keybind[1] == 'o' then
      normal_mapping[prefix]['o'][keybind[2]] = command_and_desc
    else
      normal_mapping[prefix][keybind] = command_and_desc
    end
  end

  for _, mappings_table in pairs({
    { 'queue_normal_mappings', normal_mapping, normal_opts },
    { 'queue_visual_mappings', visual_mapping, visual_opts }
  }) do
    local queue_key, mapping, opts = unpack(mappings_table)
    if not pcall(
      require("which-key").register,
      mapping,
      opts
    ) then
      for keybind, command_and_desc in pairs(M.state[queue_key]) do
        vim.api.nvim_set_keymap(
          'n',
          prefix .. keybind,
          command_and_desc[1],
          { noremap = true }
        )
      end
    end

    M.state[queue_key] = {}
  end
end

return M
