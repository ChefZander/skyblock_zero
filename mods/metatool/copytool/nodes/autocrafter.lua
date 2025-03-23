local definition = {
	name = 'autocrafter',
	nodes = {
		"pipeworks:autocrafter",
	},
	group = 'autocrafter',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	-- get and store recipe inventory data
	local recipe = {}
	for slot = 1, inv:get_size("recipe") do
		local stack = inv:get_stack("recipe", slot)
		table.insert(recipe, stack:get_name())
	end

	-- return data required for replicating this autocrafter configuration
	return {
		description = core.registered_nodes[node.name].short_description,
		recipe = recipe,
		enabled = meta:get_int("enabled"),
		maxpow = meta:get_int("maxpow"),
		reserved_slots = meta:get_string("reserved_slots")
	}
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	-- restore recipe data, trigger_stack is used to trigger autocrafter internal recipe cleanup
	local trigger_stack, trigger_index
	for index = 1, #data.recipe do
		local stack = ItemStack(data.recipe[index])
		if data.recipe[index] ~= "" then
			stack:set_count(1)
			trigger_stack = stack
			trigger_index = index
		else
			stack:set_count(0)
		end
		inv:set_stack("recipe", index, stack)
	end
	meta:set_string("reserved_slots", data.reserved_slots)
	meta:set_int("maxpow", data.maxpow)
	-- on/off goes backwards and tells current state that will be toggled: on to turn off, off to turn on
	local nodedef = minetest.registered_nodes[node.name]
	if trigger_stack then
		nodedef.allow_metadata_inventory_put(pos, "recipe", trigger_index, trigger_stack, player)
	else
		nodedef.allow_metadata_inventory_take(pos, "output", 1, inv:get_stack("output", 1), player)
	end
	nodedef.on_receive_fields(pos, "", { [data.enabled == 0 and "on" or "off"] = 1 }, player)
end

return definition
