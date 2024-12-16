--[[
execute the globalstep after the specified period. the actual amount of time elapsed is passed to the function,
and will always be greater than or equal to the length of the period.
futil.register_globalstep({
	period = 1,
	func = function(elapsed) end,
})

execute the globalstep after the specified period. if more time has elapsed than the period specified, the remainder
will be counted against the next cycle, allowing the execution to "catch up". the expected time between executions
will tend towards the specified period. IMPORTANT: do not specify a period which is less than the length of the
dedicated server step.
futil.register_globalstep({
	period = 1,
	catchup = "single"
	func = function(period) end,
})

execute the globalstep after the specified period. if more time has elapsed than the period specified, the callback
will be executed repeatedly until the elapsed time is less than the period, and the remainder will still be counted
against the next cycle.
futil.register_globalstep({
	period = 1,
	catchup = "full"
	func = function(period) end,
})

this is just a light wrapper over a normal minetest globalstep callback, and is only provided for completeness.
futil.register_globalstep({
	func = function(dtime) end,
})
]]
local f = string.format

local dedicated_server_step = tonumber(minetest.settings:get("dedicated_server_step")) or 0.09

function futil.register_globalstep(def)
	if def.period then
		local elapsed = 0
		if def.catchup == "full" then
			assert(def.period > 0, "full catchup will cause an infinite loop if period is 0")
			minetest.register_globalstep(function(dtime)
				elapsed = elapsed + dtime
				if elapsed < def.period then
					return
				end
				elapsed = elapsed - def.period
				def.func(def.period)
				while elapsed > def.period do
					elapsed = elapsed - def.period
					def.func(def.period)
				end
			end)
		elseif def.catchup == "single" or def.catchup == true then
			assert(
				def.period >= dedicated_server_step,
				f(
					"if period (%s) is less than dedicated_server_step (%s), single catchup will never fully catch up.",
					def.period,
					dedicated_server_step
				)
			)
			minetest.register_globalstep(function(dtime)
				elapsed = elapsed + dtime
				if elapsed < def.period then
					return
				end
				elapsed = elapsed - def.period
				def.func(def.period)
			end)
		else
			-- no catchup, just reset
			minetest.register_globalstep(function(dtime)
				elapsed = elapsed + dtime
				if elapsed < def.period then
					return
				end
				def.func(elapsed)
				elapsed = 0
			end)
		end
	else
		-- we do nothing useful
		minetest.register_globalstep(function(dtime)
			def.func(dtime)
		end)
	end
end
