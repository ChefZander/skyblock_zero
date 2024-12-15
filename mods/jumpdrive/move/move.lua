-- moves the source to the target area
-- no protection- or overlap checking is done here
function jumpdrive.move(source_pos1, source_pos2, target_pos1, target_pos2)
	minetest.log("action", "[jumpdrive] initiating jump (" ..
		minetest.pos_to_string(source_pos1) .. "-" .. minetest.pos_to_string(source_pos2) ..
		") (" .. minetest.pos_to_string(target_pos1) .. "-" .. minetest.pos_to_string(target_pos2) .. ")")

	-- step 1: copy via voxel manip
	-- https://dev.minetest.net/VoxelManip#Examples

	-- delta between source and target
	local delta_vector = vector.subtract(target_pos1, source_pos1)

	-- center of source
	local source_center = vector.add(source_pos1, vector.divide(vector.subtract(source_pos2, source_pos1), 2))
	minetest.log("action", "[jumpdrive] source-center: " .. minetest.pos_to_string(source_center))

	local t0 = minetest.get_us_time()

	-- load areas (just a precaution)
	if minetest.load_area then
		minetest.load_area(source_pos1, source_pos2)
		minetest.load_area(target_pos1, target_pos2)
	end

	-- move mapdata (nodeids, param1, param2)
	local movenode_list = jumpdrive.move_mapdata(source_pos1, source_pos2, target_pos1, target_pos2)

	local t1 = minetest.get_us_time()
	minetest.log("action", "[jumpdrive] step I took " .. (t1 - t0) .. " us")

	for k, v in ipairs(sbz_api.on_mvps_move) do
		v(movenode_list)
	end

	-- step 2: check meta/timers and copy if needed
	t0 = minetest.get_us_time()
	jumpdrive.move_metadata(source_pos1, source_pos2, delta_vector)
	jumpdrive.move_nodetimers(source_pos1, source_pos2, delta_vector)

	-- move "on_movenode" aware nodes
	for _, entry in ipairs(movenode_list) do
		if entry.nodedef then
			entry.nodedef.on_movenode(entry.from_pos, entry.to_pos, {
				edge = entry.edge
			})
		end
	end

	-- print stats
	t1 = minetest.get_us_time()
	minetest.log("action", "[jumpdrive] step II took " .. (t1 - t0) .. " us")


	-- step 3: execute target region compat code
	t0 = minetest.get_us_time()
	jumpdrive.target_region_compat(source_pos1, source_pos2, target_pos1, target_pos2, delta_vector)
	t1 = minetest.get_us_time()
	minetest.log("action", "[jumpdrive] step III took " .. (t1 - t0) .. " us")


	-- step 4: move objects
	t0 = minetest.get_us_time()
	jumpdrive.move_objects(source_center, source_pos1, source_pos2, delta_vector)

	-- move players
	jumpdrive.move_players(source_pos1, source_pos2, delta_vector)

	t1 = minetest.get_us_time()
	minetest.log("action", "[jumpdrive] step IV took " .. (t1 - t0) .. " us")


	-- step 5: clear source area with voxel manip
	t0 = minetest.get_us_time()
	jumpdrive.clear_area(source_pos1, source_pos2)

	t1 = minetest.get_us_time()
	minetest.log("action", "[jumpdrive] step V took " .. (t1 - t0) .. " us")

	-- call after_jump callbacks
	jumpdrive.fire_after_jump({
		pos1 = source_pos1,
		pos2 = source_pos2
	}, {
		pos1 = target_pos1,
		pos2 = target_pos2
	})
end
