-- Things that changed:
-- support is now automatic

local S = wrench.translator

local SERIALIZATION_VERSION = 2

local compress_data = minetest.settings:get_bool("wrench.compress_data", true)

local errors = {
	owned = function(owner) return S("Cannot pickup node. Owned by @1.", owner) end,
	bad_item = function(item) return S("Cannot pickup node containing @1.", item) end,
	full_inv = S("Not enough room in inventory to pickup node."),
	nested = S("Cannot pickup node. Nesting inventories is not allowed."),
	metadata = S("Cannot pickup node. Node contains too much metadata. (Too much information)"),
	missing_inv = S("Cannot pickup node. Node is missing inventory."),
	unknown = S("Cannot pickup node. Node doesn't contain metadata?"),
	cant_dig = S("A robotic arm cannot dig that node."),
}

local getdesc = function(node)
	return minetest.registered_nodes[node.name].short_description or minetest.registered_nodes[node.name].description or
	node.name
end

function wrench.description_with_items(pos, meta, node, player)
	local desc = getdesc(node)
	return S("@1 with items", desc)
end

function wrench.description_with_text(pos, meta, node, player)
	local text = meta:get_string("text")
	if #text > 32 then
		text = text:sub(1, 24) .. "..."
	end
	local desc = getdesc(node)
	return S("@1 with text \"@2\"", desc, text)
end

function wrench.description_with_configuration(pos, meta, node, player)
	local desc = getdesc(node)
	return S("@1 with configuration", desc)
end

local function get_description(def, pos, meta, node, player)
	if type(def.description) == "string" then
		return def.description
	elseif type(def.description) == "function" then
		local desc = def.description(pos, meta, node, player)
		if desc then
			return desc
		end
	end

	if def.meta.inventories then
		return wrench.description_with_items(pos, meta, node, player)
	elseif def.meta and def.meta.fields.text then
		return wrench.description_with_text(pos, meta, node, player)
	else
		return wrench.description_with_configuration(pos, meta, node, player)
	end
end

local function save_data(stack, data, desc)
	local meta = stack:get_meta()
	data = minetest.serialize(data)
	if compress_data then
		data = minetest.encode_base64(minetest.compress(data, "deflate"))
		meta:set_string("wrench_compressed", "true")
	end
	meta:set_string("data", data)
	meta:set_string("description", desc)
	return stack
end

local function get_data(stack)
	local meta = stack:get_meta()
	local data = meta:get("data")
	if not data then
		return nil
	end
	if meta:get("wrench_compressed") == "true" then
		data = minetest.decompress(minetest.decode_base64(data), "deflate")
	end
	data = minetest.deserialize(data)
	if not data or not data.version or not data.name then
		return nil
	end
	return data
end

local function safe_to_pickup(def, tmeta, inv)
	if next(tmeta.fields) == nil and next(tmeta.inventory) == nil then
		return false
	end
	return true
end

function wrench.pickup_node(pos, player)
	local node = minetest.get_node(pos)

	local def = core.registered_nodes[node.name]
	if not def then
		return
	end
	if not (minetest.get_dig_params(def.groups, core.registered_items["sbz_resources:robotic_arm"].tool_capabilities) or {}).diggable then
		return errors.cant_dig
	end

	local pickup_override = false
	if def.wrench_can_pickup then
		local can_pickup, err_msg = def.wrench_can_pickup(pos, player)
		if can_pickup == false then
			return false, err_msg
		elseif can_pickup == true then
			pickup_override = true
		end
	end

	local meta = minetest.get_meta(pos)
	if not pickup_override then
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			return
		end
		if def.owned and not minetest.check_player_privs(player, "protection_bypass") then
			local owner = meta:get_string("owner")
			if owner ~= "" and owner ~= player:get_player_name() then
				return false, errors.owned(owner)
			end
		end
	end
	local inv = meta:get_inventory()
	local tmeta = meta:to_table()
	if not safe_to_pickup(def, tmeta, inv) then
		return false, errors.unknown
	end
	local data = {
		name = def.drop or node.name,
		version = SERIALIZATION_VERSION,
		meta = tmeta, -- { fields = fields, inventory = inventory (list of lists)}
	}
	-- validate lists
	for listname, list in pairs(data.meta.inventory) do
		for i, stack in ipairs(list) do
			if stack:is_empty() then
				list[i] = ""
			else
				if wrench.blacklisted_items[stack:get_name()] then
					local desc = stack:get_description()
					return false, errors.bad_item(desc)
				end
				local sdata = get_data(stack)
				if sdata and sdata.meta.inventories and next(sdata.meta.inventories) ~= nil then
					return false, errors.nested
				end
				list[i] = stack:to_string()
			end
		end
	end

	local timer = minetest.get_node_timer(pos)
	data.timer = {
		timeout = timer:get_timeout(),
		elapsed = timer:get_elapsed()
	}

	local drop_node = table.copy(node)
	if def.drop then
		drop_node.name = def.drop
	end

	local stack = ItemStack(drop_node.name)
	save_data(stack, data, get_description(def, pos, meta, drop_node, player))

	if #stack:to_string() > 65000 then
		return false, errors.metadata
	end

	local player_inv = player:get_inventory()
	if not player_inv:room_for_item("main", stack) then
		return false, errors.full_inv
	end
	player_inv:add_item("main", stack)
	if def.before_pickup then
		def.before_pickup(pos, meta, node, player)
	end
	local meta_table = meta:to_table()
	minetest.remove_node(pos)
	if def.after_pickup then
		def.after_pickup(pos, node, meta_table, player)
	end
	local node_def = minetest.registered_nodes[node.name]
	if wrench.has_pipeworks and node_def.tube then
		pipeworks.after_dig(pos)
	end
	return true
end

function wrench.restore_node(pos, player, stack, pointed)
	if not stack then
		return
	end
	local data = get_data(stack)
	if not data then
		return
	end
	local def = core.registered_nodes[data.name]
	if not def then
		return
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	for listname, list in pairs(data.meta.inventory) do
		inv:set_list(listname, list)
	end
	for name, value in pairs(data.meta.fields) do
		meta:set_string(name, value)
	end
	if data.timer then
		local timer = minetest.get_node_timer(pos)
		if data.timer.timeout == 0 then
			timer:stop()
		else
			timer:set(data.timer.timeout, data.timer.elapsed)
		end
	end
	if def.groups and (def.groups.drawer or 0) > 0 then
		drawers.spawn_visuals(pos)
	end
	--[[
	if def.after_place_node then
		def.after_place_node(pos, player, stack, pointed)
	end
	]]
	return true
end
