local M = {}

local Text = require 'Text'

local __tonumber = tonumber

local set = function(obj, cr, text, force)
	if text and text ~= obj.pretext then
		obj.value = __tonumber(text) or 0

		if force == 0 then
			obj.current_source = obj.critical.source
		elseif force == 1 then
			obj.current_source = obj.source
		else
			if obj.critical.enabled(obj.value) then
				obj.current_source = obj.critical.source
			else
				obj.current_source = obj.source
			end
		end
		Text.set(obj, cr, text)
	end
end

M.draw = Text.draw
M.set = set

return M
