--[[
Luanti Mod Storage Drawers - A Mod adding storage drawers

Original Mod:
Copyright (C) 2017-2019 Linus Jahn <lnj@kaidan.im>
Copyright (C) 2016 Mango Tango <mtango688@gmail.com>

Modifications for Skyblock: Zero:
Copyright (C) 2026 Skyblock: Zero Contributors

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

local S = core.get_translator('drawers')

-- Used for Drawer Controller's GUI
function drawers.inventory_list(posy)
	local hotbar_row_posy = posy + 1.25
	local inventory_list = "list[current_player;main;0.5," .. posy .. ";8,1;]" ..
		"list[current_player;main;0.5," .. hotbar_row_posy .. ";8,3;8]"
	return inventory_list
end

function drawers.gen_info_text(basename, count, factor, stack_max)
	local maxCount = stack_max * factor
	local percent = count / maxCount * 100
	-- round the number (float -> int)
	percent = math.floor(percent + 0.5)

	if count == 0 then
		return S("@1 (@2% full)", basename, tostring(percent))
	else
		return S("@1 @2 (@3% full)", tostring(count), basename, tostring(percent))
	end
end

-- Get an image string from a tile definition
local function tile_to_image(tile, fallback_image)
	if not tile then
		return fallback_image
	end
	local tile_type = type(tile)
	if tile_type == "string" then
		return tile
	end
	assert(tile_type == "table", "Tile definition is not a string or table")
	local image = tile.name or tile.image
	assert(image, "Tile definition has no image file specified")
	if tile.color then
		local colorstr = core.colorspec_to_colorstring(tile.color)
		if colorstr then
			return image .. "^[multiply:" .. colorstr
		end
	end
	return image
end

function drawers.get_inv_image(name)
	local texture = "blank.png"
	local def = core.registered_items[name]
	if not def then return end

	if def.inventory_image and #def.inventory_image > 0 then
		texture = def.inventory_image
	else
		if not def.tiles then return texture end
		local tiles = table.copy(def.tiles)
		local top = tile_to_image(tiles[1])
		local left = tile_to_image(tiles[3], top)
		local right = tile_to_image(tiles[5], left)
		texture = core.inventorycube(top, left, right)
	end

	return texture
end

function drawers.update_drawer_upgrades(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	local drawerType = ndef.groups.drawer

	-- default number of slots/stacks
	local stackMaxFactor = ndef.drawer_stack_max_factor

	-- storage percent with all upgrades
	local storagePercent = 100

	-- get info of all upgrades
	local inventory = core.get_meta(pos):get_inventory():get_list("upgrades")
	for _, itemStack in pairs(inventory) do
		local iname = itemStack:get_name()
		local idef = core.registered_items[iname]
		local addPercent = idef.groups.drawer_upgrade or 0

		storagePercent = storagePercent + addPercent
	end

	--						i.e.: 150% / 100 => 1.50
	stackMaxFactor = math.floor(stackMaxFactor * (storagePercent / 100))
	-- calculate stack_max factor for a single drawer
	stackMaxFactor = stackMaxFactor / drawerType

	-- set the new stack max factor in all visuals
	local drawer_visuals = drawers.drawer_visuals[core.hash_node_position(pos)]
	if not drawer_visuals then return end

	for _, visual in pairs(drawer_visuals) do
		visual:setStackMaxFactor(stackMaxFactor)
	end
end

function drawers.randomize_pos(pos)
	local rndpos = table.copy(pos)
	local x = math.random(-50, 50) * 0.01
	local z = math.random(-50, 50) * 0.01
	rndpos.x = rndpos.x + x
	rndpos.y = rndpos.y + 0.25
	rndpos.z = rndpos.z + z
	return rndpos
end

function drawers.node_tiles_front_other(front, other)
	return { other, other, other, other, other, front }
end

--Section below modified as of 2021 by Pandorabox

core.register_chatcommand("drawers_fix", {
	description = "recreates the drawer-visuals in your area",
	func = function(name)
		local player = core.get_player_by_name(name)
		if not player then
			return
		end
		local t1 = sbz_api.clock_ms()

		local ppos = player:get_pos()
		local pos1 = vector.subtract(ppos, 10)
		local pos2 = vector.add(ppos, 10)

		local poslist = core.find_nodes_in_area(pos1, pos2, { "group:drawer" })

		for _, pos in ipairs(poslist) do
			drawers.remove_visuals(pos)
			drawers.spawn_visuals(pos)
		end

		local t2 = sbz_api.clock_ms()
		local diff = t2 - t1
		local millis = diff

		return true, "Restored " .. #poslist .. " drawers in " .. millis .. " ms"
	end
})
