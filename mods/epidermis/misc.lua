function epidermis.vector_axis_angle(euler_rotation)
	return modlib.quaternion.to_axis_angle(modlib.quaternion.from_euler_rotation(vector.multiply(euler_rotation, -1)))
end

function epidermis.on_cheat(player, cheat)
	local name = player:get_player_name()
	minetest.log("warning", "Kicked " .. name .. " for cheating: " .. modlib.json:write_string(cheat))
	minetest.kick_player(name, "Kicked for cheating")
end

local visible_wielditem = rawget(_G, "visible_wielditem")
function epidermis.register_tool(name, def)
	minetest.register_tool(name, def)
	if visible_wielditem then
		visible_wielditem.item_tweaks.names[name] = { rotation = vector.new(0, 0, -90) }
	end
end
