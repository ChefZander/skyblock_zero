local _ENV = {}

local components = {}
for _, value in pairs{
	"mod",
	"luon",
	"raycast",
	"schematic",
	"colorspec",
	"media",
	"obj",
	"texmod",
} do
	components[value] = value
end

-- These dirty files have to write to the modlib.minetest environment
local dirty_files = {}
for filename, comps in pairs{
	-- get_gametime is missing from here as it is forceloaded in init.lua
	misc = {
		"max_wear",
		"override",
		"after",
		"register_globalstep",
		"form_listeners",
		"register_form_listener",
		"texture_modifier_inventorycube",
		"get_node_inventory_image",
		"check_player_privs",
		"decode_base64",
		"objects_inside_radius",
		"objects_inside_area",
		"nodename_matcher",
		"playerdata",
		"connected_players",
		"set_privs",
		"register_on_leaveplayer",
		"get_mod_info",
		"get_mod_load_order"
	},
	liquid = {
		"liquid_level_max",
		"get_liquid_corner_levels",
		"flowing_downwards",
		"get_liquid_flow_direction"
	},
	wielditem_change = {
		"players",
		"registered_on_wielditem_changes",
		"register_on_wielditem_change"
	},
	colorspec = {
		"named_colors",
		"colorspec_to_colorstring"
	},
	boxes = {
		"get_node_boxes",
		"get_node_collisionboxes",
		"get_node_selectionboxes",
	},
	png = {
		"decode_png",
		"convert_png_to_argb8",
		"encode_png",
	}
} do
	for _, component in pairs(comps) do
		components[component] = filename
	end
	dirty_files[filename] = true
end

local modpath, concat_path = minetest.get_modpath(modlib.modname), modlib.file.concat_path

setmetatable(_ENV, {__index = function(_ENV, name)
	local filename = components[name]
	if filename then
		local loader = assert(loadfile(concat_path{modpath, "minetest", filename .. ".lua"}))
		if dirty_files[filename] then
			loader(_ENV)
			return rawget(_ENV, name)
		end
		local module = loader()
		_ENV[name] = module
		return module
	end
end})

return _ENV