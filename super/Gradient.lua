local __cairo_pattern_create_radial 		= cairo_pattern_create_radial
local __cairo_pattern_create_linear 		= cairo_pattern_create_linear
local __cairo_pattern_add_color_stop_rgba 	= cairo_pattern_add_color_stop_rgba
local __pairs 								= pairs

local set_dimensions = function(gradient, p1, p2, r1, r2)
	if p1 and p2 then
		local pattern = (r1 and r2) and
			__cairo_pattern_create_radial(p1.x, p1.y, r1, p2.x, p2.y, r2) or
			__cairo_pattern_create_linear(p1.x, p1.y, p2.x, p2.y)
		
		for _, color_stop in __pairs(gradient.color_stops) do
			__cairo_pattern_add_color_stop_rgba(pattern, color_stop.stop,
			  color_stop.r, color_stop.g, color_stop.b, color_stop.a)
		end
		gradient.userdata = pattern
	end
end

return set_dimensions
