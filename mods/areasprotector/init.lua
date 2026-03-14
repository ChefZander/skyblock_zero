local creative_mode = core.settings:get_bool("creative_mode")

local function cyan(str)
	return core.colorize("#00FFFF", str)
end

local function red(str)
	return core.colorize("#FF5555", str)
end

local horizontal_reach_large = 25
local vertical_reach_large = 25

local horizontal_reach_small = 8
local vertical_reach_small = 8

local max_protectors = 1000

local core_no_protects_radius = 32

local function remove_display(pos)
	local objs = core.get_objects_inside_radius(pos, 0.5)
	for _, o in pairs(objs) do
		o:remove()
	end
	core.sound_play({ name = 'dialogue', gain = 0.8, pitch = 0.5 })
end

areas:registerProtectionCondition(function(pos1, pos2, name)
	local core_no_protects_pos1 = vector.add(pos2,
		vector.new(core_no_protects_radius, core_no_protects_radius, core_no_protects_radius))
	local core_no_protects_pos2 = vector.add(pos1,
		vector.new(-core_no_protects_radius, -core_no_protects_radius, -core_no_protects_radius))

	if #core.find_nodes_in_area(core_no_protects_pos1, core_no_protects_pos2, { "sbz_resources:the_core" }) > 0 then
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
		fs[#fs + 1] = string.format("label[0.3,%s;%s]", i + 0.5, core.formspec_escape(owners[i]))
		fs[#fs + 1] = string.format("button[5,%s;0.5,0.5;%s_x;x]", i + 0.25, core.formspec_escape(owners[i]))
		max_y = max_y + 1
	end
	if #owners ~= 12 then
		fs[#fs + 1] = "tooltip[add_more_owners_button;Add another owner]"
		fs[#fs + 1] = string.format("field[0.2,%s;5.6,1;add_more_owners;;]", max_y)
		fs[#fs + 1] = string.format("button[5,%s;0.5,0.5;add_more_owners_button;+]", max_y + 0.25)
	end
	return table.concat(fs)
end

local function on_receive_fields(pos, formname, fields, sender, horizontal_reach, vertical_reach)
	local meta = core.get_meta(pos)

	local owner_name = meta:get_string("owner")
	if sender:get_player_name() ~= owner_name then
		core.record_protection_violation(pos, sender:get_player_name())
		return
	end

	local owners = core.deserialize(meta:get_string("owners")) or {}
	local owners_area_id = core.deserialize(meta:get_string("owners_area_id")) or {}


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
	local new_owners = {}
	for k, v in pairs(owners) do
		new_owners[#new_owners + 1] = v
	end
	owners = new_owners
	if fields.add_more_owners_button then
		local name = fields.add_more_owners
		local pos1 = vector.add(pos, vector.new( horizontal_reach,  vertical_reach,  horizontal_reach))
		local pos2 = vector.add(pos, vector.new(-horizontal_reach, -vertical_reach, -horizontal_reach))
		local perm, err = areas:canPlayerAddArea(pos1, pos2, owner_name)
		if not perm then
			core.chat_send_player(owner_name, red("You are not allowed to protect that area: ") .. err)
			return
		end
		if string.find(name, "[\\%[%];,$]", 1, false) then
			core.chat_send_player(owner_name,
				red("You are not allowed to protect that area: ") ..
				"That name is obviously invalid.")
			return
		end
		if name == "" then
			core.chat_send_player(owner_name,
				red("You are not allowed to protect that area: ") ..
				"You need to fill out the field with a name")
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

	meta:set_string("owners", core.serialize(owners))
	meta:set_string("owners_area_id", core.serialize(owners_area_id))
	meta:set_string("formspec", get_formspec(owners, meta:get_string("is_open")))
end

local function on_place(itemstack, player, pointed, horizontal_reach, vertical_reach, sizeword)
	local pos = pointed.above
	if not sbz_api.is_air(pos) then
		return itemstack
	end
	local pos1 = vector.add(pos, vector.new( horizontal_reach,  vertical_reach,  horizontal_reach))
	local pos2 = vector.add(pos, vector.new(-horizontal_reach, -vertical_reach, -horizontal_reach))

	local name = player:get_player_name()
	local perm, err = areas:canPlayerAddArea(pos1, pos2, name)
	if not perm then
		core.chat_send_player(name, red("You are not allowed to protect that area: ") .. err)
		return itemstack
	end
	--[[
	local conflicts = core.find_nodes_in_area(pos1, pos2,
		{ "areasprotector:protector_small", "areasprotector:protector_large", })
	if conflicts and #conflicts > 0 and not core.check_player_privs(name, "areas") then
		core.chat_send_player(name,
			red("Another protector block is too close: ") ..
			"another protector block was found at " ..
			cyan(core.pos_to_string(conflicts[1])) ..
			", and this size of protector block cannot be placed within " .. cyan(tostring(horizontal_reach) .. "m") ..
			" of others.")
		return itemstack
	end
	]]
	local userareas = 0
	for k, v in pairs(areas.areas) do
		if v.owner == name and string.sub(v.name, 1, 28) == "Protected by Protector Block" then
			userareas = userareas + 1
		end
	end
	if userareas >= max_protectors and not core.check_player_privs(name, "areas") then
		core.chat_send_player(name,
			red("You are using too many protector blocks:") ..
			" this server allows you to use up to " ..
			cyan(tostring(max_protectors)) .. " protector blocks, and you already have " ..
			cyan(tostring(userareas)) .. ".")
		if sizeword == "small" then
			core.chat_send_player(name,
				"If you need to protect more, please consider using the larger protector blocks, using the chat commands instead, or at the very least taking the time to rename some of your areas to something more descriptive first.")
		else
			core.chat_send_player(name,
				"If you need to protect more, please consider using the chat commands instead, or at the very least take the time to rename some of your areas to something more descriptive first.")
		end
		return itemstack
	end
	local id = areas:add(name, "Protected by Protector Block at " .. core.pos_to_string(pos, 0), pos1, pos2)
	areas:save()
	local msg = string.format("The area from %s to %s has been protected as #%s", cyan(core.pos_to_string(pos1)),
		cyan(core.pos_to_string(pos2)), cyan(id))
	core.chat_send_player(name, msg)
	core.set_node(pos, { name = "areasprotector:protector_" .. sizeword })
	local meta = core.get_meta(pos)
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
		end
		for k, v in pairs(core.deserialize(oldmetadata.fields.owners_area_id) or {}) do
			if areas.areas[v] and areas:isAreaOwner(v, areas.areas[v].owner) then
				areas:remove(v)
			end
		end
		areas:save()
	end
end

local function on_punch(pos, node, puncher, sizeword)
	local objs = core.get_objects_inside_radius(pos, .5) -- a radius of .5 since the entity serialization seems to be not that precise
	local display_active = true
	for _, o in pairs(objs) do
		if (not o:is_player()) and o:get_luaentity().name == "areasprotector:display_" .. sizeword then
			o:remove()
			display_active = false
		end
	end
	if display_active then
		core.add_entity(pos, "areasprotector:display_" .. sizeword)
		core.sound_play({ name = 'dialogue', gain = 1.0 })
		core.after(15, remove_display, pos)
	else
		core.sound_play({ name = 'dialogue', gain = 0.8, pitch = 0.5 })
	end
end

local function on_step(self, dtime, sizeword)
	if core.get_node(self.object:get_pos()).name ~= "areasprotector:protector_" .. sizeword then
		self.object:remove()
		return
	end
end

local function make_display_nodebox(horizontal_reach, vertical_reach)
	-- Extend the protected area boundary slightly outward so the wireframe
	-- sits just outside the protected volume rather than flush with it.
	local HR = horizontal_reach + 0.55
	local VR = vertical_reach + 0.55

	-- Nodebox components are specified as { x1, y1, z1, x2, y2, z2 }.
	-- The four vertical slabs form the sides of the bounding box,
	-- the two flat slabs cap it at top and bottom, and the small cube
	-- surrounds the protector node itself at the origin.
	return {
		{ -HR,  -VR,  -HR,  -HR,   VR,   HR }, -- west
		{ -HR,  -VR,   HR,   HR,   VR,   HR }, -- north
		{  HR,  -VR,  -HR,   HR,   VR,   HR }, -- east
		{ -HR,  -VR,  -HR,   HR,   VR,  -HR }, -- south
		{ -HR,   VR,  -HR,   HR,   VR,   HR }, -- top
		{ -HR,  -VR,  -HR,   HR,  -VR,   HR }, -- bottom
		-- center cube surrounding the protector node itself
		{ -0.55, -0.55, -0.55, 0.55, 0.55, 0.55 },
	}
end

local area_protector_sounds = {
	footstep = { name = 'gen_metallic_hit',            gain = 1.0, pitch = 1.0, fade = 0.0 },
	dig      = { name = 'mix_thunk_slightly_metallic', gain = 1.0, pitch = 1.0, fade = 0.0 },
	dug      = { name = 'mix_metal_cabinet_hit',       gain = 1.0, pitch = 1.0, fade = 0.0 },
	place    = { name = 'mix_hollow_metal_clunk',      gain = 1.0, pitch = 1.0, fade = 0.0 },
}

core.register_node("areasprotector:protector_large", {
	description = "Large Protector Block",
	on_receive_fields = function(pos, formname, fields, sender)
		return on_receive_fields(pos, formname, fields, sender, horizontal_reach_large, vertical_reach_large)
	end,
	groups = { cracky = 1, matter = 1, protector = 1, no_spread = 1 },
	tiles = {
		"areasprotector_big.png",
		"areasprotector_big.png",
		"areasprotector_big_side.png"
	},
	sounds = area_protector_sounds,
	paramtype = "light",
	on_place = function(itemstack, player, pointed_thing)
		return on_place(itemstack, player, pointed_thing, horizontal_reach_large, vertical_reach_large, "large")
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		after_dig(pos, oldnode, oldmetadata, digger, "large")
	end,
	on_punch = function(pos, node, puncher)
		on_punch(pos, node, puncher, "large")
	end
})


core.register_node("areasprotector:protector_small", {
	description = "Small Protector Block",
	on_receive_fields = function(pos, formname, fields, sender)
		return on_receive_fields(pos, formname, fields, sender, horizontal_reach_small, vertical_reach_small)
	end,
	groups = { cracky = 1, matter = 1, protector = 1, no_spread = 1 },
	tiles = {
		"areasprotector_small.png",
		"areasprotector_small.png",
		"areasprotector_small_side.png"
	},
	sounds = area_protector_sounds,
	paramtype = "light",
	on_place = function(itemstack, player, pointed_thing)
		return on_place(itemstack, player, pointed_thing, horizontal_reach_small, vertical_reach_small, "small")
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		after_dig(pos, oldnode, oldmetadata, digger, "small")
	end,
	on_punch = function(pos, node, puncher)
		on_punch(pos, node, puncher, "small")
	end
})

mesecon.register_on_mvps_move(function(moved)
	if not moved.from_jumpdrive then -- from luacontroller
		local performed_area_operations = false
		for i = 1, #moved do
			local moved_node = moved[i]
			if core.get_item_group(moved_node.node.name, "protector") > 0 then
				local meta = core.get_meta(moved_node.pos)
				local id = meta:get_int("area_id")
				local owners_area_id = core.deserialize(meta:get_string("owners_area_id") or "") or {}
				local newpos1 = vector.add(vector.subtract(areas.areas[id].pos1, moved_node.oldpos), moved_node.pos)
				local newpos2 = vector.add(vector.subtract(areas.areas[id].pos2, moved_node.oldpos), moved_node.pos)
				if not core.is_area_protected(newpos1, newpos2, areas.areas[id].owner) then
					areas:move(id, areas.areas[id], newpos1, newpos2)
				end
				for k, area_id in pairs(owners_area_id) do
					newpos1 = vector.add(vector.subtract(areas.areas[area_id].pos1, moved_node.oldpos),
						moved_node.pos)
					newpos2 = vector.add(vector.subtract(areas.areas[area_id].pos2, moved_node.oldpos),
						moved_node.pos)
					if not core.is_area_protected(newpos1, newpos2, areas.areas[id].owner) then
						areas:move(area_id, areas.areas[area_id], newpos1, newpos2)
					end
				end

				performed_area_operations = true
			end
		end
		if performed_area_operations then areas:save() end
	end
end)

-- entities code below (and above) mostly copied-pasted from Zeg9's protector mod

local undone_wielditem_resize = { x = 1.0 / 1.5, y = 1.0 / 1.5 }
local empty_collision_box = { 0, 0, 0, 0, 0, 0 }

core.register_entity("areasprotector:display_large", {
	initial_properties = {
		physical = false,
		collisionbox = empty_collision_box,
		visual = "wielditem",
		visual_size = undone_wielditem_resize,
		textures = { "areasprotector:display_node_large" },
		backface_culling = false,
	},
	on_step = function(self, dtime)
		on_step(self, dtime, "large")
	end
})

core.register_entity("areasprotector:display_small", {
	initial_properties = {
		physical = false,
		collisionbox = empty_collision_box,
		visual = "wielditem",
		visual_size = undone_wielditem_resize,
		textures = { "areasprotector:display_node_small" },
		backface_culling = false,
	},
	on_step = function(self, dtime)
		on_step(self, dtime, "small")
	end
})

core.register_node("areasprotector:display_node_large", {
	tiles = { "areasprotector_display.png" },
	walkable = false,
	drawtype = "nodebox",
	use_texture_alpha = "clip",
	node_box = {
		type = "fixed",
		fixed = make_display_nodebox(horizontal_reach_large, vertical_reach_large)
	},
	selection_box = {
		type = "regular",
	},
	paramtype = "light",
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	drop = "",
})

core.register_node("areasprotector:display_node_small", {
	tiles = { "areasprotector_display.png" },
	walkable = false,
	drawtype = "nodebox",
	use_texture_alpha = "clip",
	node_box = {
		type = "fixed",
		fixed = make_display_nodebox(horizontal_reach_small, vertical_reach_small)
	},
	selection_box = {
		type = "regular",
	},
	paramtype = "light",
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	drop = "",
})

do -- Small Area Protector recipe scope
	local Small_Area_Protector = 'areasprotector:protector_small'
	local amount = 2
	local St = 'sbz_resources:stone'
	local RM = 'sbz_resources:reinforced_matter'
	local CI = 'sbz_chem:cobalt_ingot'
	core.register_craft({
		output = Small_Area_Protector .. ' ' .. tostring(amount),
		recipe = {
			{ St, RM, St },
			{ RM, CI, RM },
			{ St, RM, St },
		}
	})
end

do -- Large Area Protector recipe scope
	local Large_Area_Protector = 'areasprotector:protector_large'
	local PS = 'areasprotector:protector_small'
	core.register_craft({
		output = Large_Area_Protector,
		type = "shapeless",
		recipe = {
			PS, PS, PS,
			PS, PS, PS,
			PS, PS, PS,
		}
	})
end

core.register_alias("areasprotector:protector",    "areasprotector:protector_large")
core.register_alias("areasprotector:display_node", "areasprotector:display_node_large")
