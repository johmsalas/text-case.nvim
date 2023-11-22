local feature_neovim_requirement = {
  telescope = "nvim-0.9.0",
  flag_incremental_preview = "nvim-0.8-dev+374-ge13dcdf16",
}

local is_feature_available = function(feature)
  return vim.fn.has(feature_neovim_requirement[feature]) == 1
end

local M = {
  feature_neovim_requirement = feature_neovim_requirement,
  is_feature_available = is_feature_available,
}

return M
