local M = {}

local stringcase = require('textcase.conversions.stringcase')
local utils = require('textcase.shared.utils')

local c = utils.create_wrapped_method

M.to_upper_case = c('to_upper_case', stringcase.to_upper_case)
M.to_lower_case = c('to_lower_case', stringcase.to_lower_case)
M.to_snake_case = c('to_snake_case', stringcase.to_snake_case)
M.to_dash_case = c('to_dash_case', stringcase.to_dash_case)
M.to_constant_case = c('to_constant_case', stringcase.to_constant_case)
M.to_dot_case = c('to_dot_case', stringcase.to_dot_case)
M.to_phrase_case = c('to_phrase_case', stringcase.to_phrase_case)
M.to_camel_case = c('to_camel_case', stringcase.to_camel_case)
M.to_pascal_case = c('to_pascal_case', stringcase.to_pascal_case)
M.to_title_case = c('to_title_case', stringcase.to_title_case)
M.to_path_case = c('to_path_case', stringcase.to_path_case)

return M
