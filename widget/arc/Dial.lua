local M = {}

local Arc = require 'Arc'

local __cairo_set_source  	= cairo_set_source
local __cairo_stroke 	 	= cairo_stroke
local __cairo_append_path 	= cairo_append_path

local set = function(obj, percent)
	obj.percent = percent
	obj.dial_path = obj._make_dial_path(percent)

	if obj.critical.enabled(obj.percent) then
		obj.current_source = obj.critical.source
	else
		obj.current_source = obj.indicator_source
	end
end

local draw = function(obj, cr)
	Arc.draw(obj, cr)
	__cairo_set_source(cr, obj.current_source)
	__cairo_append_path(cr, obj.dial_path)
	__cairo_stroke(cr)
end

M.set = set
M.draw = draw

return M
