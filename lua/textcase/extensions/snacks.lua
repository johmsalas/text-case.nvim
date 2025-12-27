local plugin = require("textcase.plugin.plugin")
local presets = require("textcase.plugin.presets")
local constants = require("textcase.shared.constants")
local utils = require("textcase.shared.utils")
local api = require("textcase").api

local M = {}

-- Access the state from repeat methods to store visual region
local repeat_methods = require("strings.repeat.methods")

---@class textcase.snacks.Item
---@field text string
---@field method_name string
---@field type string

---Create the list of case conversion options
---@param prefix_text string
---@param conversion_type string
---@return textcase.snacks.Item[]
local function create_resulting_cases(prefix_text, conversion_type)
    local results = {}

    for _, method in pairs({
        api.to_upper_case,
        api.to_lower_case,
        api.to_snake_case,
        api.to_dash_case,
        api.to_title_dash_case,
        api.to_constant_case,
        api.to_dot_case,
        api.to_comma_case,
        api.to_phrase_case,
        api.to_camel_case,
        api.to_pascal_case,
        api.to_title_case,
        api.to_path_case,
    }) do
        if presets.options.enabled_methods_set[method.method_name] then
            table.insert(results, {
                text = prefix_text .. method.desc,
                method_name = method.method_name,
                type = conversion_type,
            })
        end
    end

    return results
end

---Execute the selected conversion
---@param item textcase.snacks.Item
local function invoke_replacement(item)
    if not item then
        return
    end

    if item.type == constants.change_type.CURRENT_WORD then
        plugin.current_word(item.method_name)
    elseif item.type == constants.change_type.LSP_RENAME then
        plugin.lsp_rename(item.method_name)
    elseif item.type == constants.change_type.VISUAL then
        plugin.visual(item.method_name)
    end
end

---@param opts? snacks.picker.Config
function M.normal_mode_quick_change(opts)
    local ok, Snacks = pcall(require, "snacks")
    if not ok then
        vim.notify("snacks.nvim is required for this feature", vim.log.levels.ERROR)
        return
    end

    local items = create_resulting_cases("Convert to ", constants.change_type.CURRENT_WORD)

    Snacks.picker.pick({
        title = "Text Case",
        items = items,
        format = "text",
        layout = opts and opts.layout or { preset = "select" },
        confirm = function(picker, item)
            picker:close()
            if item then
                vim.schedule(function()
                    invoke_replacement(item)
                end)
            end
        end,
    })
end

---@param opts? snacks.picker.Config
function M.normal_mode_lsp_change(opts)
    local ok, Snacks = pcall(require, "snacks")
    if not ok then
        vim.notify("snacks.nvim is required for this feature", vim.log.levels.ERROR)
        return
    end

    local items = create_resulting_cases("LSP rename ", constants.change_type.LSP_RENAME)

    Snacks.picker.pick({
        title = "Text Case (LSP)",
        items = items,
        format = "text",
        layout = opts and opts.layout or { preset = "select" },
        confirm = function(picker, item)
            picker:close()
            if item then
                vim.schedule(function()
                    invoke_replacement(item)
                end)
            end
        end,
    })
end

---@param opts? snacks.picker.Config
function M.normal_mode(opts)
    local ok, Snacks = pcall(require, "snacks")
    if not ok then
        vim.notify("snacks.nvim is required for this feature", vim.log.levels.ERROR)
        return
    end

    local results_quick = create_resulting_cases("Convert to ", constants.change_type.CURRENT_WORD)
    local results_lsp = create_resulting_cases("LSP rename ", constants.change_type.LSP_RENAME)

    local items = {}
    for _, v in ipairs(results_quick) do
        table.insert(items, v)
    end
    for _, v in ipairs(results_lsp) do
        table.insert(items, v)
    end

    Snacks.picker.pick({
        title = "Text Case",
        items = items,
        format = "text",
        layout = opts and opts.layout or { preset = "select" },
        confirm = function(picker, item)
            picker:close()
            if item then
                vim.schedule(function()
                    invoke_replacement(item)
                end)
            end
        end,
    })
end

---@param opts? snacks.picker.Config
function M.visual_mode(opts)
    local ok, Snacks = pcall(require, "snacks")
    if not ok then
        vim.notify("snacks.nvim is required for this feature", vim.log.levels.ERROR)
        return
    end

    -- Save the visual region before opening the picker (same as telescope does)
    local mode = vim.api.nvim_get_mode().mode
    repeat_methods.state.telescope_previous_mode = mode
    repeat_methods.state.telescope_previous_buffer = vim.api.nvim_get_current_buf()
    repeat_methods.state.telescope_previous_visual_region =
        utils.get_visual_region(0, true, nil, utils.get_mode_at_operator(mode))

    local items = create_resulting_cases("Convert to ", constants.change_type.VISUAL)

    Snacks.picker.pick({
        title = "Text Case",
        items = items,
        format = "text",
        layout = opts and opts.layout or { preset = "select" },
        confirm = function(picker, item)
            picker:close()
            if item then
                vim.schedule(function()
                    invoke_replacement(item)
                end)
            end
        end,
    })
end

-- Alias for consistency
M.textcase = M.normal_mode

return M
