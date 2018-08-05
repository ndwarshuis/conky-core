local M = {}

local Arc = require 'Arc'

local __cairo_set_source  	= cairo_set_source
local __cairo_stroke 	 	= cairo_stroke
local __cairo_append_path 	= cairo_append_path
local __cairo_set_line_width 	= cairo_set_line_width
local __cairo_set_line_cap 		= cairo_set_line_cap

local set = function(obj, percent)
	obj.percent = percent
	obj.dial_path = obj._make_dial_path(percent)

	if obj.critical.enabled(obj.percent) then
		obj.current_source = obj.critical.source
	else
		obj.current_source = obj.indicator_source
	end
end

local draw_static = function(obj, cr)
   Arc.draw(obj, cr)
end

local draw_dynamic = function(obj, cr)
   __cairo_set_line_width(cr, obj.thickness)
   __cairo_set_line_cap(cr, obj.cap)
   __cairo_set_source(cr, obj.current_source)
   __cairo_append_path(cr, obj.dial_path)
   __cairo_stroke(cr)
end

M.set = set
M.draw_static = draw_static
M.draw_dynamic = draw_dynamic

return M
