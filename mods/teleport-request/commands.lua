--[[
Commands
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

minetest.register_chatcommand("tpr", {
	description = S("Request teleport to another player"),
	params = S("<playername> | leave playername empty to see help message"),
	privs = {interact = true, tp = true},
	func = tp.tpr_send
})

minetest.register_chatcommand("tphr", {
	description = S("Request player to teleport to you"),
	params = S("<playername> | leave playername empty to see help message"),
	privs = {interact = true, tp = true},
	func = tp.tphr_send
})

minetest.register_chatcommand("tpc", {
	description = S("Teleport to coordinates"),
	params = S("<coordinates> | leave coordinates empty to see help message"),
	privs = {interact = true, tp_tpc = true, tp = true},
	func = tp.tpc_send
})

minetest.register_chatcommand("tpj", {
	description = S("Teleport to relative position"),
	params = S("<axis> <distance> | leave empty to see help message"),
	privs = {interact = true, tp_tpc = true, tp = true},
	func = tp.tpj
})

minetest.register_chatcommand("tpe", {
	description = S("Evade Enemy"),
	privs = {interact = true, tp_tpc = true, tp = true},
	func = tp.tpe
})

minetest.register_chatcommand("tpy", {
	description = S("Accept teleport requests from another player"),
	privs = {interact = true, tp = true},
	func = tp.tpr_accept
})

minetest.register_chatcommand("tpn", {
	description = S("Deny teleport requests from another player"),
	privs = {interact = true, tp = true},
	func = tp.tpr_deny
})

minetest.register_chatcommand("tpf", {
	description = S("Show all teleport requests, made by you or to you, that are still active"),
	privs = {interact = true, tp = true},
	func = function(player)
		tp.tpf_update_time[player] = true
		tp.list_requests(player)
	end
})

minetest.register_chatcommand("tpr_mute", {
	description = S("Mutes a player: denies them from sending you teleport requests"),
	params = S("<playername> | leave playername empty to see help message"),
	privs = {interact = true, tp = true},
	func = tp.tpr_mute
})

minetest.register_chatcommand("tpr_unmute", {
	description = S("Unmutes a player: allow them to send you teleport requests again"),
	params = S("<playername> | leave playername empty to see help message"),
	privs = {interact = true, tp = true},
	func = tp.tpr_unmute
})
