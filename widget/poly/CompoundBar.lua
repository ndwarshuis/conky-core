local M = {}

local Bar = require 'Bar'

local __cairo_set_line_width	= cairo_set_line_width
local __cairo_set_line_cap 		= cairo_set_line_cap
local __cairo_set_source   		= cairo_set_source
local __cairo_stroke 	  		= cairo_stroke
local __cairo_append_path  		= cairo_append_path

local set = function(obj, index, percent)
	Bar.set(obj.bars[index], percent)
end

local draw = function(obj, cr)
	local first_bar = obj.bars[1]
	__cairo_set_line_width(cr, first_bar.thickness)
	__cairo_set_line_cap(cr, first_bar.cap)
	
	for i = 1, obj.bars.n do
		local bar = obj.bars[i]
		__cairo_set_source(cr, bar.source)
		__cairo_append_path(cr, bar.path)
		__cairo_stroke(cr)
		__cairo_set_source(cr, bar.current_source)
		__cairo_append_path(cr, bar.bar_path)
		__cairo_stroke(cr)
	end
end

M.set = set
M.draw = draw

return M
