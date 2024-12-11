local S = smartshop.S
local api = smartshop.api

local check_shop_add = smartshop.util.check_shop_add_remainder
local check_shop_removed = smartshop.util.check_shop_remove_remainder
local check_player_add = smartshop.util.check_player_add_remainder
local check_player_removed = smartshop.util.check_player_remove_remainder

api.registered_purchase_mechanics = {}
api.registered_on_purchases = {}
api.registered_on_shop_fulls = {}
api.registered_on_shop_emptys = {}
api.registered_transaction_transforms = {}

--[[
	TODO: mechanic definition isn't set in stone currently, see below
	      for an example
]]
function api.register_purchase_mechanic(def)
	table.insert(api.registered_purchase_mechanics, def)
end

function api.register_on_purchase(callback)
	table.insert(api.registered_on_purchases, callback)
end

function api.on_purchase(player, shop, i)
	for _, callback in ipairs(api.registered_on_purchases) do
		callback(player, shop, i)
	end
end

function api.register_on_shop_full(callback)
	table.insert(api.registered_on_shop_fulls, callback)
end

function api.on_shop_full(player, shop, i)
	for _, callback in ipairs(api.registered_on_shop_fulls) do
		callback(player, shop, i)
	end
end

function api.register_on_shop_empty(callback)
	table.insert(api.registered_on_shop_emptys, callback)
end

function api.on_shop_empty(player, shop, i)
	for _, callback in ipairs(api.registered_on_shop_emptys) do
		callback(player, shop, i)
	end
end

function api.register_transaction_transform(callback)
	table.insert(api.registered_transaction_transforms, callback)
end

function api.do_transaction_transforms(player, shop, i, shop_removed, player_removed)
	for _, callback in ipairs(api.registered_transaction_transforms) do
		shop_removed, player_removed = callback(player, shop, i, shop_removed, player_removed)
	end

	return shop_removed, player_removed
end

function api.try_purchase(player, shop, i)
	for _, def in ipairs(api.registered_purchase_mechanics) do
		if def.allow_purchase(player, shop, i) then
			def.do_purchase(player, shop, i)
			shop:log_purchase(player, i, def.description)
			api.on_purchase(player, shop, i)
			return true
		end
	end

	local reason = api.get_purchase_fail_reason(player, shop, i)
	smartshop.chat_send_player(player, ("Cannot exchange: %s"):format(reason))

	if reason == "Shop is sold out" then
		api.on_shop_empty(player, shop, i)
	elseif reason == "Shop is full" then
		api.on_shop_full(player, shop, i)
	end

	return false
end

function api.get_purchase_fail_reason(player, shop, i)
	local player_inv = api.get_player_inv(player)
	local pay_stack = shop:get_pay_stack(i)
	local give_stack = shop:get_give_stack(i)
	local strict_meta = shop:is_strict_meta()

	if not player_inv:contains_item(pay_stack, strict_meta) then
		return "You lack appropriate payment"
	elseif not shop:contains_item(give_stack, "give") then
		return "Shop is sold out"
	elseif not player_inv:room_for_item(give_stack) then
		return "No room in your inventory"
	elseif not shop:room_for_item(pay_stack, "pay") then
		return "Shop is full"
	end

	return "Failed for unknown reason"
end

api.register_purchase_mechanic({
	name = "smartshop:basic_purchase",
	description = S("normal exchange"),
	allow_purchase = function(player, shop, i)
		local player_inv = api.get_player_inv(player)
		local pay_stack = shop:get_pay_stack(i)
		local give_stack = shop:get_give_stack(i)
		local strict_meta = shop:is_strict_meta()

		local tmp_shop_inv = shop:get_tmp_inv()
		local tmp_player_inv = player_inv:get_tmp_inv()

		local count_to_remove = give_stack:get_count()
		local shop_removed = tmp_shop_inv:remove_item(give_stack, "give")
		local success = count_to_remove == shop_removed:get_count()

		count_to_remove = pay_stack:get_count()
		local player_removed = tmp_player_inv:remove_item(pay_stack, strict_meta)
		success = success and (count_to_remove == player_removed:get_count())

		local leftover = tmp_shop_inv:add_item(player_removed, "pay")
		success = success and (leftover:get_count() == 0)

		leftover = tmp_player_inv:add_item(shop_removed)
		success = success and (leftover:get_count() == 0)

		shop:destroy_tmp_inv(tmp_shop_inv)
		player_inv:destroy_tmp_inv(tmp_player_inv)

		return success
	end,
	do_purchase = function(player, shop, i)
		local player_inv = api.get_player_inv(player)
		local pay_stack = shop:get_pay_stack(i)
		local give_stack = shop:get_give_stack(i)
		local strict_meta = shop:is_strict_meta()

		local shop_removed = shop:remove_item(give_stack, "give")
		local player_removed = player_inv:remove_item(pay_stack, strict_meta)

		shop_removed, player_removed = api.do_transaction_transforms(player, shop, i, shop_removed, player_removed)

		local player_remaining = player_inv:add_item(shop_removed)
		local shop_remaining = shop:add_item(player_removed, "pay")

		check_shop_removed(shop, shop_removed, give_stack)
		check_player_removed(player_inv, shop, player_removed, pay_stack)
		check_player_add(player_inv, shop, player_remaining)
		check_shop_add(shop, shop_remaining)
	end,
})
