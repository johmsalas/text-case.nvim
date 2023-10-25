local M = {}

local stringcase = require('textcase.conversions.stringcase')
local utils = require('textcase.shared.utils')

local c = utils.create_wrapped_method

M.to_upper_case = c('TO UPPER CASE', stringcase.to_upper_case)
M.to_lower_case = c('to lower case', stringcase.to_lower_case)
M.to_snake_case = c('to_snake_case', stringcase.to_snake_case)
M.to_dash_case = c('to-dash-case', stringcase.to_dash_case)
M.to_title_dash_case = c('To-Title-Dash-Case', stringcase.to_title_dash_case)
M.to_constant_case = c('TO_CONSTANT_CASE', stringcase.to_constant_case)
M.to_dot_case = c('to.dot.case', stringcase.to_dot_case)
M.to_phrase_case = c('To phrase case', stringcase.to_phrase_case)
M.to_camel_case = c('toCamelCase', stringcase.to_camel_case)
M.to_pascal_case = c('ToPascalCase', stringcase.to_pascal_case)
M.to_title_case = c('To Title Case', stringcase.to_title_case)
M.to_path_case = c('to/path/case', stringcase.to_path_case)
M.to_upper_phrase_case = c('TO UPPER PHRASE CASE', stringcase.to_upper_phrase_case)
M.to_lower_phrase_case = c('to lower phrase case', stringcase.to_lower_phrase_case)

return M
