--
-- Register sorting tube for tubetool
--


local inv_size = 6
local nodes = { "pipeworks:item_sorter" }

local definition = {
	name = 'item_sorter',
	nodes = nodes,
	group = 'sorting tube',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	-- get and store direction bits
	local enabled = {}
	for i = 1, 6 do
		table.insert(enabled, meta:get_int("l" .. i .. "s"))
	end

	-- get and store inventories data
	local inv_data = {}
	local itemcount = 0
	for i = 1, 6 do
		table.insert(inv_data, {})
		for slot = 1, inv_size do
			local stack = inv:get_stack("line" .. i, slot)
			local item
			if not stack:is_empty() then
				item = stack:get_name()
				itemcount = itemcount + 1
			end
			-- add item or empty, do not care about count because sorting tube also does not care
			table.insert(inv_data[i], item or "")
		end
	end

	-- return data required for replicating this tube settings
	return {
		description = string.format("Items: %d States: %s", itemcount, table.concat(enabled, ",")),
		enabled = enabled,
		inventory = inv_data,
	}
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	-- restore direction bits
	for index, value in ipairs(data.enabled) do
		meta:set_int("l" .. index .. "s", value)
	end

	-- restore inventories data
	for index, slots in ipairs(data.inventory) do
		for slotidx, item in ipairs(slots) do
			inv:set_stack("line" .. index, slotidx, ItemStack(item))
		end
	end

	-- update tube formspec, this seems to be cleanest solution
	local nodedef = minetest.registered_nodes[node.name]
	nodedef.on_receive_fields(pos, "", {}, player)
end

return definition
