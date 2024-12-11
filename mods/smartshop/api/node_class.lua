local check_player_privs = minetest.check_player_privs
local get_meta = minetest.get_meta
local pos_to_string = minetest.pos_to_string

local api = smartshop.api

local player_is_admin = smartshop.util.player_is_admin

local class = futil.class1
local formspec_pos = futil.formspec_pos

--------------------

local inv_class = smartshop.inv_class
local node_class = class(inv_class)
smartshop.node_class = node_class

--------------------

function node_class:_init(pos)
	if not (pos.x and pos.y and pos.z) then
		error(dump(pos))
	end
	self.pos = pos
	self.meta = get_meta(pos)
	if not self.meta then
		smartshop.util.error("could not get node metadata @ %s", minetest.pos_to_string(pos))
	end
	inv_class._init(self, self.meta:get_inventory())
end

function node_class:get_pos_as_string()
	return pos_to_string(self.pos)
end

function node_class:get_formspec_pos()
	return formspec_pos(self.pos)
end

--------------------

function node_class:set_owner(owner)
	self.meta:set_string("owner", owner)
	self.meta:mark_as_private("owner")
end

function node_class:get_owner()
	return self.meta:get_string("owner")
end

function node_class:is_owner(player)
	local player_name
	if type(player) == "string" then
		player_name = player
	elseif futil.is_player(player) then
		player_name = player:get_player_name()
	else
		return false
	end

	if player_is_admin(player_name) then
		return true
	elseif self:is_private() then
		return player_name == self:get_owner()
	else
		return not minetest.is_protected(self.pos, player_name)
	end
end

function node_class:set_infotext(infotext)
	self.meta:set_string("infotext", infotext)
end

function node_class:get_infotext()
	return self.meta:get_string("infotext")
end

function node_class:set_private(value)
	-- reverse the semantics of what's stored, because we want the default to be "is_private"
	self.meta:set_int("shared", value and 0 or 1)
	self.meta:mark_as_private("shared")
end

function node_class:is_private()
	-- reverse the semantics of what's stored, because we want the default to be "is_private"
	return self.meta:get_int("shared") == 0
end

--------------------

function node_class:is_shop()
	return api.is_shop(self.pos)
end

function node_class:is_storage()
	return api.is_storage(self.pos)
end

--------------------

function node_class:initialize_metadata(owner)
	local player_name
	if type(owner) == "string" then
		player_name = owner
	else
		player_name = owner:get_player_name()
	end

	self:set_owner(player_name)
	self:set_private(true)
end

--------------------

function node_class:on_destruct()
	-- noop
end

--------------------

function node_class:on_rightclick(node, player, itemstack, pointed_thing)
	self:show_formspec(player)
end

function node_class:show_formspec(player)
	-- noop
end

function node_class:receive_fields(player, fields)
	-- noop
end

--------------------

function node_class:update_appearance()
	-- noop
end

--------------------

function node_class:can_access(player)
	return (self:is_owner(player) or check_player_privs(player, { protection_bypass = true }))
end

function node_class:can_dig(player)
	return self.inv:is_empty("main") and self:can_access(player)
end

--------------------

function node_class:allow_metadata_inventory_put(listname, index, stack, player)
	if not self:can_access(player) or stack:get_wear() ~= 0 or not stack:is_known() then
		return 0
	else
		return stack:get_count()
	end
end

function node_class:allow_metadata_inventory_take(listname, index, stack, player)
	if not self:can_access(player) then
		return 0
	else
		return stack:get_count()
	end
end

function node_class:allow_metadata_inventory_move(from_list, from_index, to_list, to_index, count, player)
	if not self:can_access(player) then
		return 0
	else
		return count
	end
end

function node_class:on_metadata_inventory_put(listname, index, stack, player)
	smartshop.log(
		"action",
		"%s put %q in %s @ %s",
		player:get_player_name(),
		stack:to_string(),
		minetest.get_node(self.pos).name,
		minetest.pos_to_string(self.pos)
	)
end

function node_class:on_metadata_inventory_take(listname, index, stack, player)
	smartshop.log(
		"action",
		"%s took %q from %s @ %s",
		player:get_player_name(),
		stack:to_string(),
		minetest.get_node(self.pos).name,
		minetest.pos_to_string(self.pos)
	)
end
