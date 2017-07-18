local M = {}

local _CR = require 'CR'

local __cairo_new_path 	    	= cairo_new_path
local __cairo_move_to 	    	= cairo_move_to
local __cairo_line_to 	    	= cairo_line_to
local __cairo_close_path     	= cairo_close_path
local __cairo_append_path    	= cairo_append_path
local __cairo_copy_path			= cairo_copy_path
local __cairo_set_line_width 	= cairo_set_line_width
local __cairo_set_line_cap   	= cairo_set_line_cap
local __cairo_set_line_join  	= cairo_set_line_join
local __cairo_set_source	    = cairo_set_source
local __cairo_stroke		    = cairo_stroke

local create_path = function(closed, ...)
	__cairo_new_path(_CR)
	__cairo_move_to(_CR, arg[1].x, arg[1].y)
	for i = 2, #arg do
		__cairo_line_to(_CR, arg[i].x, arg[i].y)
	end
	if closed then __cairo_close_path(_CR) end
	return __cairo_copy_path(_CR)
end

local draw = function(obj, cr)
	__cairo_append_path(cr, obj.path)
	__cairo_set_line_width(cr, obj.thickness)
	__cairo_set_line_join(cr, obj.join)
	__cairo_set_line_cap(cr, obj.cap)
	__cairo_set_source(cr, obj.source)
	__cairo_stroke(cr)
end

M.create_path = create_path
M.draw = draw

return M
