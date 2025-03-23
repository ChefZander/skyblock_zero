local S = wrench.translator

local tool_uses = tonumber(minetest.settings:get("wrench.tool_uses")) or 100

minetest.register_tool("sbz_wrench:wrench", {
	description = S("Node Preserver"),
	info_extra = "From the mt-mods/wrench mod!",
	inventory_image = "wrench_tool.png",
	on_use = function(stack, player, pointed)
		if not player or not pointed or not pointed.under then
			return
		end
		local picked_up, err_msg = wrench.pickup_node(pointed.under, player)
		if not picked_up then
			if err_msg then
				local name = player:get_player_name()
				minetest.chat_send_player(name, err_msg)
			end
			return
		end
		if tool_uses > 0 then
			stack:add_wear(65535 / tool_uses)
		end
		return stack
	end,
})

core.register_craft({
	output = "sbz_wrench:wrench",
	recipe = {
		{ "sbz_resources:phlogiston" },
		{ "sbz_resources:robotic_arm" },
	}
})
