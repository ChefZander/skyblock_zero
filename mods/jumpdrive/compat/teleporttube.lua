if not pipeworks.tptube then
	minetest.log("warning", "[jumpdrive] pipeworks teleport patch not applied, tp-tubes don't work as expected!")
	return
end

local is_compatible = pipeworks.tptube and pipeworks.tptube.remove_tube
if not is_compatible then
	minetest.log("warning", "[jumpdrive] tp-tube api not comptible, consider upgrading the pipeworks mod")
end

function jumpdrive.teleporttube_compat(from, to)
	if not is_compatible then
		return
	end

	local from_hash = pipeworks.tptube.hash(from)
	local to_hash = pipeworks.tptube.hash(to)

	-- swap data
	local db = pipeworks.tptube.get_db()
	local data = db[from_hash]

	if not data then
		minetest.log("warning", "[jumpdrive] no tp-tube data found at hash: " ..
			from_hash .. " / pos: " .. minetest.pos_to_string(from))
		return
	end

	minetest.log("action", "[jumpdrive] moving tp-tube data from " ..
		from_hash .. " to " .. to_hash .. " at pos: " .. minetest.pos_to_string(from))

	data.x = to.x
	data.y = to.y
	data.z = to.z

	-- remove source-entry
	pipeworks.tptube.remove_tube(from)

	-- set target entry
	db[to_hash] = data
	pipeworks.tptube.save_tube(to_hash)
end
