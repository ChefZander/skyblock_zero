local pos1 = { x=-50, y=-10, z=-50 }
local pos2 = { x=50, y=50, z=50 }

mtt.emerge_area(pos1, pos2)

mtt.register("basic move-test", function(callback)
	local source_pos1 = { x=0, y=0, z=0 }
	local source_pos2 = { x=5, y=5, z=5 }
	local target_pos1 = { x=10, y=10, z=10 }
	local target_pos2 = { x=15, y=15, z=15 }

	minetest.get_voxel_manip(source_pos1, source_pos1)
	local src_node = minetest.get_node(source_pos1)

	areas:add("dummy", "landscape", source_pos1, source_pos2)
	areas:save()

	assert(not minetest.is_protected(source_pos1, "dummy"))
	assert(minetest.is_protected(source_pos1, "dummy2"))

	jumpdrive.move(source_pos1, source_pos2, target_pos1, target_pos2)

	assert(not minetest.is_protected(source_pos1, "dummy"))
	assert(not minetest.is_protected(source_pos1, "dummy2"))

	assert(not minetest.is_protected(target_pos1, "dummy"))
	assert(minetest.is_protected(target_pos1, "dummy2"))

	minetest.get_voxel_manip(target_pos1, target_pos1)
	local target_node = minetest.get_node(target_pos1)

	if target_node.name ~= src_node.name then
		error("moved node name does not match")
	end

	if target_node.param2 ~= src_node.param2 then
		error("moved param2 does not match")
	end

	callback()
end)
