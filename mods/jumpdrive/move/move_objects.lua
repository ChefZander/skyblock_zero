
-- invoked from move.lua
jumpdrive.move_objects = function(source_center, source_pos1, source_pos2, delta_vector)

	local margin = vector.new(0.5, 0.5, 0.5)
	local pos1 = vector.subtract(source_pos1, margin)
	local pos2 = vector.add(source_pos2, margin)

	local radius = math.ceil(vector.distance(source_center, pos2))

	local all_objects = minetest.get_objects_inside_radius(source_center, radius);
	for _,obj in ipairs(all_objects) do

		local objPos = obj:get_pos()

		local x_match = objPos.x >= pos1.x and objPos.x <= pos2.x
		local y_match = objPos.y >= pos1.y and objPos.y <= pos2.y
		local z_match = objPos.z >= pos1.z and objPos.z <= pos2.z

		if x_match and y_match and z_match and not obj:is_player() then
			minetest.log("action", "[jumpdrive] object:  @ " .. minetest.pos_to_string(objPos))

			-- coords in range
			local entity = obj:get_luaentity()

			if not entity then
				minetest.log("action", "[jumpdrive] moving object")
				obj:set_pos( vector.add(objPos, delta_vector) )

			elseif entity.name:find("^mobs_animal:") then
				minetest.log("action", "[jumpdrive] moving animal")
				obj:set_pos( vector.add(objPos, delta_vector) )

			elseif entity.name == "__builtin:item" then
				minetest.log("action", "[jumpdrive] moving dropped item")
				obj:set_pos( vector.add(objPos, delta_vector) )

			else
				minetest.log("action", "[jumpdrive] removing entity: " .. entity.name)
				obj:remove()

			end
		end
	end
end
