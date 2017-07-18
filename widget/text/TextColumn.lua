local M = {}

local Text = require 'Text'

local __cairo_set_font_face	= cairo_set_font_face
local __cairo_set_font_size = cairo_set_font_size
local __cairo_set_source	= cairo_set_source
local __cairo_move_to       = cairo_move_to
local __cairo_show_text     = cairo_show_text
local __string_sub			= string.sub

local set = function(obj, cr, row_num, text)
	if obj.max_length then
		Text.set(obj.rows[row_num], cr, Text.trim_to_length(text, obj.max_length))
	else
		Text.set(obj.rows[row_num], cr, text)
	end
end

local draw = function(obj, cr)
	local rep_row = obj.rows[1]
	__cairo_set_font_face(cr, rep_row.font_face)
	__cairo_set_font_size(cr, rep_row.font_size)
	__cairo_set_source(cr, rep_row.source)

	local rows = obj.rows
	
	for i = 1, rows.n do
		local row = rows[i]
		__cairo_move_to(cr, row.x, row.y)
		__cairo_show_text(cr, row.text)
	end
end

M.set = set
M.draw = draw

return M
