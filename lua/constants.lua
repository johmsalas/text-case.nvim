local is_feature_available = function(feature)
  return true
end

local M = {
  feature_neovim_requirement = {
    telescope = "0.9",
    flag_incremental_preview = "nvim-0.8-dev+374-ge13dcdf16",
  },
  is_feature_available,
}

return M
