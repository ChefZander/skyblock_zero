--https://github.com/minetest-mods/technic/blob/master/technic/machines/HV/forcefield.lua

local is_int = function(value)
	return type(value) == 'number' and math.floor(value) == value and not core.is_nan(value)
end

jumpdrive.logic_effector = function(pos, msg, from_pos)
	local msgt = type(msg)
	if msgt ~= "table" then
		return
	end

	local notify = sbz_api.logic.get_notify(from_pos, pos)

	local meta = minetest.get_meta(pos)

	local radius = jumpdrive.get_radius(pos)
	local targetPos = jumpdrive.get_meta_pos(pos)

	local distance = vector.distance(pos, targetPos)
	local power_req = jumpdrive.calculate_power(radius, distance, pos, targetPos)

	if msg.command == "get" then
		notify {
			powerstorage = meta:get_int("power"),
			radius = radius,
			position = pos,
			target = targetPos,
			distance = distance,
			power_req = power_req
		}
	elseif msg.command == "reset" then
		meta:set_int("x", pos.x)
		meta:set_int("y", pos.y)
		meta:set_int("z", pos.z)
		jumpdrive.update_formspec(meta, pos)
	elseif msg.command == "set" then
		-- API requires integers for coord values, noop for everything else
		if is_int(msg.x) then meta:set_int("x", jumpdrive.sanitize_coord(msg.x)) end
		if is_int(msg.y) then meta:set_int("y", jumpdrive.sanitize_coord(msg.y)) end
		if is_int(msg.z) then meta:set_int("z", jumpdrive.sanitize_coord(msg.z)) end
		if is_int(msg.r) and msg.r <= jumpdrive.config.max_radius then
			meta:set_int("radius", msg.r)
		end
		if msg.formupdate then
			jumpdrive.update_formspec(meta, pos)
		end
	elseif msg.command == "simulate" or msg.command == "show" then
		local success, resultmsg = jumpdrive.simulate_jump(pos)

		notify {
			success = success,
			msg = resultmsg
		}
	elseif msg.command == "jump" then
		local success, timeormsg = jumpdrive.execute_jump(pos)

		if success then
			-- send new message in target pos
			-- don't defer that's very lame of you mt-mods developers
			notify {
				success = success,
				time = timeormsg
			}
		else
			notify {
				success = success,
				msg = timeormsg
			}
		end
	end
end
