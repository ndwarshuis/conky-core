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

local draw_static = function(obj, cr)
   local these_dials = obj.dials
   __cairo_set_line_width(cr, these_dials[1].thickness)
   __cairo_set_line_cap(cr, these_dials[1].cap)
   
   for i = 1, #these_dials do
	  local this_dial = these_dials[i]
	  __cairo_set_source(cr, this_dial.source)
	  __cairo_append_path(cr, this_dial.path)
	  __cairo_stroke(cr)
   end
end

local draw_dynamic = function(obj, cr)
   local these_dials = obj.dials
   __cairo_set_line_width(cr, these_dials[1].thickness)
   __cairo_set_line_cap(cr, these_dials[1].cap)
   
   for i = 1, #these_dials do
	  local this_dial = these_dials[i]
	  __cairo_set_source(cr, this_dial.current_source)
	  __cairo_append_path(cr, this_dial.dial_path)
	  __cairo_stroke(cr)
   end
end

M.set = set
M.draw_static = draw_static
M.draw_dynamic = draw_dynamic

return M
