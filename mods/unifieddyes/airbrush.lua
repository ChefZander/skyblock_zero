--[=[
This file is part of unifieddyes mod.

Original mod.
Copyright (C) 2012-2025 Original unifieddyes Mod Contributors

Modifications for Skyblock: Zero.
Copyright (C) 2024-2025 Skyblock: Zero unifieddyes Mod Contributors

Please see COPYRIGHT.md for names of authors and contributors.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, see <https://www.gnu.org/licenses/>.
]=]

local function sheet(t, sx, sy, x, y)
	return ("%s^[sheet:%sx%s:%s,%s"):format(t, sx, sy, x, y)
end

-- cols/rows: tile counts in the source image
-- leftover:  missing tiles from the last row
local palette_sizes = {
	["unifieddyes_palette_colorfacedir.png"]     = { cols = 8, rows = 1, leftover = 0 },
	["unifieddyes_palette_extended.png"]         = { cols = 256, rows = 1, leftover = 0 },
	["unifieddyes_palette_colorwallmounted.png"] = { cols = 8, rows = 4, leftover = 0 },
}

local function show_fs(user, palette)
	local size = palette_sizes[palette]
	if size == nil then
		minetest.chat_send_player(user:get_player_name(), "Node not supported!")
		return
	end

	local button_size    = 0.8
	local button_spacing = 0.9
	local wrap           = 24 -- columns to wrap 1D palettes into
	local is_strip       = (size.rows == 1)
	local total          = size.cols * size.rows - size.leftover

	local display_cols, display_rows
	if is_strip then
		display_cols = math.min(total, wrap)
		display_rows = math.ceil(total / wrap)
	else
		display_cols = size.cols
		display_rows = size.rows
	end

	local fs = {
		([[
formspec_version[7]
size[%s,%s]
		]]):format(
			((display_cols - 1) * button_spacing) + 1.2,
			((display_rows - 1) * button_spacing) + 1.2
		),
	}

	local head = #fs + 1

	for idx = 0, total - 1 do
		local src_x, src_y, screen_x, screen_y
		if is_strip then
			src_x, src_y = idx, 0
			screen_x = idx % wrap
			screen_y = math.floor(idx / wrap)
		else
			src_x = idx % size.cols
			src_y = math.floor(idx / size.cols)
			screen_x, screen_y = src_x, src_y
		end

		fs[head] = string.format(
			"image_button[%s,%s;%s,%s;%s;%s;]",
			(screen_x * button_spacing) + 0.2,
			(screen_y * button_spacing) + 0.2,
			button_size, button_size,
			minetest.formspec_escape(sheet(palette, size.cols, size.rows, src_x, src_y)),
			idx + 1
		)
		head = head + 1
	end

	minetest.show_formspec(user:get_player_name(), "color_dialog", table.concat(fs))
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

do -- Coloring Tool recipe scope
	local Coloring_Tool = 'unifieddyes:coloring_tool'
	local Co = 'unifieddyes:colorium'
	local MD = 'sbz_resources:matter_dust'
	core.register_craft({
		output = Coloring_Tool,
		recipe = {
			{ Co },
			{ MD },
			{ MD },
		}
	})
end
