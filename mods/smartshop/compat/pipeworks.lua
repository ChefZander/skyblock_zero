-- luacheck: globals pipeworks
local get_object = smartshop.api.get_object

local function pipeworks_override(itemstring)
	local def = minetest.registered_nodes[itemstring]
	local after_place_node = def.after_place_node
	local after_dig_node = def.after_dig_node
	local groups = table.copy(def.groups)
	groups.tubedevice = 1
	groups.tubedevice_receiver = 1
	minetest.override_item(itemstring, {
		groups = groups,
		after_place_node = function(pos, placer, itemstack)
			if after_place_node then
				after_place_node(pos, placer, itemstack)
			end
			pipeworks.after_place(pos, placer, itemstack)
		end,
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			if after_dig_node then
				after_dig_node(pos, oldnode, oldmetadata, digger)
			end
			pipeworks.after_dig(pos, oldnode, oldmetadata, digger)
		end,
		tube = {
			can_insert = function(pos, node, stack, direction)
				local obj = get_object(pos)
				local inv = obj.inv
				return inv:room_for_item("main", stack) and stack:get_wear() == 0 and stack:is_known()
			end,
			insert_object = function(pos, node, stack, direction)
				local obj = get_object(pos)
				local inv = obj.inv
				local remainder = inv:add_item("main", stack)

				obj:update_appearance()

				return remainder
			end,
			input_inventory = "main",
			connect_sides = {
				left = 1,
				right = 1,
				front = 1,
				back = 1,
				top = 1,
				bottom = 1,
			},
		},
		-- we disallow rotation, so don't use this
		-- on_rotate = pipeworks.on_rotate,
	})
end

for _, variant in ipairs(smartshop.nodes.shop_node_names) do
	pipeworks_override(variant)
end

for _, variant in ipairs(smartshop.nodes.storage_node_names) do
	pipeworks_override(variant)
end
