local c_air = minetest.get_content_id("air")

-- map of replaced content id's on jump
-- TODO: expose as api function
-- <id> = <id>
local mapped_content_ids = {}

if minetest.get_modpath("vacuum") then
	-- don't jump vacuum
	mapped_content_ids[minetest.get_content_id("vacuum:vacuum")] = c_air
end

if minetest.get_modpath("planet_mars") then
	-- alias planet_mars:airlight to air
	mapped_content_ids[minetest.get_content_id("planet_mars:airlight")] = c_air
end

-- map of "on_movenode" aware node id's
-- content_id = nodedef
local movenode_aware_nodeids = {}

-- collect movenode aware node id's
minetest.register_on_mods_loaded(function()
	local count = 0
	for nodename, nodedef in pairs(minetest.registered_nodes) do
		if type(nodedef.on_movenode) == "function" then
			count = count + 1
			local id = minetest.get_content_id(nodename)
			movenode_aware_nodeids[id] = nodedef
		end
	end
	minetest.log("action", "[jumpdrive] collected " .. count .. " 'on_movenode' aware nodes")
end)

function jumpdrive.move_mapdata(source_pos1, source_pos2, target_pos1, target_pos2)
	-- delta between source and target
	local delta_vector = vector.subtract(target_pos1, source_pos1)

	-- read source
	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(source_pos1, source_pos2)
	local source_area = VoxelArea:new({ MinEdge = e1, MaxEdge = e2 })
	local source_data = manip:get_data()
	local source_param1 = manip:get_light_data()
	local source_param2 = manip:get_param2_data()

	minetest.log("action", "[jumpdrive] read source-data")

	-- write target
	manip = minetest.get_voxel_manip()
	e1, e2 = manip:read_from_map(target_pos1, target_pos2)
	local target_area = VoxelArea:new({ MinEdge = e1, MaxEdge = e2 })
	local target_data = manip:get_data()
	local target_param1 = manip:get_light_data()
	local target_param2 = manip:get_param2_data()

	-- list of { from_pos, to_pos, }
	local movenode_list = {}

	minetest.log("action", "[jumpdrive] read target-data");

	for z = source_pos1.z, source_pos2.z do
		for y = source_pos1.y, source_pos2.y do
			for x = source_pos1.x, source_pos2.x do
				local from_pos = { x = x, y = y, z = z }
				local to_pos = vector.add(from_pos, delta_vector)

				local source_index = source_area:indexp(from_pos)
				local target_index = target_area:indexp(to_pos)

				-- copy block id
				local id = source_data[source_index]

				if mapped_content_ids[id] then
					-- replace original content id
					id = mapped_content_ids[id]
				end

				target_data[target_index] = id

				if id ~= c_air then
					-- check if we are on an edge
					local edge = { x = 0, y = 0, z = 0 }

					-- negative edge
					if source_pos1.x == x then edge.x = -1 end
					if source_pos1.y == y then edge.y = -1 end
					if source_pos1.z == z then edge.z = -1 end
					-- positive edge
					if source_pos2.z == x then edge.x = 1 end
					if source_pos2.y == y then edge.y = 1 end
					if source_pos2.z == z then edge.z = 1 end

					table.insert(movenode_list, {
						from_pos = from_pos,
						to_pos = to_pos,
						edge = edge,
						nodedef = movenode_aware_nodeids[id],

						-- legacy mesecon crap
						pos = to_pos,
						oldpos = from_pos,
						node = core.get_node(from_pos),
					})
				end

				-- copy params
				target_param1[target_index] = source_param1[source_index]
				target_param2[target_index] = source_param2[source_index]
			end
		end
	end


	manip:set_data(target_data)
	manip:set_light_data(target_param1)
	manip:set_param2_data(target_param2)
	manip:write_to_map()
	manip:update_map()

	return movenode_list
end
