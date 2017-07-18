local M = {}

local __cairo_append_path		= cairo_append_path
local __cairo_set_line_width 	= cairo_set_line_width
local __cairo_set_line_cap   	= cairo_set_line_cap
local __cairo_set_source	    = cairo_set_source
local __cairo_stroke		    = cairo_stroke

local set = function(obj, percent)
	obj.percent = percent
	obj.bar_path = obj._make_bar_path(percent)
	
	if obj.critical.enabled(percent) then
		obj.current_source = obj.critical.source
	else
		obj.current_source = obj.indicator_source
	end
end

local draw = function(obj, cr)
	__cairo_set_line_width(cr, obj.thickness)
	__cairo_set_line_cap(cr, obj.cap)
	
	__cairo_append_path(cr, obj.path)
	__cairo_set_source(cr, obj.source)
	__cairo_stroke(cr)

	__cairo_append_path(cr, obj.bar_path)
	__cairo_set_source(cr, obj.current_source)
	__cairo_stroke(cr)
end

M.set = set
M.draw = draw

return M
