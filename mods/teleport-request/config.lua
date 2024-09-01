--[[
Configuration
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

-- Timeout delay and mod version.
tp.timeout_delay = tonumber(minetest.settings:get("tp.timeout_delay")) or 60
tp.version = "1.5"

-- Message color
tp.message_color = minetest.settings:get("tp.message_color") or "#FFFFFF"

-- Enable teleporting immediately to the specified player for those with "tp_admin" privilege.
tp.enable_immediate_teleport = minetest.settings:get_bool("tp.enable_immediate_teleport")

-- Set the values of the positions of your places, players will be able to teleport to them (no matter if it is protected, or not).
-- You must activate "enable_tpp_command" in order to make this to work.
tp.available_places = {
	spawn = {x = 0, y = 0, z = 0}, -- Set coordinates of spawn here.
	shop = {x = 0, y = 0, z = 0}, -- Set coordinates of the shop here.
}

-- Enable tpp command
tp.enable_tpp_command = minetest.settings:get_bool("tp.enable_tpp_command")

-- Spam prevention
tp.spam_prevention = minetest.settings:get_bool("tp.enable_spam_prevention")
