local M = {}

local stringcase = require('textcase.conversions.stringcase')
local utils = require('textcase.shared.utils')

local c = utils.create_wrapped_method

M.to_upper_case = c('to_upper_case', stringcase.to_upper_case, 'TO UPPER CASE')
M.to_lower_case = c('to_lower_case', stringcase.to_lower_case, 'to lower case')
M.to_snake_case = c('to_snake_case', stringcase.to_snake_case, 'to_snake_case')
M.to_dash_case = c('to_dash_case', stringcase.to_dash_case, 'to-dash-case')
M.to_title_dash_case = c('to_title_dash_case', stringcase.to_title_dash_case, 'To-Title-Dash-Case')
M.to_constant_case = c('to_constant_case', stringcase.to_constant_case, 'TO_CONSTANT_CASE')
M.to_dot_case = c('to_dot_case', stringcase.to_dot_case, 'to.dot.case')
M.to_phrase_case = c('to_phrase_case', stringcase.to_phrase_case, 'To phrase case')
M.to_camel_case = c('to_camel_case', stringcase.to_camel_case, 'toCamelCase')
M.to_pascal_case = c('to_pascal_case', stringcase.to_pascal_case, 'ToPascalCase')
M.to_title_case = c('to_title_case', stringcase.to_title_case, 'To Title Case')
M.to_path_case = c('to_path_case', stringcase.to_path_case, 'to/path/case')
M.to_upper_phrase_case = c('to_upper_phrase_case', stringcase.to_upper_phrase_case, 'TO UPPER PHRASE CASE')
M.to_lower_phrase_case = c('to_lower_phrase_case', stringcase.to_lower_phrase_case, 'to lower phrase case')

return M
