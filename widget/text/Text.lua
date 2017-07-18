local M = {}

local __string_sub			= string.sub
local __cairo_set_font_face	= cairo_set_font_face
local __cairo_set_font_size = cairo_set_font_size
local __cairo_set_source	= cairo_set_source
local __cairo_move_to       = cairo_move_to
local __cairo_show_text     = cairo_show_text
local __cairo_text_extents  = cairo_text_extents

local te = cairo_text_extents_t:create()
tolua.takeownership(te)

local trim_to_length = function(text, len)
	if #text > len then
		return __string_sub(text, 1, len)..'...'
	else
		return text
	end
end

local draw = function(obj, cr)
	__cairo_set_font_face(cr, obj.font_face)
	__cairo_set_font_size(cr, obj.font_size)
	__cairo_set_source(cr, obj.current_source)
	__cairo_move_to(cr, obj.x, obj.y)
	__cairo_show_text(cr, obj.text)
end

local set = function(obj, cr, text)
	if text and text ~= obj.pretext then
		obj.pretext = text

		if obj.append_front then text = obj.append_front..text end
		if obj.append_end then text = text..obj.append_end end

		if text ~= obj.text then
			local x_align = obj.x_align
			local te = te
			
			__cairo_set_font_size(cr, obj.font_size)
			__cairo_set_font_face(cr, obj.font_face)
			__cairo_text_extents(cr, text, te)
			
			obj.width = te.width
			
			if		x_align == 'left'	then obj.delta_x = -te.x_bearing
			elseif 	x_align == 'center' then obj.delta_x = -(te.x_bearing + obj.width * 0.5)
			elseif 	x_align == 'right'  then obj.delta_x = -(te.x_bearing + obj.width)
			end
			
			obj.x = obj.x_ref + obj.delta_x
		end
		obj.text = text
	end
end

local move_to_x = function(obj, x)
	if x ~= obj.x then
		obj.x_ref = x
		obj.x = x + obj.delta_x
	end
end

local move_to_y = function(obj, y)
	if y ~= obj.y then
		obj.y_ref = y
		obj.y = y + obj.delta_y
	end
end

local move_to = function(obj, x, y)
	move_to_X(obj, x)
	move_to_Y(obj, y)
end

M.trim_to_length = trim_to_length
M.set = set
M.draw = draw
M.move_to = move_to
M.move_to_x = move_to_x
M.move_to_y = move_to_y

return M
