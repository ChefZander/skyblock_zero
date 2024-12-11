local get_node = minetest.get_node
local swap_node = minetest.swap_node

local S = smartshop.S
local api = smartshop.api
local class = futil.class

--------------------

local node_class = smartshop.node_class
local storage_class = class(node_class)
smartshop.storage_class = storage_class

--------------------

function storage_class:get_title()
	if not self.meta:get("title") then
		self:set_title("storage@%s", self:get_pos_as_string())
	end
	return self.meta:get_string("title")
end

function storage_class:set_title(format, ...)
	self.meta:set_string("title", format:format(...))
	self.meta:mark_as_private("title")
end

--------------------

function storage_class:initialize_metadata(player)
	node_class.initialize_metadata(self, player)

	local player_name
	if type(player) == "string" then
		player_name = player
	else
		player_name = player:get_player_name()
	end

	self:set_infotext(S("External storage by: @1", player_name))
	self:set_title("storage@%s", self:get_pos_as_string())
end

function storage_class:initialize_inventory()
	node_class.initialize_inventory(self)

	local inv = self.inv
	inv:set_size("main", 60)
end

--------------------

function storage_class:show_formspec(player)
	if not self:can_access(player) then
		return
	end

	local formspec = api.build_storage_formspec(self)

	api.show_formspec(player, self.pos, formspec)
end

function storage_class:receive_fields(player, fields)
	if fields.quit then
		api.close_formspec(player)
		return
	end

	if not self:is_owner(player) then
		return
	end

	local changed = false
	if fields.private then
		self:set_private(fields.private == "true")
		changed = true
	end

	if fields.title then
		self:set_title(fields.title)
		changed = true
	end

	if changed then
		self:show_formspec(player)
	end
end

------------------

function storage_class:set_variant(variant)
	local node = get_node(self.pos)
	if node.name ~= variant then
		node.name = variant
		swap_node(self.pos, node)
	end
end

function storage_class:add_item(stack)
	local leftover = node_class.add_item(self, stack)
	self:set_variant("smartshop:storage_has_send")
	return leftover
end

function storage_class:remove_item(stack, match_meta)
	local removed = node_class.remove_item(self, stack, match_meta)
	if not self:contains_item(stack, match_meta) then
		self:set_variant("smartshop:storage_lacks_refill")
	end
	return removed
end

function storage_class:on_metadata_inventory_put(listname, index, stack, player)
	node_class.on_metadata_inventory_put(self, listname, index, stack, player)
	self:set_variant("smartshop:storage")
end

function storage_class:on_metadata_inventory_take(listname, index, stack, player)
	node_class.on_metadata_inventory_take(self, listname, index, stack, player)
	self:set_variant("smartshop:storage")
end
