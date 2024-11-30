minetest.register_craftitem("unifieddyes:colorium", {
	description = "Colorium",
	inventory_image = "colorium.png",
})
minetest.register_craft {
	type = "cooking",
	output = "unifieddyes:colorium",
	recipe = "unifieddyes:colorium_powder",
}

minetest.register_craftitem("unifieddyes:colorium_powder", {
	description = "Colorium Powder",
	inventory_image = "powder.png^[mask:colorium.png",
})
minetest.register_node("unifieddyes:colorium_blob", unifieddyes.def {
	description = "Colorium Blob",
	tiles = {
		"blank.png^[invert:rgba"
	},
	light_source = 14,
	info_extra = "A pure white colorable node.",
	groups = { matter = 1, antimatter = 1 }
})
minetest.register_craft {
	output = "unifieddyes:colorium_blob",
	recipe = {
		{ "unifieddyes:colorium", "unifieddyes:colorium", "unifieddyes:colorium", },
		{ "unifieddyes:colorium", "unifieddyes:colorium", "unifieddyes:colorium", },
		{ "unifieddyes:colorium", "unifieddyes:colorium", "unifieddyes:colorium", },
	}
}

stairs.register("unifieddyes:colorium_blob")

local function sheet(t, sx, sy, x, y)
	sx = sx + 1
	sy = sy + 1
	return ("%s^[sheet:%sx%s:%s,%s"):format(t, sx, sy, x, y)
end

local palette_sizes = {
	["unifieddyes_palette_colorfacedir.png"] = vector.new(8, 1, 0), -- im using vectors cuz z will be "how much is left off the last row" if that makes sense
	["unifieddyes_palette_extended.png"] = vector.new(24, 11, 8),
	["unifieddyes_palette_colorwallmounted.png"] = vector.new(8, 4, 0),
}

for k, v in pairs(palette_sizes) do
	palette_sizes[k] = vector.subtract(v, vector.new(1, 1, 1))
end

local function show_fs(user, palette)
	local size = palette_sizes[palette]
	if size == nil then
		minetest.chat_send_player(user:get_player_name(), "Node not supported!")
		return
	end

	local button_size = 0.8
	local button_spacing = 0.9

	local fs = {
		([[
formspec_version[7]
size[%s,%s]
	]]):format((size.x * button_spacing) + 1.2, 1.2 + (size.y * button_spacing)), -- 1.5 spacing for the rest
	}

	local head = #fs + 1

	local idx = 0

	for y = 0, size.y do
		for x = 0, size.x do
			idx = idx + 1
			if y == size.y and x >= (size.x - size.z) then
				break
			end
			fs[head] = string.format("image_button[%s,%s;%s,%s;%s;%s;]",
				(x * button_spacing) + 0.2, (y * button_spacing) + 0.2,
				button_size, button_size,
				minetest.formspec_escape(sheet(palette, size.x, size.y, x, y)), idx)
			head = head + 1
		end
	end

	minetest.show_formspec(user:get_player_name(), "color_dialog",
		table.concat(fs))
end
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "color_dialog" then return end

	local wield_item = player:get_wielded_item()
	if wield_item:get_name() ~= "unifieddyes:coloring_tool" then return end

	if fields.quit then return end
	if not next(fields) then return end

	local idx = tonumber(({ next(fields) })[1])
	if idx == nil then return end

	wield_item:get_meta():set_int("selected_index", idx)
	player:set_wielded_item(wield_item)
	minetest.chat_send_player(player:get_player_name(), "Updated the tool succesfully")
	minetest.show_formspec(player:get_player_name(), "color_dialog", "")
end)

_G.show_fs = show_fs



local function load_into(stack, player, pointed)
	if pointed.type ~= "node" then return end
	local pos = pointed.under
	local n = minetest.get_node(pos)
	local def = minetest.registered_nodes[n.name] or {}
	if not palette_sizes[def.palette or "no"] then
		minetest.chat_send_player(player:get_player_name(), "Node not supported!")
		return
	end
	show_fs(player, def.palette)
	stack:get_meta():set_string("palette", def.palette)
	return stack
end

local function color_block(stack, player, pointed)
	if pointed.type ~= "node" then return end
	local pos = pointed.under
	if minetest.is_protected(pos, player:get_player_name()) then
		minetest.chat_send_player(player:get_player_name(),
			"PROTECTED!!!!!")
		return
	end

	-- see if the player actually has the colorium

	local pinv = player:get_inventory()

	if not pinv:contains_item("main", "unifieddyes:colorium 1") then
		minetest.chat_send_player(player:get_player_name(), "You don't have the required colorium")
		return
	end

	local n = minetest.get_node(pos)
	local def = minetest.registered_nodes[n.name] or {}
	local pal = def.palette
	local meta = stack:get_meta()
	local stack_pal = meta:get_string("palette")
	if pal ~= stack_pal then
		minetest.chat_send_player(player:get_player_name(), "Palette mismatch, need to re-configure again")
		return load_into(stack, player, pointed)
	end
	local indx = meta:get_int("selected_index")

	local paramtype = def.paramtype2
	local rotation = 0
	rotation = n.param2 - minetest.strip_param2_color(n.param2, paramtype)

	local mul = 1
	if paramtype == "colorfacedir" then
		mul = 32
	elseif paramtype == "color4dir" then
		mul = 4
	elseif paramtype == "colorwallmounted" then
		mul = 8
	elseif paramtype == "colordegrotate" then
		mul = 32
	end
	indx = indx - 1
	minetest.swap_node(pos, { name = n.name, param2 = rotation + (math.floor(indx * mul)) })

	pinv:remove_item("main", "unifieddyes:colorium 1")
end

minetest.register_tool("unifieddyes:coloring_tool", {
	description = "Coloring Tool",
	inventory_image = "color_tool.png",
	liquids_pointable = false, -- colorable liquids probably wont exist but they would be funny
	light_source = 14,
	on_place = load_into,
	on_use = color_block,
	stack_max = 1
})
minetest.register_craft {
	output = "unifieddyes:coloring_tool",
	recipe = {
		{ "unifieddyes:colorium" },
		{ "sbz_resources:matter_dust" },
		{ "sbz_resources:matter_dust" }
	}
}
