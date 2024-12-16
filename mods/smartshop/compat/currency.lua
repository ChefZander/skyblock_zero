local f = string.format

local pairs_by_value = futil.table.pairs_by_value

local S = smartshop.S
local api = smartshop.api
local util = smartshop.util

local check_shop_add = util.check_shop_add_remainder
local check_shop_removed = util.check_shop_remove_remainder
local check_player_add = util.check_player_add_remainder
local check_player_removed = util.check_player_remove_remainder

local currency = {}
currency.available_currency = {}

function currency.register_currency(name, value)
	if minetest.registered_items[name] then
		currency.available_currency[name] = value
	else
		error(f("attempt to register unknown item as currency: %q", name))
	end
end

for name, value in pairs({
	-- standard currency
	["currency:minegeld_cent_5"] = 5,
	["currency:minegeld_cent_10"] = 10,
	["currency:minegeld_cent_25"] = 25,
	["currency:minegeld"] = 100,
	["currency:minegeld_2"] = 200,
	["currency:minegeld_5"] = 500,
	["currency:minegeld_10"] = 1000,
	["currency:minegeld_20"] = 2000,
	["currency:minegeld_50"] = 5000,
	["currency:minegeld_100"] = 10000,

	-- tunneler's abyss
	["currency:cent_1"] = 1,
	["currency:cent_2"] = 2,
	["currency:cent_5"] = 5,
	["currency:cent_10"] = 10,
	["currency:cent_20"] = 20,
	["currency:cent_50"] = 50,
	["currency:buck_1"] = 100,
	["currency:buck_2"] = 200,
	["currency:buck_5"] = 500,
	["currency:buck_10"] = 1000,
	["currency:buck_20"] = 2000,
	["currency:buck_50"] = 5000,
	["currency:buck_100"] = 10000,
	["currency:buck_200"] = 20000,
	["currency:buck_500"] = 50000,
	["currency:buck_1000"] = 100000,

	-- for testing code
	["smartshop:currency_1"] = 1,
	["smartshop:currency_2"] = 2,
	["smartshop:currency_5"] = 5,
	["smartshop:currency_10"] = 10,
	["smartshop:currency_20"] = 20,
	["smartshop:currency_50"] = 50,
	["smartshop:currency_100"] = 100,
	["smartshop:currency_10000"] = 10000,
}) do
	if minetest.registered_items[name] then
		currency.register_currency(name, value)
		smartshop.log("info", "available currency: %s=%q", name, tostring(value))
	end
end

function currency.is_currency(stack)
	if type(stack) == "string" then
		stack = ItemStack(stack)
	end
	local name = stack:get_name()
	return currency.available_currency[name] ~= nil
end

function currency.get_single_value(stack)
	if type(stack) == "string" then
		stack = ItemStack(stack)
	end
	local name = stack:get_name()
	return currency.available_currency[name] or 0
end

function currency.get_stack_value(stack)
	return currency.get_single_value(stack) * stack:get_count()
end

function currency.get_all_currency_in_inv(inv, kind)
	local all_currency = {}
	local all_counts = inv:get_all_counts(kind)
	for item, count in pairs(all_counts) do
		if currency.is_currency(item) then
			while count > 0 do
				local stack = ItemStack(item)
				local maxed_count = math.min(stack:get_stack_max(), count)
				stack:set_count(maxed_count)
				table.insert(all_currency, stack)
				count = count - maxed_count
			end
		end
	end
	-- sort by the value of individual bills, smallest bills first
	table.sort(all_currency, function(a, b)
		return currency.get_single_value(a) < currency.get_single_value(b)
	end)
	return all_currency
end

function currency.get_inv_value(inv, kind)
	local total_value = 0
	local all_currency = currency.get_all_currency_in_inv(inv, kind)
	for i = 1, #all_currency do
		total_value = total_value + currency.get_stack_value(all_currency[i])
	end
	return total_value
end

local function get_change_for_value(value)
	local items = {}
	local largest_first = pairs_by_value(currency.available_currency, function(a, b)
		return b < a
	end)
	for name, currency_value in largest_first do
		if currency_value <= value then
			local count = math.floor(value / currency_value)
			while count > 0 do
				local stack = ItemStack(name)
				local maxed_count = math.min(stack:get_stack_max(), count)
				stack:set_count(maxed_count)
				table.insert(items, stack)
				value = value - (currency_value * maxed_count)
				count = count - maxed_count
			end
			if value == 0 then
				break
			end
		end
	end
	if value > 0 then
		smartshop.util.error("currency changing: some value (%s) is remaining %s", value)
	end
	return items
end

function currency.remove_item(inv, stack, kind)
	local owed_value = currency.get_stack_value(stack)
	local inv_total_value = currency.get_inv_value(inv, kind)
	if owed_value > inv_total_value then
		return ItemStack()
	end

	local all_currency = currency.get_all_currency_in_inv(inv, kind)
	local i = 1
	while owed_value > 0 do
		local currency_stack = all_currency[i]
		local value = currency.get_stack_value(currency_stack)
		if value <= owed_value then
			inv:remove_item(currency_stack)
			owed_value = owed_value - value
			i = i + 1
		else
			local item_value = currency.get_single_value(currency_stack)
			local number_to_remove = math.ceil(owed_value / item_value)
			local stack_to_remove = ItemStack(currency_stack)
			stack_to_remove:set_count(number_to_remove)
			inv:remove_item(stack_to_remove)
			owed_value = owed_value - currency.get_stack_value(stack_to_remove)
			break
		end
	end

	if owed_value < 0 then
		local to_refund = get_change_for_value(-owed_value)
		for _, refund_stack in ipairs(to_refund) do
			local remainder = inv:add_item(refund_stack)
			if not remainder:is_empty() then
				return ItemStack()
			end
		end
	end

	return ItemStack(stack)
end

api.register_purchase_mechanic({
	name = "smartshop:currency",
	description = S("currency exchange"),
	allow_purchase = function(player, shop, i)
		local pay_stack = shop:get_pay_stack(i)
		local give_stack = shop:get_give_stack(i)
		local strict_meta = shop:is_strict_meta()

		if not (currency.is_currency(pay_stack) or currency.is_currency(give_stack)) then
			return
		end

		local player_inv = api.get_player_inv(player)
		local tmp_player_inv = player_inv:get_tmp_inv()
		local tmp_shop_inv = shop:get_tmp_inv()

		local success = true
		local player_removed, shop_removed

		if currency.is_currency(pay_stack) then
			player_removed = currency.remove_item(tmp_player_inv, pay_stack, "pay")
			success = success and not player_removed:is_empty()
		else
			local count = pay_stack:get_count()
			player_removed = tmp_player_inv:remove_item(pay_stack, strict_meta)
			success = success and (count == player_removed:get_count())
		end

		if not success then
			shop:destroy_tmp_inv(tmp_shop_inv)
			player_inv:destroy_tmp_inv(tmp_player_inv)
			return false
		end

		if currency.is_currency(give_stack) then
			shop_removed = currency.remove_item(tmp_shop_inv, give_stack, "give")
			success = success and not shop_removed:is_empty()
		else
			local count = give_stack:get_count()
			shop_removed = tmp_shop_inv:remove_item(give_stack, "give")
			success = success and (count == shop_removed:get_count())
		end

		if not success then
			shop:destroy_tmp_inv(tmp_shop_inv)
			player_inv:destroy_tmp_inv(tmp_player_inv)
			return false
		end

		local shop_remaining = tmp_shop_inv:add_item(player_removed, "pay")
		success = success and shop_remaining:is_empty()

		if not success then
			shop:destroy_tmp_inv(tmp_shop_inv)
			player_inv:destroy_tmp_inv(tmp_player_inv)
			return false
		end

		local player_remaining = tmp_player_inv:add_item(shop_removed)
		success = success and player_remaining:is_empty()

		shop:destroy_tmp_inv(tmp_shop_inv)
		player_inv:destroy_tmp_inv(tmp_player_inv)

		return success
	end,
	do_purchase = function(player, shop, i)
		local player_inv = api.get_player_inv(player)

		local pay_stack = shop:get_pay_stack(i)
		local give_stack = shop:get_give_stack(i)
		local strict_meta = shop:is_strict_meta()

		local shop_removed
		local shop_remaining
		local player_removed
		local player_remaining

		if currency.is_currency(pay_stack) then
			player_removed = currency.remove_item(player_inv, pay_stack, "pay")
		else
			player_removed = player_inv:remove_item(pay_stack, strict_meta)
		end

		if currency.is_currency(give_stack) then
			shop_removed = currency.remove_item(shop, give_stack, "give")
		else
			shop_removed = shop:remove_item(give_stack, "give")
		end

		shop_removed, player_removed = api.do_transaction_transforms(player, shop, i, shop_removed, player_removed)

		shop_remaining = shop:add_item(player_removed, "pay")
		player_remaining = player_inv:add_item(shop_removed)

		check_shop_removed(shop, shop_removed, give_stack)
		check_player_removed(player_inv, shop, player_removed, pay_stack)
		check_player_add(player_inv, shop, player_remaining)
		check_shop_add(shop, shop_remaining)
	end,
})

smartshop.compat.currency = currency
