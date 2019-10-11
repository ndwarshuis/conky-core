local M = {}

local __tonumber		= tonumber
local __tostring		= tostring
local __io_popen 		= io.popen
local __io_open 		= io.open
local __math_floor 		= math.floor
local __math_ceil 		= math.ceil
local __string_sub 		= string.sub
local __string_gsub 	= string.gsub
local __string_match 	= string.match
local __string_format 	= string.format
local __string_upper 	= string.upper
local __conky_parse		= conky_parse
local __select			= select
local __setmetatable 	= setmetatable

local round = function(x, places)
    local m = 10 ^ (places or 0)
    if x >= 0 then
		return __math_floor(x * m + 0.5) / m
	else
		return __math_ceil(x * m - 0.5) / m
	end
end

local get_bytes_power = function(unit)
	if     unit == 'KiB' then return 10
	elseif unit == 'MiB' then return 20
	elseif unit == 'GiB' then return 30
	elseif unit == 'TiB' then return 40
	else                      return 0
	end
end

local convert_bytes = function(x, old_unit, new_unit)
	if old_unit == new_unit then
		return __tonumber(x)
	else
		return x * 2 ^ (get_bytes_power(old_unit) - get_bytes_power(new_unit))
	end
end

local round_to_string = function(x, places)
	places = places or 0
	local y = round(x, places)
	if places >= 0 then
       return __string_format('%.'..places..'f', y)
    else
       return __tostring(y)
    end
end

local precision_round_to_string = function(x, sig_fig)
	sig_fig = sig_fig or 4
	if     x < 10   then return round_to_string(x, sig_fig - 1)
	elseif x < 100  then return round_to_string(x, sig_fig - 2)
	elseif x < 1000 then return round_to_string(x, sig_fig - 3)
	else                 return round_to_string(x, sig_fig - 4)
	end
end

--[[
available modes per lua docs
*n: number (actually returns a number)
*a: entire file (default here)
*l: reads one line and strips \n (default for read cmd)
*L; reads one line and keeps \n
N: reads number of lines (where N is a number)
--]]
local read_entire_file = function(file, regex, mode)
	if not file then return '' end
	local str = file:read(mode or '*a')
	file:close()
	if not str then return '' end
	if regex then return __string_match(str, regex) or '' else return str end
end

local conky = function(expr, regex)
	local ans = __conky_parse(expr)
	if regex then return __string_match(ans, regex) or '' else return ans end
end

local precision_convert_bytes = function(val, old_unit, new_unit, sig_fig)
	return precision_round_to_string(convert_bytes(val, old_unit, new_unit), sig_fig)
end

local get_unit = function(bytes)
	if     	bytes < 1024       then	return 'B'
	elseif 	bytes < 1048576    then	return 'KiB'
	elseif 	bytes < 1073741824 then	return 'MiB'
	else							return 'GiB'  
	end
end

local get_unit_base_K = function(kilobytes)
	if 		kilobytes < 1024       then	return 'KiB'
	elseif 	kilobytes < 1048576    then	return 'MiB'
	elseif	kilobytes < 1073741824 then	return 'GiB'
	else								return 'TiB'
	end
end

local parse_unit = function(str)
	return __string_match(str, '^([%d%p]-)(%a+)')
end

local char_count = function(str, char)
	return __select(2, __string_gsub(str, char, char))
end

local line_count = function(str)
	return char_count(str, '\n')
end

local execute_cmd = function(cmd, regex, mode)
	return read_entire_file(__io_popen(cmd), regex, mode)
end

local read_file = function(path, regex, mode)
	return read_entire_file(__io_open(path, 'rb'), regex, mode)
end

local write_file = function(path, str)
	local file = __io_open(path, 'w+')
	if file then
		file:write(str)
		file:close()
	end
end

local conky_numeric = function(expr, regex)
	return __tonumber(conky(expr, regex)) or 0
end

local memoize = function(f)
	local mem = {} -- memoizing table
	__setmetatable(mem, {__mode = "kv"}) -- make it weak
	return function (x) 	-- new version of ’f’, with memoizing
		local r = mem[x]
		if not r then 		-- no previous result?
			r = f(x) 		-- calls original function
			mem[x] = r 		-- store result for reuse
		end
		return r
	end
end

local convert_unix_time = function(unix_time, frmt)
	local cmd = 'date -d @'..unix_time
	if frmt then cmd = cmd..' +\''..frmt..'\'' end
	return __string_match(execute_cmd(cmd), '(.-)\n')
end

local capitalize_each_word = function(str)
	return __string_sub(__string_gsub(" "..str, "%W%l", __string_upper), 2)
end

function set_finalizer(tbl, gc_function)
   return setmetatable(tbl, {__gc = gc_function or function() print("cleaning up:", tbl) end})
end

M.round = round
M.get_bytes_power = get_bytes_power
M.convert_bytes = convert_bytes
M.conky = conky
M.round_to_string = round_to_string
M.precision_round_to_string = precision_round_to_string
M.precision_convert_bytes = precision_convert_bytes
M.get_unit = get_unit
M.get_unit_base_K = get_unit_base_K
M.parse_unit = parse_unit
M.char_count = char_count
M.line_count = line_count
M.execute_cmd = execute_cmd
M.read_file = read_file
M.write_file = write_file
M.conky_numeric = conky_numeric
M.memoize = memoize
M.convert_unix_time = convert_unix_time
M.capitalize_each_word = capitalize_each_word
M.set_finalizer = set_finalizer

return M
