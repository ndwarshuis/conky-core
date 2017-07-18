local M = {}

local __cairo_new_path  		= cairo_new_path
local __cairo_arc 	   			= cairo_arc
local __cairo_copy_path 		= cairo_copy_path
local __cairo_append_path 		= cairo_append_path
local __cairo_set_line_width 	= cairo_set_line_width
local __cairo_set_line_cap 		= cairo_set_line_cap
local __cairo_set_source 		= cairo_set_source
local __cairo_stroke 			= cairo_stroke

local draw = function(obj, cr)
	__cairo_append_path(cr, obj.path)
	__cairo_set_line_width(cr, obj.thickness)
	__cairo_set_line_cap(cr, obj.cap)
	__cairo_set_source(cr, obj.source)
	__cairo_stroke(cr)
end

local create_path = function(cr, x, y, radius, theta0, theta1)
	__cairo_new_path(cr)
	__cairo_arc(cr, x, y, radius, theta0, theta1)
	local path = __cairo_copy_path(cr)
	__cairo_new_path(cr) -- clear path to keep it from reappearing
	return path
end

M.draw = draw
M.create_path = create_path

return M
