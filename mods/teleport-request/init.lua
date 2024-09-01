--[[
Allows players to request from another player to be teleported to them.
Includes many more teleporting features. Built for Minetest.

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

----------------------------------------------------------------------------

Originally made by Traxie21 and released under the WTFPL license.
Forum link: https://forum.minetest.net/viewtopic.php?t=4457
--]]

local MP = minetest.get_modpath(minetest.get_current_modname())
local S = minetest.get_translator(minetest.get_current_modname())

tp = {
	S = S,
	tpr_list = { },
	tphr_list = { },
	tpc_list = { },
	tpn_list = { },
	tpf_update_time = { }
}

-- Clear requests when the player leaves
minetest.register_on_leaveplayer(function(name)
	if tp.tpr_list[name] then
		tp.tpr_list[name] = nil
		return
	end

	if tp.tphr_list[name] then
		tp.tphr_list[name] = nil
		return
	end

	-- Area requests
	if tp.tpc_list[name] then
		tp.tpc_list[name] = nil
		return
	end

	if tp.tpn_list[name] then
		tp.tpn_list[name] = nil
		return
	end
end)

dofile(MP .. "/privileges.lua")
dofile(MP .. "/config.lua")
dofile(MP .. "/functions.lua")
dofile(MP .. "/commands.lua")

-- Log
if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "[MOD] Teleport Request v" .. tp.version .. " loaded!")
end
