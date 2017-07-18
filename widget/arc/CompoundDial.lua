local M = {}

local Dial = require 'Dial'

local __cairo_set_line_width 	= cairo_set_line_width
local __cairo_set_line_cap 		= cairo_set_line_cap
local __cairo_set_source   		= cairo_set_source
local __cairo_stroke 	  		= cairo_stroke
local __cairo_append_path  		= cairo_append_path

local set = function(obj, index, percent)
	Dial.set(obj.dials[index], percent)
end

local draw = function(obj, cr)
	local dials = obj.dials
	__cairo_set_line_width(cr, dials[1].thickness)
	__cairo_set_line_cap(cr, dials[1].cap)
	
	for i = 1, #dials do
		local current_dial = dials[i]
		__cairo_set_source(cr, current_dial.source)
		__cairo_append_path(cr, current_dial.path)
		__cairo_stroke(cr)
		__cairo_set_source(cr, current_dial.current_source)
		__cairo_append_path(cr, current_dial.dial_path)
		__cairo_stroke(cr)
	end
end

M.set = set
M.draw = draw

return M
