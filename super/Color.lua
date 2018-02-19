local M = {}

local Gradient 	= require 'Gradient'
local Util 		= require 'Util'

local __cairo_pattern_create_rgba = cairo_pattern_create_rgba

--Color(hex_rgba, [force_alpha])
local init = function(arg)

	local hex_rgba = arg.hex_rgba

	local obj = {
		r = ((hex_rgba / 0x10000) % 0x100) / 255.,
		g = ((hex_rgba / 0x100) % 0x100) / 255.,
		b = (hex_rgba % 0x100) / 255.,
		a = arg.alpha or 1.0
	}
	obj.userdata = __cairo_pattern_create_rgba(obj.r, obj.g, obj.b, obj.a)

	return obj
end

--ColorStop(hex_rgba, stop, [force_alpha])
local initColorStop = function(arg)

	local obj = init{hex_rgba = arg.hex_rgba, alpha = arg.alpha}
	
	obj.stop = arg.stop

	return obj
end

--Gradient([p1], [p2], [r0], [r1], ... color stops)
local initGradient = function(arg)

	local obj = {color_stops = {}, ptype = 'Gradient'}
	
	for i = 1, #arg do obj.color_stops[i] = arg[i] end

	Gradient.set_dimensions(obj, arg.p1, arg.p2, arg.r1, arg.r2)

	return obj
end

M.init = init
M.ColorStop = initColorStop
M.Gradient = initGradient

M = Util.set_finalizer(M, function() print('Cleaning up Color.lua') end)

return M
