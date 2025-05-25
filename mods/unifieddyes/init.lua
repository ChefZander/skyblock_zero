--[[

Unified Dyes

This mod provides an extension to the Minetest dye system

==============================================================================

Copyright (C) 2012-2013, Vanessa Dannenberg
Email: vanessa.e.dannenberg@gmail.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
