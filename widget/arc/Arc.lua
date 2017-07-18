local M = {}

local _CR = require 'CR'

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

local create_path = function(x, y, radius, theta0, theta1)
	__cairo_new_path(_CR)
	__cairo_arc(_CR, x, y, radius, theta0, theta1)
	return __cairo_copy_path(_CR)
end

M.draw = draw
M.create_path = create_path

return M
