--[[
	Replacement tool for creative building (Mod for MineTest)
	Copyright (C) 2013 Sokomine
	Copyright (C) 2019 coil0
	Copyright (C) 2019 HybridDog
	Copyright (C) 2019-2024 SwissalpS

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

replacer = {}
replacer.version = 0 -- changed version

replacer.has_bakedclay = false
replacer.has_basic_dyes = false
replacer.has_circular_saw = false
replacer.has_colormachine_mod = false
replacer.has_technic_mod = false
replacer.has_unifieddyes_mod = false
replacer.has_unified_inventory_mod = true
replacer.has_xcompat_mod = false

replacer.sounds = {
	fail = { name = '' },
	success = { name = '' },
}

-- image mapping tables for replacer:inspect
replacer.group_placeholder = {}
replacer.image_replacements = {}


local path = minetest.get_modpath('replacer') .. '/'

-- strings for translation (inspect & replacer)
dofile(path .. 'blabla.lua')
-- utilities (inspect & replacer)
dofile(path .. 'utils.lua')
-- more settings and functions
dofile(path .. 'replacer/constrain.lua')
-- register set enable functions
dofile(path .. 'replacer/enable.lua')

-- loop through compat dir
local path_compat = path .. 'compat/'
for _, file in ipairs(minetest.get_dir_list(path_compat, false)) do
	if file:find('^[^._].+[.]lua$') then
		dofile(path_compat .. file)
	end
end

replacer.datastructures = dofile(path .. 'replacer/datastructures.lua')
dofile(path .. 'replacer/formspecs.lua')
dofile(path .. 'replacer/history.lua')
dofile(path .. 'replacer/patterns.lua')
dofile(path .. 'replacer/replacer.lua')
dofile(path .. 'crafts.lua')
dofile(path .. 'chat_commands.lua')
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
print('[replacer] loaded')
