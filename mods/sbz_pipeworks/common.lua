local S = minetest.get_translator("pipeworks")

-- Random variables

pipeworks.expect_infinite_stacks = true
if minetest.get_modpath("unified_inventory") or not minetest.settings:get_bool("creative_mode") then
	pipeworks.expect_infinite_stacks = false
end

pipeworks.meseadjlist = { { x = 0, y = 0, z = 1 }, { x = 0, y = 0, z = -1 }, { x = 0, y = 1, z = 0 }, { x = 0, y = -1, z = 0 }, { x = 1, y = 0, z = 0 }, { x = -1, y = 0, z = 0 } }

pipeworks.rules_all = { { x = 0, y = 0, z = 1 }, { x = 0, y = 0, z = -1 }, { x = 1, y = 0, z = 0 }, { x = -1, y = 0, z = 0 },
	{ x = 0, y = 1, z = 1 }, { x = 0, y = 1, z = -1 }, { x = 1, y = 1, z = 0 }, { x = -1, y = 1, z = 0 },
	{ x = 0, y = -1, z = 1 }, { x = 0, y = -1, z = -1 }, { x = 1, y = -1, z = 0 }, { x = -1, y = -1, z = 0 },
	{ x = 0, y = 1,  z = 0 }, { x = 0, y = -1, z = 0 } }


pipeworks.button_off = {
	text = "",
	texture = "pipeworks_button_off.png",
	addopts =
	"false;false;pipeworks_button_interm.png"
}
pipeworks.button_on = {
	text = "",
	texture = "pipeworks_button_on.png",
	addopts =
	"false;false;pipeworks_button_interm.png"
}
pipeworks.button_base = "image_button[0,4.3;1,0.6"
pipeworks.button_label = "label[0.9,4.31;" .. S("Allow splitting incoming stacks from tubes") .. "]"

-- Helper functions

function pipeworks.fix_image_names(table, replacement)
	local outtable = {}
	for i in ipairs(table) do
		outtable[i] = string.gsub(table[i], "_XXXXX", replacement)
	end

	return outtable
end

local function overlay_tube_texture(texture)
	-- The texture appears the first time to be colorized as the opaque background.
	return ("(%s)^[noalpha^[colorize:#dadada^(%s)"):format(texture, texture)
end

function pipeworks.make_tube_tile(tile)
	if pipeworks.use_real_entities then
		return tile
	elseif type(tile) == "string" then
		return overlay_tube_texture(tile)
	else
		tile = table.copy(tile)
		if tile.color then
			-- Won't work 100% of the time, but good enough.
			tile.name = tile.name .. "^[multiply:" .. minetest.colorspec_to_colorstring(tile.color)
			tile.color = nil
		end
		tile.name = overlay_tube_texture(tile.name)
		tile.backface_culling = nil -- The texture is opaque
		return tile
	end
end

function pipeworks.add_node_box(t, b)
	if not t or not b then return end
	for i in ipairs(b)
	do
		table.insert(t, b[i])
	end
end

function pipeworks.may_configure(pos, player)
	local name = player:get_player_name()
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")

	if owner ~= "" and owner == name then -- wielders and filters
		return true
	end
	return not minetest.is_protected(pos, name)
end

function pipeworks.replace_name(tbl, tr, name)
	local ntbl = {}
	for key, i in pairs(tbl) do
		if type(i) == "string" then
			ntbl[key] = string.gsub(i, tr, name)
		elseif type(i) == "table" then
			ntbl[key] = pipeworks.replace_name(i, tr, name)
		else
			ntbl[key] = i
		end
	end
	return ntbl
end

-----------------------
-- Facedir functions --
-----------------------

function pipeworks.facedir_to_top_dir(facedir)
	return ({ [0] = { x = 0, y = 1, z = 0 },
			{ x = 0,  y = 0,  z = 1 },
			{ x = 0,  y = 0,  z = -1 },
			{ x = 1,  y = 0,  z = 0 },
			{ x = -1, y = 0,  z = 0 },
			{ x = 0,  y = -1, z = 0 } })
		[math.floor(facedir / 4)]
end

function pipeworks.facedir_to_right_dir(facedir)
	facedir = facedir - (core.strip_param2_color(facedir, "colorfacedir") or 0)
	return vector.cross(
		pipeworks.facedir_to_top_dir(facedir),
		minetest.facedir_to_dir(facedir)
	)
end

local directions = {}
pipeworks.directions = directions
function directions.side_to_dir(side)
	return ({ [0] = vector.new(),
		vector.new(0, 1, 0),
		vector.new(0, -1, 0),
		vector.new(1, 0, 0),
		vector.new(-1, 0, 0),
		vector.new(0, 0, 1),
		vector.new(0, 0, -1)
	})[side]
end

function directions.dir_to_side(dir)
	local c = vector.dot(dir, vector.new(1, 2, 3)) + 4
	return ({ 6, 2, 4, 0, 3, 1, 5 })[c]
end

---------------------
-- Table functions --
---------------------

function pipeworks.table_contains(tbl, element)
	for _, elt in pairs(tbl) do
		if elt == element then
			return true
		end
	end
	return false
end

function pipeworks.table_extend(tbl, tbl2)
	local oldlength = #tbl
	for i = 1, #tbl2 do
		tbl[oldlength + i] = tbl2[i]
	end
end

function pipeworks.table_recursive_replace(tbl, pattern, replace_with)
	if type(tbl) == "table" then
		local tbl2 = {}
		for key, value in pairs(tbl) do
			tbl2[key] = pipeworks.table_recursive_replace(value, pattern, replace_with)
		end
		return tbl2
	elseif type(tbl) == "string" then
		return tbl:gsub(pattern, replace_with)
	else
		return tbl
	end
end

------------------------
-- Formspec functions --
------------------------

local fs_helpers = {}
pipeworks.fs_helpers = fs_helpers
function fs_helpers.on_receive_fields(pos, fields)
	local meta = minetest.get_meta(pos)
	for field in pairs(fields) do
		if field:match("^fs_helpers_cycling:") then
			local l = field:split(":")
			local new_value = tonumber(l[2])
			local meta_name = l[3]
			meta:set_int(meta_name, new_value)
		end
	end
end

function fs_helpers.cycling_button(meta, base, meta_name, values)
	local current_value = meta:get_int(meta_name)
	local new_value = (current_value + 1) % (#values)
	local val = values[current_value + 1]
	local text
	local texture_name = nil
	local addopts = nil
	--when we get a table, we know the caller wants an image_button
	if type(val) == "table" then
		text = val["text"]
		texture_name = val["texture"]
		addopts = val["addopts"]
	else
		text = val
	end
	local field = "fs_helpers_cycling:" .. new_value .. ":" .. meta_name
	return base ..
		";" ..
		(texture_name and texture_name .. ";" or "") ..
		field .. ";" .. minetest.formspec_escape(text) .. (addopts and ";" .. addopts or "") .. "]"
end

function fs_helpers.get_inv(y)
	local fs = {}
	if minetest.get_modpath("i3") then
		local inv_x = i3.settings.legacy_inventory and 0.75 or 0.22
		local inv_y = (y + 0.4) or 6.9
		local size, spacing = 1, 0.1
		local hotbar_len = i3.settings.hotbar_len or (i3.settings.legacy_inventory and 8 or 9)
		local inv_size = i3.settings.inv_size or (hotbar_len * 4)

		table.insert(fs, "style_type[box;colors=#77777710,#77777710,#777,#777]")

		for i = 0, hotbar_len - 1 do
			table.insert(fs, "box[" .. (i * size + inv_x + (i * spacing)) .. "," .. inv_y .. ";" .. size ..
				"," .. size .. ";]")
		end

		table.insert(fs, "style_type[list;size=" .. size .. ";spacing=" .. spacing .. "]")
		table.insert(fs, "list[current_player;main;" .. inv_x .. "," .. inv_y .. ";" .. hotbar_len .. ",1;]")

		table.insert(fs, "style_type[box;colors=#666]")
		for i = 0, 2 do
			for j = 0, hotbar_len - 1 do
				table.insert(fs,
					"box[" ..
					0.2 + (j * 0.1) + (j * size) ..
					"," .. (inv_y + size + spacing + 0.05) + (i * 0.1) + (i * size) .. ";" .. size .. "," .. size .. ";]")
			end
		end

		table.insert(fs, "style_type[list;size=" .. size .. ";spacing=" .. spacing .. "]")
		table.insert(fs,
			"list[current_player;main;" ..
			inv_x .. "," .. (inv_y + 1.15) .. ";" .. hotbar_len .. "," .. (inv_size / hotbar_len) .. ";" ..
			hotbar_len .. "]")
	elseif minetest.get_modpath("mcl_formspec") then
		local inv_x = 0.22
		local inv_y = (y + 0.4) or 6.9
		local size, spacing = 1, 0.1
		local hotbar_len = 9
		local inv_size = hotbar_len * 4

		table.insert(fs, "style_type[box;colors=#77777710,#77777710,#777,#777]")

		for i = 0, hotbar_len - 1 do
			table.insert(fs, "box[" .. (i * size + inv_x + (i * spacing)) .. "," .. inv_y .. ";" .. size ..
				"," .. size .. ";]")
		end

		table.insert(fs, "style_type[list;size=" .. size .. ";spacing=" .. spacing .. "]")
		table.insert(fs, "list[current_player;main;" .. inv_x .. "," .. inv_y .. ";" .. hotbar_len .. ",1;]")

		table.insert(fs, "style_type[box;colors=#666]")
		for i = 0, 2 do
			for j = 0, hotbar_len - 1 do
				table.insert(fs,
					"box[" ..
					0.2 + (j * 0.1) + (j * size) ..
					"," .. (inv_y + size + spacing + 0.05) + (i * 0.1) + (i * size) .. ";" .. size .. "," .. size .. ";]")
			end
		end

		table.insert(fs, "style_type[list;size=" .. size .. ";spacing=" .. spacing .. "]")
		table.insert(fs,
			"list[current_player;main;" ..
			inv_x .. "," .. (inv_y + 1.15) .. ";" .. hotbar_len .. "," .. (inv_size / hotbar_len) .. ";" ..
			hotbar_len .. "]")
	else
		table.insert(fs, "list[current_player;main;0.22," .. y .. ";8,4;]")
	end

	return table.concat(fs, "")
end

function fs_helpers.get_prepends(size)
	local prepend = {}

	if minetest.get_modpath("i3") then
		prepend = {
			"no_prepend[]",
			"bgcolor[black;neither]",
			"background9[0,0;" .. size .. ";i3_bg_full.png;false;10]",
			"style_type[button;border=false;bgimg=[combine:16x16^[noalpha^[colorize:#6b6b6b]",
			"listcolors[#0000;#ffffff20]"
		}
	end

	return table.concat(prepend, "")
end

---------
-- Env --
---------

function pipeworks.load_position(pos)
	if pos.x < -30912 or pos.y < -30912 or pos.z < -30912 or
		pos.x > 30927 or pos.y > 30927 or pos.z > 30927 then
		return
	end
	if minetest.get_node_or_nil(pos) then
		return
	end
	local vm = minetest.get_voxel_manip()
	vm:read_from_map(pos, pos)
end
