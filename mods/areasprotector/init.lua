local creative_mode = minetest.settings:get_bool("creative_mode")

local function cyan(str)
	return minetest.colorize("#00FFFF", str)
end

local function red(str)
	return minetest.colorize("#FF5555", str)
end

local radius_large = 25
local height_large = 25

local radius_small = 8
local height_small = 8

local max_protectors = 1000

local core_no_protects_radius = 32

local function remove_display(pos)
	local objs = minetest.get_objects_inside_radius(pos, 0.5)
	for _, o in pairs(objs) do
		o:remove()
	end
end

areas:registerProtectionCondition(function(pos1, pos2, name)
	local core_no_protects_pos1 = vector.add(pos2,
		vector.new(core_no_protects_radius, core_no_protects_radius, core_no_protects_radius))
	local core_no_protects_pos2 = vector.add(pos1,
		vector.new(-core_no_protects_radius, -core_no_protects_radius, -core_no_protects_radius))

	if #minetest.find_nodes_in_area(core_no_protects_pos1, core_no_protects_pos2, { "sbz_resources:the_core" }) > 0 then
		return false, "Too close to core"
	end
end)

local function get_formspec(owners, opened_up)
	local ifs = string.format([[
formspec_version[7]
size[6,15]
position[0.3,0.5]
label[0.3,0.5;Owners:]
checkbox[0.2,14;open;Open;%s]
]], opened_up)

	local fs = { ifs }

	local max_y = 1
	for i = 1, #owners do -- max 13
		fs[#fs + 1] = string.format("box[0.2,%s;5.6,1;grey]", i)
		fs[#fs + 1] = string.format("label[0.3,%s;%s]", i + 0.5, minetest.formspec_escape(owners[i]))
		fs[#fs + 1] = string.format("button[5,%s;0.5,0.5;%s_x;x]", i + 0.25, minetest.formspec_escape(owners[i]))
		max_y = max_y + 1
	end
	if #owners ~= 12 then
		fs[#fs + 1] = "tooltip[add_more_owners_button;Add another owner]"
		fs[#fs + 1] = string.format("field[0.2,%s;5.6,1;add_more_owners;;]", max_y)
		fs[#fs + 1] = string.format("button[5,%s;0.5,0.5;add_more_owners_button;+]", max_y + 0.25)
	end
	return table.concat(fs)
end

local function on_receive_fields(pos, formname, fields, sender, radius, height)
	local meta = minetest.get_meta(pos)

	local owner_name = meta:get_string("owner")
	if sender:get_player_name() ~= owner_name then
		minetest.record_protection_violation(pos, sender:get_player_name())
		return
	end

	local owners = minetest.deserialize(meta:get_string("owners")) or {}
	local owners_area_id = minetest.deserialize(meta:get_string("owners_area_id")) or {}


	local remove_theese = {}

	for k, _ in pairs(fields) do
		if string.sub(k, - #"_x") == "_x" then
			remove_theese[string.sub(k, 1, - #"_x" - 1)] = true
		end
	end

	for k, v in ipairs(owners) do
		if remove_theese[v] then
			if areas.areas[owners_area_id[owners[k]]] then
				areas:remove(owners_area_id[owners[k]])
				areas:save()
			end
			owners_area_id[owners[k]] = nil
			owners[k] = nil
		end
	end

	if fields.add_more_owners_button then
		local name = fields.add_more_owners
		local pos1 = vector.add(pos, vector.new(radius, height, radius))
		local pos2 = vector.add(pos, vector.new(-radius, -height, -radius))
		local perm, err = areas:canPlayerAddArea(pos1, pos2, owner_name)
		if not perm then
			minetest.chat_send_player(owner_name, red("You are not allowed to protect that area: ") .. err)
			return
		end
		if string.find(name, "[\\%[%];,$]", 1, false) then
			minetest.chat_send_player(owner_name,
				red("You are not allowed to protect that area: ") ..
				"That name is obviously invalid and also it would be slightly tricky displaying it so like yeah")
			return
		end
		owners_area_id[name] = areas:add(name, "Protector block sub-area", pos1, pos2, meta:get_int("area_id"))
		areas:save()
		owners[#owners + 1] = fields.add_more_owners
	end

	local duplicate_checks = {}
	for k, v in ipairs(owners) do
		if not duplicate_checks[v] then
			duplicate_checks[v] = true
		else
			table.remove(owners, k)
		end
	end
	if fields.open ~= nil then
		local open = nil
		if fields.open == "true" then
			open = true
		elseif fields.open == "false" then
			open = false
		end
		areas.areas[meta:get_int("area_id")].open = open or nil
		meta:set_string("is_open", fields.open)
		areas:save()
	end

	meta:set_string("owners", minetest.serialize(owners))
	meta:set_string("owners_area_id", minetest.serialize(owners_area_id))
	meta:set_string("formspec", get_formspec(owners, meta:get_string("is_open")))
end

local function on_place(itemstack, player, pointed, radius, height, sizeword)
	local pos = pointed.above
	local pos1 = vector.add(pos, vector.new(radius, height, radius))
	local pos2 = vector.add(pos, vector.new(-radius, -height, -radius))



	local name = player:get_player_name()
	local perm, err = areas:canPlayerAddArea(pos1, pos2, name)
	if not perm then
		minetest.chat_send_player(name, red("You are not allowed to protect that area: ") .. err)
		return itemstack
	end
	local conflicts = minetest.find_nodes_in_area(pos1, pos2,
		{ "areasprotector:protector_small", "areasprotector:protector_large", })
	if conflicts and #conflicts > 0 and not minetest.check_player_privs(name, "areas") then
		minetest.chat_send_player(name,
			red("Another protector block is too close: ") ..
			"another protector block was found at " ..
			cyan(minetest.pos_to_string(conflicts[1])) ..
			", and this size of protector block cannot be placed within " .. cyan(tostring(radius) .. "m") ..
			" of others.")
		return itemstack
	end
	local userareas = 0
	for k, v in pairs(areas.areas) do
		if v.owner == name and string.sub(v.name, 1, 28) == "Protected by Protector Block" then
			userareas = userareas + 1
		end
	end
	if userareas >= max_protectors and not minetest.check_player_privs(name, "areas") then
		minetest.chat_send_player(name,
			red("You are using too many protector blocks:") ..
			" this server allows you to use up to " ..
			cyan(tostring(max_protectors)) .. " protector blocks, and you already have " ..
			cyan(tostring(userareas)) .. ".")
		if sizeword == "small" then
			minetest.chat_send_player(name,
				"If you need to protect more, please consider using the larger protector blocks, using the chat commands instead, or at the very least taking the time to rename some of your areas to something more descriptive first.")
		else
			minetest.chat_send_player(name,
				"If you need to protect more, please consider using the chat commands instead, or at the very least take the time to rename some of your areas to something more descriptive first.")
		end
		return itemstack
	end
	local id = areas:add(name, "Protected by Protector Block at " .. minetest.pos_to_string(pos, 0), pos1, pos2)
	areas:save()
	local msg = string.format("The area from %s to %s has been protected as #%s", cyan(minetest.pos_to_string(pos1)),
		cyan(minetest.pos_to_string(pos2)), cyan(id))
	minetest.chat_send_player(name, msg)
	minetest.set_node(pos, { name = "areasprotector:protector_" .. sizeword })
	local meta = minetest.get_meta(pos)
	local infotext = string.format("Protecting area %d owned by %s", id, name)
	meta:set_string("formspec", get_formspec({}))
	meta:set_string("infotext", infotext)
	meta:set_int("area_id", id)
	meta:set_string("owner", name)
	if not creative_mode then
		itemstack:take_item()
	end
	return itemstack
end

local function after_dig(pos, oldnode, oldmetadata, digger, sizeword)
	if oldmetadata and oldmetadata.fields then
		local owner = oldmetadata.fields.owner
		local id = tonumber(oldmetadata.fields.area_id)
		if areas.areas[id] and areas:isAreaOwner(id, owner) then
			areas:remove(id)
			areas:save()
		end
		for k, v in pairs(minetest.deserialize(oldmetadata.fields.owners_area_id) or {}) do
			if areas.areas[v] then
				areas:remove(v)
				areas:save()
			end
		end
	end
end

local function on_punch(pos, node, puncher, sizeword)
	local objs = minetest.get_objects_inside_radius(pos, .5) -- a radius of .5 since the entity serialization seems to be not that precise
	local removed = false
	for _, o in pairs(objs) do
		if (not o:is_player()) and o:get_luaentity().name == "areasprotector:display_" .. sizeword then
			o:remove()
			removed = true
		end
	end
	if not removed then -- nothing was removed: there wasn't the entity
		minetest.add_entity(pos, "areasprotector:display_" .. sizeword)
		minetest.after(4, remove_display, pos)
	end
end

local function on_step(self, dtime, sizeword)
	if minetest.get_node(self.object:get_pos()).name ~= "areasprotector:protector_" .. sizeword then
		self.object:remove()
		return
	end
end

local function make_display_nodebox(radius, height)
	local nb_radius = radius + 0.55
	local nb_height = height + 0.55
	local t = {
		-- sides
		{ -nb_radius, -nb_height, -nb_radius, -nb_radius, nb_height,  nb_radius },
		{ -nb_radius, -nb_height, nb_radius,  nb_radius,  nb_height,  nb_radius },
		{ nb_radius,  -nb_height, -nb_radius, nb_radius,  nb_height,  nb_radius },
		{ -nb_radius, -nb_height, -nb_radius, nb_radius,  nb_height,  -nb_radius },
		-- top
		{ -nb_radius, nb_height,  -nb_radius, nb_radius,  nb_height,  nb_radius },
		-- bottom
		{ -nb_radius, -nb_height, -nb_radius, nb_radius,  -nb_height, nb_radius },
		-- middle (surround protector)
		{ -.55,       -.55,       -.55,       .55,        .55,        .55 },
	}
	return t
end

local nbox = {
	type = "fixed",
	fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
}


minetest.register_node("areasprotector:protector_large", {
	description = "Large Protector Block",
	on_receive_fields = function(pos, formname, fields, sender)
		return on_receive_fields(pos, formname, fields, sender, radius_large, height_large)
	end,
	groups = { cracky = 1, matter = 1, protector = 1 },
	tiles = {
		"areasprotector_big.png",
		"areasprotector_big.png",
		"areasprotector_big_side.png"
	},
	paramtype = "light",
	drawtype = "nodebox",
	node_box = nbox,
	on_place = function(itemstack, player, pointed_thing)
		return on_place(itemstack, player, pointed_thing, radius_large, height_large, "large")
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		after_dig(pos, oldnode, oldmetadata, digger, "large")
	end,
	on_punch = function(pos, node, puncher)
		on_punch(pos, node, puncher, "large")
	end
})


minetest.register_node("areasprotector:protector_small", {
	description = "Small Protector Block",
	on_receive_fields = function(pos, formname, fields, sender)
		return on_receive_fields(pos, formname, fields, sender, radius_small, height_small)
	end,
	groups = { cracky = 1, matter = 1, protector = 1 },
	tiles = {
		"areasprotector_small.png",
		"areasprotector_small.png",
		"areasprotector_small_side.png"
	},
	paramtype = "light",
	drawtype = "nodebox",
	node_box = nbox,
	on_place = function(itemstack, player, pointed_thing)
		return on_place(itemstack, player, pointed_thing, radius_small, height_small, "small")
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		after_dig(pos, oldnode, oldmetadata, digger, "small")
	end,
	on_punch = function(pos, node, puncher)
		on_punch(pos, node, puncher, "small")
	end
})

mesecon.register_on_mvps_move(function(moved)
	local performed_area_operations = false
	for i = 1, #moved do
		local moved_node = moved[i]
		if core.get_item_group(moved_node.node.name, "protector") > 0 then
			local meta = core.get_meta(moved_node.node.name)
			local id = meta:get_int("area_id")
			local owners_area_id = minetest.deserialize(meta:get_string("owners_area_id")) or {}
			areas:move(id, areas.areas[id],
				vector.add(vector.subtract(areas.areas[id].pos1, moved_node.oldpos), moved_node.pos),
				vector.add(vector.subtract(areas.areas[id].pos2, moved_node.oldpos), moved_node.pos))
			for k, area_id in pairs(owners_area_id) do
				areas:move(area_id, areas.areas[area_id],
					vector.add(vector.subtract(areas.areas[area_id].pos1, moved_node.oldpos), moved_node.pos),
					vector.add(vector.subtract(areas.areas[area_id].pos2, moved_node.oldpos), moved_node.pos))
			end

			performed_area_operations = true
		end
	end
	if performed_area_operations then areas:save() end
end)

-- entities code below (and above) mostly copied-pasted from Zeg9's protector mod

-- wielditem seems to be scaled to 1.5 times original node size
local vsize = { x = 1.0 / 1.5, y = 1.0 / 1.5 }
local ecbox = { 0, 0, 0, 0, 0, 0 }

minetest.register_entity("areasprotector:display_large", {
	physical = false,
	collisionbox = ecbox,
	visual = "wielditem",
	visual_size = vsize,
	textures = { "areasprotector:display_node_large" },
	on_step = function(self, dtime)
		on_step(self, dtime, "large")
	end
})

minetest.register_entity("areasprotector:display_small", {
	physical = false,
	collisionbox = ecbox,
	visual = "wielditem",
	visual_size = vsize,
	textures = { "areasprotector:display_node_small" },
	on_step = function(self, dtime)
		on_step(self, dtime, "small")
	end
})

minetest.register_node("areasprotector:display_node_large", {
	tiles = { "areasprotector_display.png" },
	walkable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = make_display_nodebox(radius_large, height_large)
	},
	selection_box = {
		type = "regular",
	},
	paramtype = "light",
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	drop = "",
	sounds = sbz_api.sounds.machine(),
})

minetest.register_node("areasprotector:display_node_small", {
	tiles = { "areasprotector_display.png" },
	walkable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = make_display_nodebox(radius_small, height_small)
	},
	selection_box = {
		type = "regular",
	},
	paramtype = "light",
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	drop = "",
	sounds = sbz_api.sounds.machine(),
})

minetest.register_craft({
	output = "areasprotector:protector_small 2",
	recipe = {
		{ "sbz_resources:stone",             "sbz_resources:reinforced_matter", "sbz_resources:stone" },
		{ "sbz_resources:reinforced_matter", "sbz_chem:cobalt_ingot",           "sbz_resources:reinforced_matter" },
		{ "sbz_resources:stone",             "sbz_resources:reinforced_matter", "sbz_resources:stone" },
	}
})

minetest.register_craft({
	output = "areasprotector:protector_large",
	type = "shapeless",
	recipe = {
		"areasprotector:protector_small",
		"areasprotector:protector_small",
		"areasprotector:protector_small",
		"areasprotector:protector_small",
		"areasprotector:protector_small",
		"areasprotector:protector_small",
		"areasprotector:protector_small",
		"areasprotector:protector_small",
		"areasprotector:protector_small"
	}
})

minetest.register_alias("areasprotector:protector", "areasprotector:protector_large")
minetest.register_alias("areasprotector:display_node", "areasprotector:display_node_large")
