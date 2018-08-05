local M = {}

local Poly = require 'Poly'

local __cairo_append_path 		= cairo_append_path
local __cairo_move_to    		= cairo_move_to
local __cairo_line_to    		= cairo_line_to
local __cairo_set_line_width	= cairo_set_line_width
local __cairo_set_line_cap   	= cairo_set_line_cap
local __cairo_set_line_join  	= cairo_set_line_join
local __cairo_set_source	    = cairo_set_source
local __cairo_fill_preserve  	= cairo_fill_preserve
local __cairo_stroke		    = cairo_stroke
local __cairo_path_destroy		= cairo_path_destroy
local __table_insert			= table.insert

local DATA_THICKNESS = 1
local DATA_CAP = CAIRO_LINE_CAP_BUTT
local DATA_JOIN = CAIRO_LINE_JOIN_MITER
local INTRVL_THICKNESS = 1
local INTRVL_CAP = CAIRO_LINE_CAP_BUTT
local OUTLINE_THICKNESS = 2
local OUTLINE_CAP = CAIRO_LINE_CAP_BUTT
local OUTLINE_JOIN = CAIRO_LINE_JOIN_MITER

local update = function(obj, ...)
   local data = obj.data
   for i = 1, #arg do
	  local series = data[i]
	  __table_insert(series, 1, obj.y + obj.height * (1 - arg[i]))
	  if #series == data.num_points + 2 then series[#series] = nil end
	end
end

local draw_static = function(obj, cr)
	--draw intervals
	local intrvls = obj.intrvls
	local x_intrvls = intrvls.x
	local y_intrvls = intrvls.y
	
	__cairo_set_line_width(cr, INTRVL_THICKNESS)
	__cairo_set_line_cap(cr, INTRVL_CAP)
	__cairo_set_source(cr, intrvls.source)
	for i = 1, #x_intrvls do
		__cairo_append_path(cr, x_intrvls[i])
	end
	for i = 1, #y_intrvls do
		__cairo_append_path(cr, y_intrvls[i])
	end
	__cairo_stroke(cr)
end

local draw_dynamic = function(obj, cr)

	--draw data on graph
	local data = obj.data
	local spacing = obj.width / data.num_points
	local right_x = obj.x + obj.width

	-- we stack from top to bottom, but index from bottom
	for i = #data, 1, -1 do
	   local series = data[i]
	   local current_num_intervals = #series
	   
	   __cairo_move_to(cr, right_x, series[1])
	   
	   for j = 1, current_num_intervals - 1 do
		  __cairo_line_to(cr, right_x - j * spacing, series[j+1])
	   end
	   
	   if series.fill_source then
		  local bottom_y = obj.y + obj.height
		  -- bottom line only matters if we fill
		  -- but if we do fill, we need to figure out if we are stacked
		  if i == 1 then
			 -- if this is the bottom series just draw a straight line along the x axis
			 __cairo_line_to(cr, right_x - (current_num_intervals - 1) * spacing, bottom_y)
			 __cairo_line_to(cr, right_x, bottom_y)
		  else
			 -- if this is not the bottom series then the bottom edge
			 -- of this region is the next data series
			 local next_series = data[i-1]
			 for j = current_num_intervals, 1, -1 do
				__cairo_line_to(cr, right_x - (j - 1) * spacing, next_series[j])
			 end
		  end
		  __cairo_set_source(cr, series.fill_source)
		  __cairo_fill_preserve(cr)
	   end

	   if series.line_source then
		  __cairo_set_line_width (cr, DATA_THICKNESS)
		  __cairo_set_line_cap(cr, DATA_CAP)
		  __cairo_set_line_join(cr, DATA_JOIN)
		  __cairo_set_source(cr, series.line_source)
	   end
		  __cairo_stroke(cr)
	end
	--draw graph outline (goes on top of everything)
	local outline = obj.outline
	
	__cairo_append_path(cr, outline.path)
	__cairo_set_line_width(cr, OUTLINE_THICKNESS)
	__cairo_set_line_join(cr, OUTLINE_JOIN)
	__cairo_set_line_cap(cr, OUTLINE_CAP)
	__cairo_set_source(cr, outline.source)
	__cairo_stroke(cr)
end

local position_x_intrvls = function(obj, cr)
	local y1 = obj.y - 0.5
	local y2 = y1 + obj.height + 0.5
	local x_intrvls = obj.intrvls.x
	local intrvl_width = obj.width / x_intrvls.n
	local p1 = {x = 0, y = 0}
	local p2 = {x = 0, y = 0}

	local obj_x = obj.x

	for i = 1, x_intrvls.n do
		local x1 = obj_x + intrvl_width * i - 0.5
		p1.x = x1
		p1.y = y1
		p2.x = x1
		p2.y = y2
		__cairo_path_destroy(x_intrvls[i])
		x_intrvls[i] = Poly.create_path(cr, nil, p1, p2)
	end
end

local position_y_intrvls = function(obj, cr)
	local x1 = obj.x-- + 0.5
	local x2 = obj.x + obj.width-- + 0.5
	local y_intrvls = obj.intrvls.y
	local y_intrvl_height = obj.height / y_intrvls.n
	local p1 = {x = 0, y = 0}
	local p2 = {x = 0, y = 0}
	
	for i = 1, y_intrvls.n do
		local y1 = obj.y + (i - 1) * y_intrvl_height - 0.5
		p1.x = x1
		p1.y = y1
		p2.x = x2
		p2.y = y1
		__cairo_path_destroy(y_intrvls[i])
		y_intrvls[i] = Poly.create_path(cr, nil, p1, p2)
	end
end

local position_graph_outline = function(obj, cr)
	local x1 = obj.x
	local y1 = obj.y - 0.5
	local x2 = obj.x + obj.width + 0.5
	local y2 = obj.y + obj.height + 1.0
	local p1 = {x = x1, y = y1}
	local p2 = {x = x1, y = y2}
	local p3 = {x = x2, y = y2}

	__cairo_path_destroy(obj.outline.path)
	
	obj.outline.path = Poly.create_path(cr, nil, p1, p2, p3)
end

M.draw_static = draw_static
M.draw_dynamic = draw_dynamic
M.update = update
M.position_x_intrvls = position_x_intrvls
M.position_y_intrvls = position_y_intrvls
M.position_graph_outline = position_graph_outline

return M
