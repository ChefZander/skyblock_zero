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
local fs_version = 'formspec_version[7]'

-- Used for Drawer Controller's GUI
function drawers.inventory_list(posy)
	local hotbar_row_posy = posy + 1.25
	local list_fs = "list[current_player;main;0.5," .. posy .. ";8,1;]" ..
		"list[current_player;main;0.5," .. hotbar_row_posy .. ";8,3;8]"
	return fs_version .. list_fs
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

-- Drawtypes where even inventorycube() is meaningless — use a single flat tile.
local flat_sprite_drawtypes = {
	torchlike        = true,
	signlike         = true,
	plantlike        = true,
	plantlike_rooted = true,
	firelike         = true,
	raillike         = true,
}

-- Drawtypes that are cubic but use the same texture on all faces
local all_same_face_drawtypes = {
	allfaces                  = true,
	allfaces_optional         = true,
	glasslike                 = true,
	liquid                    = true,
	flowingliquid             = true,
}

function drawers.get_inv_image(name)
	local texture = "blank.png"
	local def = core.registered_items[name]
	if not def then return texture end

	-- Best case: an explicit 2D inventory image is defined
	if def.inventory_image and #def.inventory_image > 0 then
		return def.inventory_image
	end

	-- Second best: an explicit 2D wield image
	if def.wield_image and #def.wield_image > 0 then
		return def.wield_image
	end

	if not def.tiles then return texture end

	-- Drawtypes with no meaningful cube faces: single flat tile
	if def.drawtype and flat_sprite_drawtypes[def.drawtype] then
		return tile_to_image(def.tiles[1]) or texture
	end

	-- Drawtypes that are cubic but use the same texture on all faces
	if def.drawtype and all_same_face_drawtypes[def.drawtype] then
		local face = tile_to_image(def.tiles[1]) or texture
		return core.inventorycube(face, face, face)
	end

	-- Connected texture nodes: composite the overlay (tiles[2]) over the base
	-- (tiles[1]) so the full appearance is shown, not just the bare base texture.
	if def.drawtype == "connected" then
		local base    = tile_to_image(def.tiles[1], texture)
		local overlay = def.tiles[2] and tile_to_image(def.tiles[2]) or nil
		local face    = overlay and (base .. "^" .. overlay) or base
		return core.inventorycube(face, face, face)
	end

	-- glasslike_framed: tiles[2] is the inner fill, tiles[1] is the frame overlay.
	-- Composite fill first, then frame on top.
	if def.drawtype == "glasslike_framed" or def.drawtype == "glasslike_framed_optional" then
		local fill  = def.tiles[2] and tile_to_image(def.tiles[2]) or nil
		local frame = tile_to_image(def.tiles[1], texture)
		local face  = fill and (fill .. "^" .. frame) or frame
		return core.inventorycube(face, face, face)
	end
--[[ 
	-- To make special cases (crusher fixed already by "tiles[2] or top" though below)
	if string.find(def.tiles[1], 'crusher') then
		local tiles = table.copy(def.tiles)
		local top   = tile_to_image(tiles[1])
		local right = tile_to_image(tiles[2], top) -- fallback: top
		local left  = tile_to_image(tiles[2], right) -- fallback: right
		return core.inventorycube(top, left, right)
	end
 ]]
	-- Full cubes and nodeboxes: isometric cube preview from top/left/right tiles
	local tiles = table.copy(def.tiles)
	local top   = tile_to_image(tiles[1])
	local right = tile_to_image(tiles[3], tiles[2] or top)
	local left  = tile_to_image(tiles[6], right) -- fallback: right
	return core.inventorycube(top, left, right)
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

	-- i.e.: 150% / 100 => 1.50
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
