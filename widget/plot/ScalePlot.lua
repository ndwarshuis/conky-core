local M = {}

local LabelPlot = require 'LabelPlot'

local __table_insert	= table.insert
local __table_remove	= table.remove
local __math_max        = math.max

-- nothing here is "static" because we cannot assume that
-- any object will remain the same shape (can shift in both x and y)
local draw_static = function(obj, cr)
   -- stub
end

local draw_dynamic = function(obj, cr)
   LabelPlot.draw_static(obj, cr)
   LabelPlot.draw_dynamic(obj, cr)
end

local scale_data = function(obj, cr, new_domain, new_factor)
	local y = obj.y
	local current_factor = obj.scale.factor
	local data = obj.plot.data
	local h = obj.plot.height
	for i = 1, #data do
	   local series = data[i]
	   for j = 1, #series do
		  series[j] = y + h * (1 - (1 - (series[j] - y) / h) * (new_factor / current_factor))
	   end
	end
	obj.scale.domain = new_domain
	obj.scale.factor = new_factor
	LabelPlot.populate_y_labels(obj, cr, 1 / new_factor)
	LabelPlot.position_x_labels(obj)
	LabelPlot.position_x_intrvls(obj.plot, cr)
	LabelPlot.position_y_intrvls(obj.plot, cr)
	LabelPlot.position_graph_outline(obj.plot, cr)
end

local update = function(obj, cr, ...)
   local scale = obj.scale
   local new_domain, new_factor = obj.scale._func(__math_max(unpack(arg)))
	
	--###tick/tock timers
	
	local timers = scale.timers
	local n = #timers
	for i = n, 1, -1 do
		local current_timer = timers[i]
		current_timer.remaining = current_timer.remaining - 1
		if current_timer.remaining == 0 then
			__table_remove(timers, i)
			n = n - 1
		end
	end

	--###create/destroy timers
	if new_domain > scale.previous_domain then						--zap all timers less than/equal to s
		for i = n, 1, -1 do
			if timers[i].domain <= new_domain then
				__table_remove(timers, i)
				n = n - 1
			end
		end
	elseif new_domain < scale.previous_domain then					--create new timer for prev_s
		timers[n + 1] = {
			domain = scale.previous_domain,
			factor = scale.previous_factor,
			remaining = obj.plot.data.num_points
		}
		n = n + 1
	end
	
	--###scale data
	
	if new_domain > scale.domain then 								--scale up
		scale_data(obj, cr, new_domain, new_factor)
	elseif new_domain < scale.domain then							--check timers
		if n == 0 then 												--scale down bc no timers to block
			scale_data(obj, cr, new_domain, new_factor)
		elseif scale.timers[1].domain < scale.domain then			--scale down to active timer
			scale_data(obj, cr, scale.timers[1].domain, scale.timers[1].factor)
		end
	end
	
	scale.previous_domain = new_domain
	scale.previous_factor = new_factor
	
	local data = obj.plot.data

	for i = 1, #arg do
	   local series = data[i]
	   __table_insert(series, 1, obj.y + obj.plot.height * (1 - arg[i] * scale.factor))
	   if #series == data.num_points + 2 then series[#series] = nil end
	end
	--~ print('----------------------------------------------------------------------')
	--~ print('value', value, 'f', scale.factor, 's', scale.domain, 'curr_s', scale.previous_domain)
	--~ for i, v in pairs(timers) do
		--~ print('timers', 'i', i, 's', v.domain, 't', v.remaining, 'f', v.factor)
	--~ end
	--~ print('length', #timers)
end

-- M.draw = LabelPlot.draw
M.draw_static = draw_static
M.draw_dynamic = draw_dynamic
M.update = update

return M
