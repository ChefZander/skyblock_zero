local get_node = minetest.get_node
local parse_json = minetest.parse_json
local pos_to_string = minetest.pos_to_string
local swap_node = minetest.swap_node
local write_json = minetest.write_json

local S = smartshop.S
local get_safe_short_description = futil.get_safe_short_description
local player_is_admin = smartshop.util.player_is_admin
local string_to_pos = smartshop.util.string_to_pos

local class = futil.class1
local table_is_empty = futil.table.is_empty

local api = smartshop.api

local history_max = smartshop.settings.history_max

local queue
if smartshop.has.node_entity_queue then
	queue = node_entity_queue.queue
end

--------------------

local node_class = smartshop.node_class
local shop_class = class(node_class)
smartshop.shop_class = shop_class

--------------------

function shop_class:initialize_metadata(player)
	node_class.initialize_metadata(self, player)

	local player_name
	if type(player) == "string" then
		player_name = player
	else
		player_name = player:get_player_name()
	end

	local is_admin = player_is_admin(player_name)

	self:set_upgraded()
	self:set_infotext(S("Shop by: @1", player_name))
	self:set_unlimited(is_admin)
	self:set_strict_meta(false)
	self:set_freebies(false)
end

function shop_class:initialize_inventory()
	node_class.initialize_inventory(self)

	local inv = self.inv
	inv:set_size("main", 32)
	for i = 1, 4 do
		inv:set_size(("give%i"):format(i), 1)
		inv:set_size(("pay%i"):format(i), 1)
	end
end

--------------------

function shop_class:is_admin()
	return player_is_admin(self:get_owner())
end

function shop_class:set_unlimited(value)
	self.meta:set_int("unlimited", value and 1 or 0)
	self.meta:mark_as_private("unlimited")
end

function shop_class:is_unlimited()
	return self.meta:get_int("unlimited") == 1
end

function shop_class:set_send_pos(send_pos)
	local pos_as_string = send_pos and pos_to_string(send_pos) or ""
	self.meta:set_string("item_send", pos_as_string)
	self.meta:mark_as_private("item_send")
end

function shop_class:get_send_pos()
	local string_as_pos = self.meta:get_string("item_send")
	return string_to_pos(string_as_pos)
end

function shop_class:get_send()
	local send_pos = self:get_send_pos()
	if send_pos then
		local send = api.get_object(send_pos)
		if not send or not send:is_owner(self:get_owner()) then
			self:set_send_pos()
		end
		return send
	end
end

function shop_class:get_send_inv()
	local send = self:get_send()
	if send then
		return send.inv
	end
end

function shop_class:set_refill_pos(refill_pos)
	local pos_as_string = refill_pos and pos_to_string(refill_pos) or ""
	self.meta:set_string("item_refill", pos_as_string)
	self.meta:mark_as_private("item_refill")
end

function shop_class:get_refill_pos()
	local string_as_pos = self.meta:get_string("item_refill")
	return string_to_pos(string_as_pos)
end

function shop_class:get_refill()
	local refill_pos = self:get_refill_pos()
	if refill_pos then
		local refill = api.get_object(refill_pos)
		if not refill or not refill:is_owner(self:get_owner()) then
			self:set_refill_pos()
		end
		return refill
	end
end

function shop_class:get_refill_inv()
	local refill = self:get_refill()
	if refill then
		return refill.inv
	end
end

function shop_class:set_upgraded()
	self.meta:set_string("upgraded", "true")
	self.meta:mark_as_private("upgraded")
end

function shop_class:has_upgraded()
	return self.meta:get("upgraded") == "true"
end

function shop_class:set_refund(refund)
	if table_is_empty(refund) then
		self.meta:set_string("refund", "")
	else
		self.meta:set_string("refund", write_json(refund))
	end
	self.meta:mark_as_private("refund")
end

function shop_class:get_refund()
	local refund = self.meta:get("refund")
	return (refund and parse_json(refund)) or {}
end

function shop_class:has_refund()
	return not not self.meta:get("refund")
end

function shop_class:set_strict_meta(value)
	self.meta:set_int("strict_meta", value and 1 or 0)
	self.meta:mark_as_private("strict_meta")
end

function shop_class:is_strict_meta()
	return self.meta:get_int("strict_meta") == 1
end

function shop_class:set_freebies(value)
	self.meta:set_int("freebies", value and 1 or 0)
	self.meta:mark_as_private("freebies")
end

function shop_class:allow_freebies()
	return self.meta:get_int("freebies") == 1
end

function shop_class:get_purchase_history()
	local history = self.meta:get("purchase_history")
	if history then
		return minetest.deserialize(history) or { index = 0 }
	else
		return { index = 0 }
	end
end

function shop_class:log_purchase(player, i, mechanic)
	local player_name = player:get_player_name()

	local give_stack = self:get_give_stack(i)
	local pay_stack = self:get_pay_stack(i)

	smartshop.log(
		"action",
		"%s bought %q for %q from %s's shop @ %s via %s",
		player_name,
		give_stack:to_string(),
		pay_stack:to_string(),
		self:get_owner(),
		self:get_pos_as_string(),
		mechanic
	)

	if history_max == 0 then
		return
	end

	local now = os.time()
	local strict_meta = self:is_strict_meta()

	local give_item, pay_item
	if strict_meta then
		give_item = get_safe_short_description(give_stack)
		pay_item = get_safe_short_description(pay_stack)
	else
		give_item = give_stack:get_name()
		pay_item = pay_stack:get_name()
	end

	local give_count = give_stack:get_count()
	local pay_count = pay_stack:get_count()

	local history = self:get_purchase_history()
	local most_recent = history[history.index]

	if
		most_recent
		and most_recent.player_name == player_name
		and most_recent.give_item == give_item
		and most_recent.pay_item == pay_item
		and most_recent.timestamp + 60 >= now
	then
		most_recent.give_count = most_recent.give_count + give_count
		most_recent.pay_count = most_recent.pay_count + pay_count
		most_recent.timestamp = now
	else
		-- treat the history like a ring buffer
		local cur_index = history.index
		local next_index
		if history_max > 0 and cur_index == history_max then
			next_index = 1
		else
			next_index = cur_index + 1
		end

		history.index = next_index
		history[next_index] = {
			player_name = player_name,
			give_item = give_item,
			give_count = give_count,
			pay_item = pay_item,
			pay_count = pay_count,
			timestamp = now,
			method = mechanic,
		}
	end

	self.meta:set_string("purchase_history", minetest.serialize(history))
	self.meta:mark_as_private("purchase_history")
end

--------------------

function shop_class:get_pay_stack(i)
	local inv = self.inv
	local listname = ("pay%i"):format(i)
	return inv:get_stack(listname, 1)
end

function shop_class:get_give_stack(i)
	local inv = self.inv
	local listname = ("give%i"):format(i)
	return inv:get_stack(listname, 1)
end

--------------------

function shop_class:link_storage(storage, storage_type)
	if storage_type == "send" then
		self:set_send_pos(storage.pos)
	elseif storage_type == "refill" then
		self:set_refill_pos(storage.pos)
	end

	self:update_appearance()
end

--------------------

function shop_class:get_count(stack, kind)
	local match_meta = self:is_strict_meta()
	local count = node_class.get_count(self, stack, match_meta)

	if kind == "give" then
		local refill = self:get_refill()
		if refill then
			count = count + refill:get_count(stack, match_meta)
		end
	elseif kind == "pay" then
		local send = self:get_send()
		if send then
			count = count + send:get_count(stack, match_meta)
		end
	end

	return count
end

function shop_class:get_all_counts(kind)
	local match_meta = self:is_strict_meta()
	local all_counts = node_class.get_all_counts(self, match_meta)

	if kind == "give" then
		local refill = self:get_refill()
		if refill then
			for key, value in pairs(refill:get_all_counts(match_meta)) do
				all_counts[key] = (all_counts[key] or 0) + value
			end
		end
	elseif kind == "pay" then
		local send = self:get_send()
		if send then
			for key, value in pairs(send:get_all_counts(match_meta)) do
				all_counts[key] = (all_counts[key] or 0) + value
			end
		end
	end

	return all_counts
end

function shop_class:give_is_valid(i)
	local give_stack = self:get_give_stack(i)

	if give_stack:is_known() and not give_stack:is_empty() then
		return true
	elseif self:allow_freebies() then
		local pay_stack = self:get_pay_stack(i)
		return pay_stack:is_known() and not pay_stack:is_empty()
	end

	return false
end

function shop_class:can_give_count(i)
	local stack = self:get_give_stack(i)
	return self:get_count(stack, "give")
end

function shop_class:pay_is_valid(i)
	local pay_stack = self:get_pay_stack(i)

	if pay_stack:is_known() and not pay_stack:is_empty() then
		return true
	elseif self:allow_freebies() then
		local give_stack = self:get_give_stack(i)
		return give_stack:is_known() and not give_stack:is_empty()
	end

	return false
end

function shop_class:has_pay(i, ignore_storage)
	local stack = self:get_pay_stack(i)
	return self:contains_item(stack, "pay", ignore_storage)
end

function shop_class:has_pay_count(i)
	local stack = self:get_pay_stack(i)
	return self:get_count(stack, "pay")
end

function shop_class:room_for_pay(i)
	local stack = self:get_pay_stack(i)
	return self:room_for_item(stack, "pay")
end

function shop_class:can_exchange(i)
	if not (self:give_is_valid(i) and self:pay_is_valid(i)) then
		return false
	end
	local tmp_inv = self:get_tmp_inv()
	local to_remove = self:get_give_stack(i)
	local count_to_remove = to_remove:get_count()
	local removed = tmp_inv:remove_item(to_remove, "give")
	local success = count_to_remove == removed:get_count()
	local to_pay = self:get_pay_stack(i)
	local leftover = tmp_inv:add_item(to_pay, "pay")
	success = success and (leftover:get_count() == 0)
	self:destroy_tmp_inv(tmp_inv)
	return success
end

function shop_class:room_for_item(stack, kind)
	if self:is_unlimited() then
		return true
	end

	if node_class.room_for_item(self, stack) then
		return true
	end

	if kind == "give" then
		local refill = self:get_refill()
		return refill and refill:room_for_item(stack)
	elseif kind == "pay" then
		local send = self:get_send()
		return send and send:room_for_item(stack)
	end
end

function shop_class:add_item(stack, kind)
	if self:is_unlimited() then
		return ItemStack()
	end

	if kind == "give" then
		local refill = self:get_refill()
		if refill and refill:room_for_item(stack) then
			return refill:add_item(stack)
		end
	elseif kind == "pay" then
		local send = self:get_send()
		if send and send:room_for_item(stack) then
			return send:add_item(stack)
		end
	end

	return node_class.add_item(self, stack)
end

function shop_class:contains_item(stack, kind, ignore_storage)
	if self:is_unlimited() then
		return true
	end

	local match_meta = self:is_strict_meta()

	if node_class.contains_item(self, stack, match_meta) then
		return true
	end

	if not ignore_storage then
		if kind == "give" then
			local refill = self:get_refill()
			return refill and refill:contains_item(stack, match_meta)
		elseif kind == "pay" then
			local send = self:get_send()
			return send and send:contains_item(stack, match_meta)
		end
	end

	return false
end

function shop_class:remove_item(stack, kind)
	if self:is_unlimited() then
		return stack
	end

	local strict_meta = self:is_strict_meta()

	if kind == "give" then
		local refill = self:get_refill()
		if refill and refill:contains_item(stack, strict_meta) then
			return refill:remove_item(stack, strict_meta)
		end
	elseif kind == "pay" then
		local send = self:get_send()
		if send and send:contains_item(stack, strict_meta) then
			return send:remove_item(stack, strict_meta)
		end
	end

	return node_class.remove_item(self, stack, strict_meta)
end

--------------------

function shop_class:on_destruct()
	self:clear_entities()
	for _, itemstring in ipairs(self:get_refund()) do
		minetest.add_item(self.pos, itemstring)
	end
end

--------------------

function shop_class:on_rightclick(node, player, itemstack, pointed_thing)
	if not self:is_admin() then
		-- if a shop is unlimited, but the owner no longer has admin privs, revert the shop
		self:set_unlimited(false)
	end

	node_class.on_rightclick(self, node, player, itemstack, pointed_thing)
end

function shop_class:show_formspec(player, force_client_view)
	local formspec
	if self:is_owner(player) and not force_client_view then
		formspec = api.build_owner_formspec(self)
	else
		formspec = api.build_client_formspec(self)
	end

	api.show_formspec(player, self.pos, formspec)
end

function shop_class:show_history(player)
	if not self:is_owner(player) then
		return
	end

	local formspec = api.build_history_formspec(self)

	api.show_formspec(player, self.pos, formspec)
end

local function get_buy_index(pressed)
	for i = 1, 4 do
		if pressed["buy" .. i .. "a"] or pressed["buy" .. i .. "b"] then
			return i
		end
	end
end

function shop_class:receive_fields(player, fields)
	local buy_index = get_buy_index(fields)
	local changed = false

	if fields.quit then
		api.close_formspec(player)
	elseif buy_index then
		api.try_purchase(player, self, buy_index)
		self:show_formspec(player, true)
	elseif self:is_owner(player) then
		if fields.history then
			self:show_history(player)
		elseif fields.close_history then
			self:show_formspec(player)
		elseif fields.tsend then
			api.close_formspec(player)
			api.start_storage_linking(player, self, "send")
		elseif fields.trefill then
			api.close_formspec(player)
			api.start_storage_linking(player, self, "refill")
		elseif fields.customer then
			self:show_formspec(player, true)
		else
			if fields.is_unlimited and player_is_admin(player) then
				self:set_unlimited(fields.is_unlimited == "true")
				changed = true
			end
			if fields.strict_meta then
				self:set_strict_meta(fields.strict_meta == "true")
				changed = true
			end
			if fields.private then
				self:set_private(fields.private == "true")
				changed = true
			end
			if fields.freebies then
				self:set_freebies(fields.freebies == "true")
				changed = true
			end
		end
	end

	if changed then
		self:show_formspec(player)
	end

	self:update_appearance()
end

--------------------

function shop_class:update_appearance()
	self:update_variant()
	self:update_info()
	self:update_entities()
end

function shop_class:get_info_line(i)
	if not self:can_exchange(i) then
		return
	end

	local give = self:get_give_stack(i)

	local description

	if self:is_strict_meta() then
		description = get_safe_short_description(give):gsub("%%", "%%%%")
	else
		description = get_safe_short_description(give:get_name()):gsub("%%", "%%%%")
	end

	local count = give:get_count()
	if count > 1 then
		description = ("%s*%i"):format(description, count)
	end

	if self:is_unlimited() then
		return ("(∞) %s"):format(description)
	end

	local give_count = self:can_give_count(i)
	if give_count == 0 then
		return
	end
	return ("(%i) %s"):format(give_count, description)
end

function shop_class:update_info()
	local owner = self:get_owner()
	local lines = { S("(Smartshop by @1)", owner) }

	local info_lines = {}
	for i = 1, 4 do
		local line = self:get_info_line(i)
		if line then
			table.insert(info_lines, line)
		end
	end

	if #info_lines == 0 then
		local variant = self:compute_variant()
		if variant == "smartshop:shop_full" then
			table.insert(lines, S("This shop is over-full."))
		elseif variant == "smartshop:shop_empty" then
			table.insert(lines, S("This shop is sold out."))
		else
			table.insert(lines, S("This shop is not configured."))
		end
	else
		table.insert_all(lines, info_lines)
	end

	self:set_infotext(table.concat(lines, "\n"))
end

function shop_class:can_give(i, ignore_storage)
	local give = self:get_give_stack(i)
	return self:contains_item(give, "give", ignore_storage)
end

function shop_class:compute_variant()
	if self:is_unlimited() then
		return "smartshop:shop_admin"
	end

	local n_total = 4
	local n_have_give = 0
	local n_have_pay = 0
	local n_can_exchange = 0

	for i = 1, 4 do
		if not self:pay_is_valid(i) or not self:give_is_valid(i) then
			n_total = n_total - 1
		else
			if self:can_give(i) then
				n_have_give = n_have_give + 1
			end
			if self:has_pay(i, true) and not self:get_pay_stack(i):is_empty() then
				n_have_pay = n_have_pay + 1
			end
			if self:can_exchange(i) then
				n_can_exchange = n_can_exchange + 1
			end
		end
	end

	if n_total == 0 then
		-- unconfigured shop
		return "smartshop:shop"
	elseif n_have_give ~= n_total then
		-- something is sold out
		return "smartshop:shop_empty"
	elseif n_have_pay > 0 then
		return "smartshop:shop_used"
	elseif n_can_exchange ~= n_total then
		-- something can't be bought
		return "smartshop:shop_full"
	else
		-- shop is ready for use
		return "smartshop:shop"
	end
end

function shop_class:update_variant()
	local to_swap = self:compute_variant()

	local node = get_node(self.pos)
	if node.name ~= to_swap then
		swap_node(self.pos, {
			name = to_swap,
			param1 = node.param1,
			param2 = node.param2,
		})
	end
end

function shop_class:clear_entities()
	api.clear_entities(self.pos)
end

function shop_class:update_entities()
	if queue then
		queue:push_back(function()
			api.update_entities(self)
		end)
	else
		api.update_entities(self)
	end
end

--------------------

function shop_class:allow_metadata_inventory_put(listname, index, stack, player)
	if node_class.allow_metadata_inventory_put(self, listname, index, stack, player) == 0 then
		return 0
	elseif listname == "main" then
		return stack:get_count()
	else
		-- interacting with give/pay slots
		local inv = self.inv

		local old_stack = inv:get_stack(listname, index)
		if old_stack:get_name() == stack:get_name() then
			local old_count = old_stack:get_count()
			local add_count = stack:get_count()
			local max_count = old_stack:get_stack_max()
			local new_count = math.min(old_count + add_count, max_count)
			old_stack:set_count(new_count)
			inv:set_stack(listname, index, old_stack)
		else
			inv:set_stack(listname, index, stack)
		end

		-- so we don't remove anything from the player's own stuff
		return 0
	end
end

function shop_class:allow_metadata_inventory_take(listname, index, stack, player)
	if node_class.allow_metadata_inventory_take(self, listname, index, stack, player) == 0 then
		return 0
	elseif listname == "main" then
		return stack:get_count()
	else
		local inv = self.inv
		local cur_stack = inv:get_stack(listname, index)
		local new_count = math.max(0, cur_stack:get_count() - stack:get_count())
		if new_count == 0 then
			cur_stack = ItemStack("")
		else
			cur_stack:set_count(new_count)
		end
		inv:set_stack(listname, index, cur_stack)
		return 0
	end
end

function shop_class:allow_metadata_inventory_move(from_list, from_index, to_list, to_index, count, player)
	if node_class.allow_metadata_inventory_move(self, from_list, from_index, to_list, to_index, count, player) == 0 then
		return 0
	elseif from_list == "main" and to_list == "main" then
		return count
	elseif from_list == "main" then
		local inv = self.inv
		local stack = inv:get_stack(from_list, from_index)
		stack:set_count(count)
		return self:allow_metadata_inventory_put(to_list, to_index, stack, player)
	elseif to_list == "main" then
		local inv = self.inv
		local stack = inv:get_stack(to_list, to_index)
		stack:set_count(count)
		return self:allow_metadata_inventory_take(from_list, from_index, stack, player)
	else
		return count
	end
end

function shop_class:on_metadata_inventory_put(listname, index, stack, player)
	if listname == "main" then
		node_class.on_metadata_inventory_put(self, listname, index, stack, player)
	end
end

function shop_class:on_metadata_inventory_take(listname, index, stack, player)
	if listname == "main" then
		node_class.on_metadata_inventory_take(self, listname, index, stack, player)
	end
end

--------------------

function shop_class:get_tmp_inv()
	return smartshop.tmp_shop_inv_class(self)
end
