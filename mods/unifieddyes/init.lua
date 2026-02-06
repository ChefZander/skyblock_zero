--[[

Unified Dyes

This mod provides an extension to the Minetest dye system

==============================================================================
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

==============================================================================

--]]

--=====================================================================

unifieddyes = {}

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath .. "/color-tables.lua")
dofile(modpath .. "/api.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/airbrush.lua")

print("[UnifiedDyes] Loaded!")
unifieddyes.init = true
