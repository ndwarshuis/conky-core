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

local draw_static = function(obj, cr)
   local first_bar = obj.bars[1]
   __cairo_set_line_width(cr, first_bar.thickness)
   __cairo_set_line_cap(cr, first_bar.cap)
   
   for i = 1, obj.bars.n do
	  local this_bar = obj.bars[i]
	  __cairo_set_source(cr, this_bar.source)
	  __cairo_append_path(cr, this_bar.path)
	  __cairo_stroke(cr)
   end
end

local draw_dynamic = function(obj, cr)
   local first_bar = obj.bars[1]
   __cairo_set_line_width(cr, first_bar.thickness)
   __cairo_set_line_cap(cr, first_bar.cap)
   
   for i = 1, obj.bars.n do
	  local this_bar = obj.bars[i]
	  __cairo_set_source(cr, this_bar.current_source)
	  __cairo_append_path(cr, this_bar.bar_path)
	  __cairo_stroke(cr)
   end
end

M.set = set
M.draw_static = draw_static
M.draw_dynamic = draw_dynamic

return M
