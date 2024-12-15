--[[
Minetest Mod Storage Drawers - A Mod adding storage drawers

Copyright (C) 2017-2020 Linus Jahn <lnj@kaidan.im>

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local MP = core.get_modpath(core.get_current_modname())

local S = minetest.get_translator('drawers')

drawers = {}
drawers.drawer_visuals = {}

drawers.enable_1x1 = true
drawers.enable_1x2 = true
drawers.enable_2x2 = true

drawers.CONTROLLER_RANGE = 40
drawers.CHEST_ITEMSTRING = "sbz_resources:storinator"

-- GUI

drawers.gui_bg = "bgcolor[#080808BB;true]"
drawers.gui_slots = "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"
function drawers.inventory_list(posy)
	local hotbar_row_posy = posy + 1.25
	local inventory_list = "list[current_player;main;0.5," .. posy .. ";8,1;]" ..
		"list[current_player;main;0.5," .. hotbar_row_posy .. ";8,3;8]"
	return inventory_list
end

--
-- Load API
--

dofile(MP .. "/helpers.lua")
dofile(MP .. "/visual.lua")
dofile(MP .. "/api.lua")
dofile(MP .. "/controller.lua")


--
-- Register drawers
--


drawers.register_drawer("drawers:drawer", {
	description = "Matter Drawer",
	tiles1 = drawers.node_tiles_front_other("drawers_matter_front_1.png", "drawers_matter.png"),
	tiles2 = drawers.node_tiles_front_other("drawers_matter_front_2.png", "drawers_matter.png"),
	tiles4 = drawers.node_tiles_front_other("drawers_matter_front_4.png", "drawers_matter.png"),
	groups = { matter = 1, oddly_breakable_by_hand = 2 },
	sounds = sbz_api.sounds.tree(),
	drawer_stack_max_factor = 32, -- 4 * 8 normal chest size
	material = "sbz_resources:reinforced_matter",
	info_extra = "If you aren't seeing drawer visuals, try using /drawers_fix"
})

-- Register drawer upgrades

drawers.register_drawer_upgrade("drawers:bronze_upgrade", {
	description = "Bronze Drawer Upgrade (2x)",
	inventory_image = "drawers_upgrade_bronze.png",
	groups = { drawer_upgrade = 100 },
	recipe_item = "sbz_chem:bronze_ingot"
})

drawers.register_drawer_upgrade("drawers:stemfruit_upgrade", {
	description = S("Stemfruit Drawer Upgrade (x3)"),
	inventory_image = "drawers_upgrade_stemfruit.png",
	groups = { drawer_upgrade = 200 },
	recipe_item = "sbz_bio:stemfruit"
})

drawers.register_drawer_upgrade("drawers:upgrade_colorium", {
	description = S("Colorium Drawer Upgrade (x4)"),
	inventory_image = "drawers_upgrade_colorium.png",
	groups = { drawer_upgrade = 300 },
	recipe_item = "unifieddyes:colorium_blob",
	info_extra = "Sorry, but it doesn't actually make the drawer color-able...",
})

drawers.register_drawer_upgrade("drawers:warpshroom_upgrade", {
	description = S("Warpshroom Drawer Upgrade (8x)"),
	inventory_image = "drawers_upgrade_warpshroom.png",
	groups = { drawer_upgrade = 700 },
	recipe_item = "sbz_bio:warpshroom"
})

-- TODO: DIAMOND UPGRADE inbetween as 16x

drawers.register_drawer_upgrade("drawers:neutronium_upgrade", { -- neutronium is super expensive so yea
	description = S("Neutronium Drawer Upgrade (32x)"),
	inventory_image = "drawers_upgrade_neutronium.png",
	groups = { drawer_upgrade = 3100 },
	recipe_item = "sbz_meteorites:neutronium"
})

drawers.register_drawer_upgrade("drawers:infinite_upgrade", {
	description = S("Creative Drawer Upgrade (1000000x)"),
	inventory_image = "drawers_upgrade_infinite.png",
	groups = { drawer_upgrade = 1000100, creative = 1 },
	no_craft = true,
})

-- Register drawer trim
-- or maybe don't...

--[[
core.register_node("drawers:drawer_connector", {
	description = "Drawer connector",
	tiles = { "drawers_trim.png" },
	groups = { drawer_connector = 1, matter = 2, oddly_breakable_by_hand = 2 },
	is_ground_content = false,
})

core.register_craft({
	output = "drawers:trim 6",
	recipe = {
		{ "group:stick", "group:wood", "group:stick" },
		{ "group:wood",  "group:wood", "group:wood" },
		{ "group:stick", "group:wood", "group:stick" }
	}
})
]]

-- Register drawer upgrade template

core.register_craftitem("drawers:upgrade_template", {
	description = "Drawer Upgrade Template",
	inventory_image = "drawers_upgrade_template.png"
})

core.register_craft({
	output = "drawers:upgrade_template 4",
	recipe = {
		{ "sbz_chem:gold_ingot",   "sbz_chem:nickel_ingot",    "sbz_chem:gold_ingot" },
		{ "sbz_chem:nickel_ingot", "sbz_resources:storinator", "sbz_chem:nickel_ingot" },
		{ "sbz_chem:gold_ingot",   "sbz_chem:nickel_ingot",    "sbz_chem:gold_ingot" }
	}
})


--[[
The code under this line is licensed under:

MIT License

Copyright (c) 2021 Pandorabox

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
minetest.register_chatcommand("drawers_fix", {
	description = "recreates the drawer-visuals in your area",
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if not player then
			return
		end
		local t1 = minetest.get_us_time()

		local ppos = player:get_pos()
		local pos1 = vector.subtract(ppos, 10)
		local pos2 = vector.add(ppos, 10)

		local poslist = minetest.find_nodes_in_area(pos1, pos2, { "group:drawer" })

		for _, pos in ipairs(poslist) do
			drawers.remove_visuals(pos)
			drawers.spawn_visuals(pos)
		end

		local t2 = minetest.get_us_time()
		local diff = t2 - t1
		local millis = diff / 1000

		return true, "Restored " .. #poslist .. " drawers in " .. millis .. " ms"
	end
})
