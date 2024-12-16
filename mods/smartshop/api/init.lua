smartshop.api = {}

smartshop.dofile("api", "inv_class")
smartshop.dofile("api", "node_class")
smartshop.dofile("api", "shop_class")
smartshop.dofile("api", "storage_class")
smartshop.dofile("api", "player_inv_class")
smartshop.dofile("api", "tmp_inv_class")
smartshop.dofile("api", "tmp_shop_inv_class")

smartshop.dofile("api", "formspec")

smartshop.dofile("api", "purchase_mechanics")
smartshop.dofile("api", "storage_linking")

smartshop.dofile("api", "entities")

function smartshop.api.is_shop(pos)
	if not pos then
		return
	end
	local node_name = minetest.get_node(pos).name
	return minetest.get_item_group(node_name, "smartshop") > 0
end

function smartshop.api.is_storage(pos)
	if not pos then
		return
	end
	local node_name = minetest.get_node(pos).name
	return minetest.get_item_group(node_name, "smartshop_storage") > 0
end

--[[
	TODO: i'm not certain whether memoizing the returned objects is worth doing or not.
          also it'd require clearing the memo when a node is destroyed.
]]
function smartshop.api.get_object(pos)
	if not pos then
		return
	end

	minetest.load_area(pos)

	if not minetest.get_node_or_nil(pos) then
		smartshop.log(
			"warning",
			"trying to get shop/storage object for an unloaded area @ %s",
			minetest.pos_to_string(pos)
		)
	end

	if smartshop.api.is_shop(pos) then
		return smartshop.shop_class(pos)
	elseif smartshop.api.is_storage(pos) then
		return smartshop.storage_class(pos)
	end
end
