local M = {}

local Gradient 	= require 'Gradient'
local Patterns	= require 'Patterns'
local Util		= require 'Util'

local __tonumber 	= tonumber
local __string_sub 	= string.sub

--Pattern(pattern, [p1], [p2], [r1], [r2], [key])
local initPattern = function(arg)

	local pattern 	= arg.pattern
	local p1 		= arg.p1
	local p2 		= arg.p2
	local r1 		= arg.r1
	local r2 		= arg.r2
	
	if p1 and p2 and pattern and pattern.ptype == 'Gradient' then		
		Gradient.set_dimensions(pattern, p1, p2, r1, r2)
	end

	return pattern.userdata
end

--Critical([critical_pattern], [critical_limit], [p1], [p2], [r1], [r2])

local CRITICAL_PATTERN = Patterns.RED
local CRITICAL_LIMIT = '>80'

local create_critical_function = function(limit)
	local compare = limit and __string_sub(limit, 1, 1)
	local value = limit and __tonumber(__string_sub(limit, 2))

	if compare == '>' then return function(n) return (n > value) end end
	if compare == '<' then return function(n) return (n < value) end end
	return function(n) return nil end	--if no limit then return dummy
end

local initCritical = function(arg)

	local obj = {
		source = initPattern{
			pattern	= arg.critical_pattern or CRITICAL_PATTERN,
			p1 		= arg.p1,
			p2 		= arg.p2,
			r1 		= arg.r1,
			r2 		= arg.r2,
		},
		enabled = create_critical_function(arg.critical_limit or CRITICAL_LIMIT)
	}

	return obj
end

M.Pattern = initPattern
M.Critical = initCritical

M = Util.set_finalizer(M, function() print('Cleaning up Super.lua') end)

return M
