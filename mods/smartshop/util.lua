local v_new = vector.new

local equals = futil.equals
local pairs_by_key = futil.table.pairs_by_key
local FakeInventory = futil.FakeInventory

local error_behavior = smartshop.settings.error_behavior

local util = {}

function util.error(messagefmt, ...)
	local message = messagefmt:format(...)

	if error_behavior == "crash" then
		error(message)
	elseif error_behavior == "announce" then
		smartshop.chat_send_all(message)
	end

	smartshop.log("error", message)
end

function util.string_to_pos(pos_as_string)
	-- can't just use minetest.string_to_pos, for sake of backward compatibility
	if not pos_as_string or type(pos_as_string) ~= "string" then
		return nil
	end
	local x, y, z = pos_as_string:match("^%s*%(?%s*(%-?%d+)[%s,]+(%-?%d+)[%s,]+(%-?%d+)%s*%)?%s*$")
	if x and y and z then
		return v_new(tonumber(x), tonumber(y), tonumber(z))
	end
end

function util.player_is_admin(player_or_name)
	return minetest.check_player_privs(player_or_name, { [smartshop.settings.admin_shop_priv] = true })
end

function util.check_shop_add_remainder(shop, remainder)
	if remainder:is_empty() then
		return false
	end

	local owner = shop:get_owner()
	local pos_as_string = shop:get_pos_as_string()

	util.error(
		"ERROR: %s's smartshop @ %s lost %q while adding (shop inv=%s)",
		owner,
		pos_as_string,
		remainder:to_string(),
		dump(shop:get_lists())
	)

	return true
end

function util.check_shop_remove_remainder(shop, remainder, expected)
	if remainder:get_count() == expected:get_count() then
		return false
	end

	local owner = shop:get_owner()
	local pos_as_string = shop:get_pos_as_string()

	util.error(
		"ERROR: %s's smartshop @ %s lost %q of %q while removing (shop inv=%s)",
		owner,
		pos_as_string,
		remainder:to_string(),
		expected:to_string(),
		dump(shop:get_lists())
	)

	return true
end

function util.check_player_add_remainder(player_inv, shop, remainder)
	if remainder:get_count() == 0 then
		return false
	end

	local player_name = player_inv.name

	util.error(
		"ERROR: %s lost %q on add using %s's shop @ %s (shop inv=%s) (player_inv=%s)",
		player_name,
		remainder:to_string(),
		shop:get_owner(),
		shop:get_pos_as_string(),
		dump(shop:get_lists()),
		dump(player_inv:get_lists())
	)

	return true
end

function util.check_player_remove_remainder(player_inv, shop, remainder, expected)
	if remainder:get_count() == expected:get_count() then
		return false
	end

	local player_name = player_inv.name

	util.error(
		"ERROR: %s lost %q of %q on remove from %s's shop @ %s (shop inv=%s) (player_inv=%s)",
		player_name,
		remainder:to_string(),
		expected:to_string(),
		shop:get_owner(),
		shop:get_pos_as_string(),
		dump(shop:get_lists()),
		dump(player_inv:get_lists())
	)

	return true
end

function util.remove_stack_with_meta(inv, list_name, stack)
	local stack_name = stack:get_name()
	local stack_count = stack:get_count()
	local stack_wear = stack:get_wear()
	local stack_meta = stack:get_meta():to_table()
	local list_table = inv:get_list(list_name)

	for _, i_stack in ipairs(list_table) do
		local i_name = i_stack:get_name()
		local i_count = i_stack:get_count()
		local i_wear = i_stack:get_wear()
		local i_meta = i_stack:get_meta():to_table()
		if stack_name == i_name and stack_wear == i_wear and equals(stack_meta, i_meta) then
			if i_count >= stack_count then
				i_count = i_count - stack_count
				stack_count = 0
				i_stack:set_count(i_count)
				break
			else
				stack_count = stack_count - i_count
				i_stack:clear(0)
			end
		end
	end

	inv:set_list(list_name, list_table)

	-- returns the items that were actually removed
	local removed = ItemStack(stack)
	removed:set_count(stack:get_count() - stack_count)
	return removed
end

function util.get_stack_key(stack, match_meta)
	if match_meta then
		local key_stack = ItemStack(stack) -- clone
		local name = key_stack:get_name()
		local wear = key_stack:get_wear()
		local meta_parts = {}
		for key, value in pairs_by_key(key_stack:get_meta():to_table().fields) do
			table.insert(meta_parts, ("%s=%s"):format(key, value))
		end
		local key_parts = { name }
		if wear > 0 or #meta_parts > 0 then
			table.insert(key_parts, "1")
			table.insert(key_parts, tostring(wear))
		end
		if #meta_parts > 0 then
			table.insert(key_parts, table.concat(meta_parts, ","))
		end

		return table.concat(key_parts, " ")
	else
		return stack:get_name()
	end
end

function util.clone_fake_inventory(src_inv)
	local fake_inv = FakeInventory()

	fake_inv:set_size("main", src_inv:get_size("main"))
	fake_inv:set_list("main", src_inv:get_list("main"))

	return fake_inv
end

smartshop.util = util
