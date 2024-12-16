local get_object = smartshop.api.get_object

smartshop.nodes = {
	after_place_node = function(pos, placer, itemstack)
		local obj = get_object(pos)
		obj:initialize_metadata(placer)
		obj:initialize_inventory()
		obj:update_appearance()
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local obj = get_object(pos)
		obj:on_rightclick(node, player, itemstack, pointed_thing)
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local obj = get_object(pos)
		return obj:allow_metadata_inventory_put(listname, index, stack, player)
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local obj = get_object(pos)
		return obj:allow_metadata_inventory_take(listname, index, stack, player)
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local obj = get_object(pos)
		return obj:allow_metadata_inventory_move(from_list, from_index, to_list, to_index, count, player)
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local obj = get_object(pos)
		obj:on_metadata_inventory_put(listname, index, stack, player)
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local obj = get_object(pos)
		obj:on_metadata_inventory_take(listname, index, stack, player)
	end,

	can_dig = function(pos, player)
		local obj = get_object(pos)
		return obj:can_dig(player)
	end,

	on_destruct = function(pos)
		local obj = get_object(pos)
		return obj:on_destruct()
	end,

	make_variant_tiles = function(color)
		return { ("(smartshop_face.png)^(smartshop_border.png^[colorize:%s)"):format(color) }
	end,
}

smartshop.dofile("nodes", "shop")
smartshop.dofile("nodes", "storage")
