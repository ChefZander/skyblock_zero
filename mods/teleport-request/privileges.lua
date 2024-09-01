--[[
Privileges
Copyright (C) 2014-2024 ChaosWormz and contributors

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
USA
--]]

local S = tp.S

minetest.register_privilege("tp", {
	description = S("Let players teleport to other players (request will be sent)"),
	give_to_singleplayer = false,
	give_to_admin = true,
})

minetest.register_privilege("tp_admin", {
	description = S("Gives full admin-access to a player."),
	give_to_singleplayer = false,
	give_to_admin = true,
})

minetest.register_privilege("tp_tpc", {
	description = S("Allow player to teleport to coordinates (if allowed by area protection)"),
	give_to_singleplayer = false,
	give_to_admin = true,
})
