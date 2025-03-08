--
-- Register injectors for tubetool
--

local definition = {
	name = 'filter',
	nodes = {
		"pipeworks:automatic_filter_injector"
	},
	group = 'injector',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	-- get and store inventories data
	local inv_data = {}
	table.insert(inv_data, {})
	for slot = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", slot)
		local item
		if not stack:is_empty() then
			item = stack:to_table()
		end
		-- add item or empty
		table.insert(inv_data, item or "")
	end

	local slotseq_mode = meta:get_int("slotseq_mode")
	local slotseq_index = meta:get_int("slotseq_index")
	local exmatch_mode = meta:get_int("exmatch_mode")
	local description = core.registered_nodes[node.name].short_description

	-- return data required for replicating this injector settings
	return {
		description = description,
		inventory = inv_data,
		slotseq_mode = slotseq_mode,
		slotseq_index = slotseq_index,
		exmatch_mode = exmatch_mode,
	}
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	-- restore inventories data
	for index, item in ipairs(data.inventory) do
		inv:set_stack("main", index - 1, ItemStack(item))
	end

	meta:set_int("slotseq_mode", data.slotseq_mode)
	meta:set_int("slotseq_index", data.slotseq_index)
	if node.name == "pipeworks:filter" then
		meta:set_int("exmatch_mode", data.exmatch_mode)
	end

	-- update injector formspec
	local nodedef = minetest.registered_nodes[node.name]
	nodedef.on_receive_fields(pos, "", {}, player)
end

return definition
