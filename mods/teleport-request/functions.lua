--[[
Functions
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

-- Placeholders
local chatmsg, source, target,
target_coords, tpc_target_coords, old_tpc_target_coords

local spam_prevention = {}
local band = false

local muted_players = {}

local message_color = tp.message_color

local function color_string_to_number(color)
	if string.sub(color,1,1) == '#' then
		color = string.sub(color, 2)
	end
	if #color < 6 then
		local r = string.sub(color,1,1)
		local g = string.sub(color,2,2)
		local b = string.sub(color,3,3)
		color = r..r .. g..g .. b..b
	elseif #color > 6 then
		color = string.sub(color, 1, 6)
	end
	return tonumber(color, 16)
end

local message_color_number = color_string_to_number(message_color)

local function send_message(player, message)
	minetest.chat_send_player(player, minetest.colorize(message_color, message))
	if minetest.get_modpath("chat2") then
		chat2.send_message(minetest.get_player_by_name(player), message, message_color_number)
	end
end

local next_request_id = 0
local request_list = {}
local sender_list = {}
local receiver_list = {}
local area_list = {}

function tp.make_request(sender, receiver, direction)
	next_request_id = next_request_id+1
	request_list[next_request_id] = {
		time = os.time(),
		direction = direction or "receiver",
		receiver = receiver,
		sender = sender
	}

	receiver_list[receiver] = receiver_list[receiver] or {count=0}
	receiver_list[receiver][next_request_id] = true
	receiver_list[receiver].count = receiver_list[receiver].count+1

	sender_list[sender] = sender_list[sender] or {count=0}
	sender_list[sender][next_request_id] = true
	sender_list[sender].count = sender_list[sender].count+1

	return next_request_id
end

function tp.clear_request(id)
	local request = request_list[id]
	request_list[id] = nil

	sender_list[request.sender][id] = nil
	receiver_list[request.receiver][id] = nil

	sender_list[request.sender].count = sender_list[request.sender].count-1
	receiver_list[request.receiver].count = receiver_list[request.receiver].count-1

	return request
end

function tp.accept_request(id)

	local request = tp.clear_request(id)

	if request.direction == "area" then
		source = minetest.get_player_by_name(request.receiver)
		target = minetest.get_player_by_name(request.sender)
		chatmsg = S("@1 is teleporting to your protected area @2.", request.sender, minetest.pos_to_string(tpc_target_coords[request.receiver]))
		-- If source or target are not present, abort request.
		if not source or not target then
			send_message(request.receiver, S("@1 is not online right now.", request.sender))
			return
		end
		if not tpc_target_coords[request.receiver] then
			tpc_target_coords[request.sender] = old_tpc_target_coords[request.receiver]
			tp.tpp_teleport_player(request.sender, tpc_target_coords[request.sender])

			chatmsg = S("@1 is teleporting to your protected area @2.", request.sender, minetest.pos_to_string(tpc_target_coords[request.sender]))
		else
			tp.tpp_teleport_player(request.sender, tpc_target_coords[request.receiver])
			chatmsg = S("@1 is teleporting to your protected area @2.", request.sender, minetest.pos_to_string(tpc_target_coords[request.receiver]))
		end

		send_message(request.receiver, chatmsg)
		send_message(request.sender, S("Request Accepted!"))

		-- Avoid abusing with area requests
		target_coords = nil
	elseif request.direction == "receiver" then
		source = minetest.get_player_by_name(request.receiver)
		target = minetest.get_player_by_name(request.sender)
		chatmsg = S("@1 is teleporting to you.", request.sender)
		-- Could happen if either player disconnects (or timeout); if so just abort
		if not source
		or not target then
			send_message(request.receiver, S("@1 is not online right now.", request.sender))
			return
		end

		tp.tpr_teleport_player()

		-- Avoid abusing with area requests
		target_coords = nil

		send_message(request.receiver, chatmsg)

		if minetest.check_player_privs(request.sender, {tp_admin = true}) == false then
			send_message(request.sender, S("Request Accepted!"))
		else
			if tp.enable_immediate_teleport then return end

			send_message(request.sender, S("Request Accepted!"))
			return
		end
	elseif request.direction == "sender" then
		source = minetest.get_player_by_name(request.sender)
		target = minetest.get_player_by_name(request.receiver)
		chatmsg = S("You are teleporting to @1.", request.sender)
		-- Could happen if either player disconnects (or timeout); if so just abort
		if not source
		or not target then
			send_message(request.receiver, S("@1 is not online right now.", request.sender))
			return
		end

		tp.tpr_teleport_player()

		-- Avoid abusing with area requests
		target_coords = nil

		send_message(request.receiver, chatmsg)

		if minetest.check_player_privs(request.sender, {tp_admin = true}) == false then
			send_message(request.sender, S("Request Accepted!"))
		else
			if tp.enable_immediate_teleport then return end

			send_message(request.sender, S("Request Accepted!"))
			return
		end
	end
	return request
end

function tp.deny_request(id, own)
	local request = tp.clear_request(id)
	if own then
		send_message(request.sender, S("You denied your request sent to @1.", request.receiver))
		send_message(request.receiver, S("@1 denied their request sent to you.", request.sender))
	else
		if request.direction == "area" then
			send_message(request.sender, S("Area request denied."))
			send_message(request.receiver, S("You denied the request @1 sent you.", request.sender))
			spam_prevention[request.receiver] = request.sender
		elseif request.direction == "receiver" then
			send_message(request.sender, S("Teleport request denied."))
			send_message(request.receiver, S("You denied the request @1 sent you.", request.sender))
			spam_prevention[request.receiver] = request.sender
		elseif request.direction == "sender" then
			send_message(request.sender, S("Teleport request denied."))
			send_message(request.receiver, S("You denied the request @1 sent you.", request.sender))
			spam_prevention[request.receiver] = request.sender
		end
	end
end

function tp.list_requests(playername)
	local sent_requests = tp.get_requests(playername, "sender")
	local received_requests = tp.get_requests(playername, "receiver")
	local area_requests = tp.get_requests(playername, "area")

	local formspec
	if sent_requests.count == 0 and received_requests.count == 0 and area_requests.count == 0 then
		formspec = ("size[5,2]label[1,0.3;%s:]"):format(S("Teleport Requests"))
		formspec = formspec..("label[1,1.2;%s]"):format(S("You have no requests."))
	else
		local y = 1
		local request_list_formspec = ""
		if sent_requests.count ~= 0 then
			request_list_formspec = request_list_formspec..("label[0.2,%f;%s:]"):format(y, S("Sent by you"))
			y = y+0.7
			for request_id, _ in pairs(sent_requests) do
				if request_id ~= "count" then
					local request = request_list[request_id]
					if request.direction == "receiver" then
						request_list_formspec = request_list_formspec..("label[0.3,%f;%s]button[7,%f;1,1;deny_%s;Cancel]")
							:format(
								y, tostring(os.time()-request.time).."s ago: "..S("You are requesting to teleport to @1.", request.receiver),
								y, tostring(request_id)
							)
					elseif request.direction == "sender" then
						request_list_formspec = request_list_formspec..("label[0.3,%f;%s]button[7,%f;1,1;deny_%s;Cancel]")
							:format(
								y, tostring(os.time()-request.time).."s: "..S("You are requesting that @1 teleports to you.", request.receiver),
								y, tostring(request_id)
							)
					elseif request.direction == "area" then
						request_list_formspec = request_list_formspec..("label[0.3,%f;%s]button[7,%f;1,1;deny_%s;Cancel]")
							:format(
								y, tostring(os.time()-request.time).."s: "..S("You are requesting to teleport to @1's protected area.", request.receiver),
								y, tostring(request_id)
							)
					end
					y = y+0.8
				end
			end
		end
		if received_requests.count ~= 0 then
			y = y+0.5
			request_list_formspec = request_list_formspec..("label[0.2,%f;%s:]"):format(y, S("Sent to you"))
			y = y+0.7
			for request_id, _ in pairs(received_requests) do
				if request_id ~= "count" then
					local request = request_list[request_id]
					if request.direction == "receiver" then
						request_list_formspec = request_list_formspec..("label[0.3,%f;%s]button[6,%f;1,1;accept_%s;Accept]button[7,%f;1,1;deny_%s;Deny]")
							:format(
								y, tostring(os.time()-request.time).."s ago: "..S("@1 is requesting to teleport to you.", request.sender),
								y, tostring(request_id),
								y, tostring(request_id)
							)
					elseif request.direction == "sender" then
						request_list_formspec = request_list_formspec..("label[0.3,%f;%s]button[6,%f;1,1;accept_%s;Accept]button[7,%f;1,1;deny_%s;Deny]")
							:format(
								y, tostring(os.time()-request.time).."s ago: "..S("@1 is requesting that you teleport to them.", request.sender),
								y, tostring(request_id),
								y, tostring(request_id)
							)
					elseif request.direction == "area" then
						request_list_formspec = request_list_formspec..("label[0.3,%f;%s]button[6,%f;1,1;accept_%s;Accept]button[7,%f;1,1;deny_%s;Deny]")
							:format(
								y, tostring(os.time()-request.time).."s ago: "..S("@1 is requesting to teleport to your protected area.", request.sender),
								y, tostring(request_id),
								y, tostring(request_id)
							)
					end
					y = y+0.8
				end
			end
		end
		formspec = ("size[8,%f]label[1,0.3;%s:]"):format(math.min(y,10),S("Teleport Requests"))
			..request_list_formspec
	end

	minetest.show_formspec(playername, "teleport_request_list", formspec)

	local function update_time()
		if formspec == "" or string.find(formspec, S("You have no requests.")) then
			tp.tpf_update_time[playername] = false
			return
		end

		if tp.tpf_update_time[playername] then
			-- TODO: find a way to edit the text only and update
			-- the formspec without re-calling the function.
			tp.list_requests(playername)
		end
	end

	minetest.after(1, update_time)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "teleport_request_list" then return end

	local playername = player:get_player_name()

	local accepts = {}
	local denys = {}
	for button_name, _ in pairs(fields) do
		if string.sub(button_name, 1, 5) == "deny_" then
			table.insert(denys, tonumber(string.sub(button_name, 6)))
		elseif string.sub(button_name, 1, 7) == "accept_" then
			table.insert(accepts, tonumber(string.sub(button_name, 8)))
		end
	end
	local changes = false
	for _, id in ipairs(accepts) do
		if request_list[id] and request_list[id].receiver == playername then
			tp.accept_request(id)
			changes = true
		end
	end
	for _, id in ipairs(denys) do
		if request_list[id] and (request_list[id].sender == playername or request_list[id].receiver == playername) then
			tp.deny_request(id, request_list[id].sender == playername)
			changes = true
		end
	end

	if changes and not fields.quit then
		tp.tpf_update_time[playername] = true
		tp.list_requests(playername)
	elseif fields.quit then
		tp.tpf_update_time[playername] = false
	end
end)

function tp.get_requests(playername, party)
	local list
	if party == "sender" then
		list = sender_list
	elseif party == "receiver" then
		list = receiver_list
	elseif party == "area" then
		list = area_list
	else
		return -- Invalid party
	end
	if not list then return end

	return list[playername] or {count=0}
end

function tp.count_requests(playername, party)
	local player_list = tp.get_requests(playername, party)
	if not player_list then return 0 end

	return player_list.count or 0
end

function tp.first_request(playername, party)
	local player_list = tp.get_requests(playername, party)
	if not player_list then return end

	for request_id, _ in pairs(player_list) do
		if request_id ~= "count" then
			return request_id
		end
	end
end

local map_size = 30912
function tp.can_teleport(to)
	return to.x < map_size and to.x > -map_size and to.y < map_size and to.y > -map_size and to.z < map_size and to.z > -map_size
end

-- Teleport player to a player (used in "/tpr" and in "/tphr" command).
function tp.tpr_teleport_player()
	target_coords = source:get_pos()
	local target_sound = target:get_pos()
	target:set_pos(tp.find_free_position_near(target_coords))
	minetest.sound_play("tpr_warp", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
	minetest.sound_play("tpr_warp", {pos = target_sound, gain = 0.5, max_hear_distance = 10})
	--tp.parti2(target_coords)
end

-- TPC & TPJ
function tp.tpc_teleport_player(player)
	local pname = minetest.get_player_by_name(player)
	minetest.sound_play("tpr_warp", {pos = pname:get_pos(), gain = 0.5, max_hear_distance = 10})
	pname:set_pos(tp.find_free_position_near(target_coords))
	minetest.sound_play("tpr_warp", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
	--tp.parti2(target_coords)
end

-- TPP
function tp.tpp_teleport_player(player, pos)
	local pname = minetest.get_player_by_name(player)
	minetest.sound_play("tpr_warp", {pos = pname:get_pos(), gain = 0.5, max_hear_distance = 10})
	pname:set_pos(tp.find_free_position_near(pos))
	minetest.sound_play("tpr_warp", {pos = pos, gain = 0.5, max_hear_distance = 10})
	--tp.parti2(target_coords)
end

function tp.find_free_position_near(pos)
	local tries = {
		{x=1,y=0,z=0},
		{x=-1,y=0,z=0},
		{x=0,y=0,z=1},
		{x=0,y=0,z=-1},
	}
	for _,d in pairs(tries) do
		local p = vector.add(pos, d)
		local def = minetest.registered_nodes[minetest.get_node(p).name]
		if def and not def.walkable then
			return p, true
		end
	end
	return pos, false
end

function tp.parti(pos)
	minetest.add_particlespawner(50, 0.4,
		{x=pos.x + 0.5, y=pos.y, z=pos.z + 0.5}, {x=pos.x - 0.5, y=pos.y, z=pos.z - 0.5},
		{x=0, y=5, z=0}, {x=0, y=0, z=0},
		{x=0, y=5, z=0}, {x=0, y=0, z=0},
		3, 5,
		3, 5,
		false,
		"tps_portal_parti.png")
end

function tp.parti2(pos)
	minetest.add_particlespawner(50, 0.4,
		{x=pos.x + 0.5, y=pos.y + 10, z=pos.z + 0.5}, {x=pos.x - 0.5, y=pos.y, z=pos.z - 0.5},
		{x=0, y=-5, z=0}, {x=0, y=0, z=0},
		{x=0, y=-5, z=0}, {x=0, y=0, z=0},
		3, 5,
		3, 5,
		false,
		"tps_portal_parti.png")
end

-- Mutes a player from sending you teleport requests
function tp.tpr_mute(player, muted_player)
	if muted_player == "" then
		send_message(player, S("Usage: /tpr_mute <player>"))
		return
	end

	if not minetest.get_player_by_name(muted_player) then
		send_message(player, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
		return
	end

	if minetest.check_player_privs(muted_player, {tp_admin = true}) and not minetest.check_player_privs(player, {server = true}) then
		send_message(player, S("tpr_mute: Failed to mute player @1: they have the tp_admin privilege.", muted_player))
		return
	end

	if muted_players[player] == muted_player then
		send_message(player, S("tpr_mute: Player @1 is already muted.", muted_player))
		return
	end

	muted_players[player] = muted_player
	send_message(player, S("tpr_mute: Player @1 successfully muted.", muted_player))
end

-- Unmutes a player from sending you teleport requests
function tp.tpr_unmute(player, muted_player)
	if muted_player == "" then
		send_message(player, S("Usage: /tpr_unmute <player>"))
		return
	end

	if not minetest.get_player_by_name(muted_player) then
		send_message(player, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
		return
	end

	if muted_players[player] ~= muted_player then
		send_message(player, S("tpr_mute: Player @1 is not muted yet.", muted_player))
		return
	end

	muted_players[player] = nil
	send_message(player, S("tpr_mute: Player @1 successfully unmuted.", muted_player))
end

-- Teleport Request System
function tp.tpr_send(sender, receiver)
	-- Check if the sender is muted
	if muted_players[receiver] == sender and not minetest.check_player_privs(sender, {server = true}) then
		send_message(sender, S("Cannot send request to @1 (you have been muted).", receiver))
		return
	end

	if receiver == "" then
		send_message(sender, S("Usage: /tpr <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
		return
	end

	-- Spam prevention
	if spam_prevention[receiver] == sender and not minetest.check_player_privs(sender, {tp_admin = true}) then
		send_message(sender, S("Wait @1 seconds before you can send teleport requests to @2 again.", tp.timeout_delay, receiver))

		minetest.after(tp.timeout_delay, function(sender_name, receiver_name)
			spam_prevention[receiver_name] = nil
			if band == true then return end

			if spam_prevention[receiver_name] == nil then
				send_message(sender_name, S("You can now send teleport requests to @1.", receiver_name))
				band = true
			end
		end, sender, receiver)
	else
	-- Compatibility with beerchat
		if minetest.get_modpath("beerchat") and not minetest.check_player_privs(sender, {tp_admin = true}) then
			if receiver == "" then
				send_message(sender, S("Usage: /tpr <Player name>"))
				return
			end

			if not minetest.get_player_by_name(receiver) then
				send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
				return
			end

			local player_receiver = minetest.get_player_by_name(receiver)
			if player_receiver:get_meta():get_string("beerchat:muted:" .. sender) == "true" then
				send_message(sender, S("You are not allowed to send requests because you're muted."))
				return
			end
		end

		if minetest.check_player_privs(sender, {tp_admin = true}) and tp.enable_immediate_teleport then
			if receiver == "" then
				send_message(sender, S("Usage: /tpr <Player name>"))
				return
			end

			if not minetest.get_player_by_name(receiver) then
				send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
				return
			end

			local id = tp.make_request(sender, receiver, "receiver")
			tp.accept_request(id)
			return
		end

		if receiver == "" then
			send_message(sender, S("Usage: /tpr <Player name>"))
			return
		end

		if not minetest.get_player_by_name(receiver) then
			send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
			return
		end

		if minetest.get_modpath("gamehub") then -- Compatibility with gamehub (UNTESTED)
			if gamehub.players[receiver] then
				send_message(sender, S("Teleport request denied, player is in the gamehub!"))
				return
			end
		end

		send_message(receiver, S("@1 is requesting to teleport to you. /tpy to accept.", sender))
		send_message(sender, S("Teleport request sent! It will timeout in @1 seconds.", tp.timeout_delay))

		local tp_id = tp.make_request(sender, receiver, "receiver")

		-- Teleport timeout delay
		minetest.after(tp.timeout_delay, function(id)
			if request_list[id] then
				local request = tp.clear_request(id)

				send_message(request.sender, S("Request timed-out."))
				send_message(request.receiver, S("Request timed-out."))
				return
			end
		end, tp_id)
	end
end

function tp.tphr_send(sender, receiver)
	-- Check if the sender is muted
	if muted_players[receiver] == sender and not minetest.check_player_privs(sender, {server = true}) then
		send_message(sender, S("Cannot send request to @1 (you have been muted).", receiver))
		return
	end

	if receiver == "" then
		send_message(sender, S("Usage: /tphr <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
		return
	end

	-- Spam prevention
	if spam_prevention[receiver] == sender and not minetest.check_player_privs(sender, {tp_admin = true}) then
		send_message(sender, S("Wait @1 seconds before you can send teleport requests to @2 again.", tp.timeout_delay, receiver))

		minetest.after(tp.timeout_delay, function(sender_name, receiver_name)
			spam_prevention[receiver_name] = nil
			if band == true then return end

			if spam_prevention[receiver_name] == nil then
				send_message(sender_name, S("You can now send teleport requests to @1.", receiver_name))
				band = true
			end
		end, sender, receiver)
	else
	-- Compatibility with beerchat
		if minetest.get_modpath("beerchat") and not minetest.check_player_privs(sender, {tp_admin = true}) then
			if receiver == "" then
				send_message(sender, S("Usage: /tphr <Player name>"))
				return
			end

			if not minetest.get_player_by_name(receiver) then
				send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
				return
			end

			local player_receiver = minetest.get_player_by_name(receiver)
			if player_receiver:get_meta():get_string("beerchat:muted:" .. sender) == "true" then
				send_message(sender, S("You are not allowed to send requests because you're muted."))
				return
			end
		end

		if minetest.check_player_privs(sender, {tp_admin = true}) and tp.enable_immediate_teleport then
			if receiver == "" then
				send_message(sender, S("Usage: /tphr <Player name>"))
				return
			end

			if not minetest.get_player_by_name(receiver) then
				send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
				return
			end

			tp.tphr_list[receiver] = sender
			tp.tpr_accept(receiver)
			send_message(sender, S("@1 is teleporting to you.", receiver))
			return
		end

		if receiver == "" then
			send_message(sender, S("Usage: /tphr <Player name>"))
			return
		end

		if not minetest.get_player_by_name(receiver) then
			send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
			return
		end

		if minetest.get_modpath("gamehub") then -- Compatibility with gamehub (UNTESTED)
			if gamehub.players[receiver] then
				send_message(sender, S("Teleport request denied, player is in the gamehub!"))
				return
			end
		end

		send_message(receiver, S("@1 is requesting that you teleport to them. /tpy to accept; /tpn to deny.", sender))
		send_message(sender, S("Teleport request sent! It will timeout in @1 seconds.", tp.timeout_delay))

		local tp_id = tp.make_request(sender, receiver, "sender")

		-- Teleport timeout delay
		minetest.after(tp.timeout_delay, function(id)
			if request_list[id] then
				local request = tp.clear_request(id)

				send_message(request.sender, S("Request timed-out."))
				send_message(request.receiver, S("Request timed-out."))
				return
			end
		end, tp_id)
	end
end

function tp.tpc_send(sender, coordinates)
	local posx,posy,posz = string.match(coordinates, "^(-?%d+), (-?%d+), (-?%d+)$")
	local pname = minetest.get_player_by_name(sender)

	if posx ~= nil or posy ~= nil or posz ~= nil then
		posx = tonumber(posx) + 0.0
		posy = tonumber(posy) + 0.0
		posz = tonumber(posz) + 0.0
	end

	if posx==nil or posy==nil or posz==nil or string.len(posx) > 6 or string.len(posy) > 6 or string.len(posz) > 6 then
		send_message(sender, S("Usage: /tpc <x, y, z>"))
		return nil
	end

	target_coords = {x=posx, y=posy, z=posz}

	if tp.can_teleport(target_coords) == false then
		send_message(sender, S("You cannot teleport to a location outside the map!"))
		return nil
	end

	-- If the area is protected, reject the user's request to teleport to these coordinates
	-- Admin user (priv "tp_admin") overrides all protection
	if minetest.check_player_privs(pname, {tp_admin = true}) then
		tp.tpc_teleport_player(sender)
		target_coords = nil
		send_message(sender, S("Teleporting to: @1, @2, @3", posx, posy, posz))
	else
		if minetest.check_player_privs(pname, {tp_tpc = true}) then
			local protected = minetest.is_protected(target_coords, sender)
			if protected then
				if minetest.get_modpath("areas") then
					for _, area in pairs(areas:getAreasAtPos(target_coords)) do
						if minetest.get_player_by_name(area.owner) then -- Check if area owners are online

							if tpc_target_coords then
								old_tpc_target_coords = tpc_target_coords
								old_tpc_target_coords[area.owner] = tpc_target_coords[area.owner]

								tpc_target_coords[area.owner] = {x=posx, y=posy, z=posz}
							else
								tpc_target_coords = {x=posx, y=posy, z=posz}
								tpc_target_coords[area.owner] = {x=posx, y=posy, z=posz}
							end

							send_message(sender, S("Area request sent! Waiting for @1 to accept your request." ..
							" It will timeout in @2 seconds.", table.concat(areas:getNodeOwners(tpc_target_coords[area.owner]), S(", or ")), tp.timeout_delay))
							send_message(area.owner, S("@1 is requesting to teleport to a protected area" ..
							" of yours @2.", sender, minetest.pos_to_string(tpc_target_coords[area.owner])))

							local tp_id = tp.make_request(sender, area.owner, "area")

							minetest.after(tp.timeout_delay, function(id)
								if request_list[id] then
									local request = tp.clear_request(id)

									send_message(request.sender, S("Request timed-out."))
									send_message(request.receiver, S("Request timed-out."))
									return
								end
							end, tp_id)
						else
							minetest.record_protection_violation(target_coords, sender)
						end
					end
				else
					minetest.record_protection_violation(target_coords, sender)
				end
				return
			end

			tp.tpc_teleport_player(sender)
			target_coords = nil
			send_message(sender, S("Teleporting to: @1, @2, @3", posx, posy, posz))
		else
			send_message(sender, S("Error: You do not have permission to teleport to those coordinates."))
			return
		end
	end
end

function tp.tpr_deny(name)
	if tp.count_requests(name, "sender") == 0 and tp.count_requests(name, "receiver") == 0 then
		send_message(name, S("Usage: /tpn allows you to deny teleport/area requests sent to you by other players."))
		return
	end

	if (tp.count_requests(name, "sender") + tp.count_requests(name, "receiver")) > 1 then
		-- Show formspec for decision
		tp.list_requests(name)
		tp.tpf_update_time[name] = true
		return
	end

	local received_request = tp.first_request(name, "receiver")
	if received_request then
		tp.deny_request(received_request, false)
		return
	end

	local sent_request = tp.first_request(name, "sender")
	if sent_request then
		tp.deny_request(sent_request, true)
		return
	end
end

-- Teleport Accept Systems
function tp.tpr_accept(name)
	-- Check to prevent constant teleporting
	if tp.count_requests(name, "receiver") == 0 then
		send_message(name, S("Usage: /tpy allows you to accept teleport/area requests sent to you by other players."))
		return
	end

	if tp.count_requests(name, "receiver") > 1 then
		-- Show formspec for decision
		tp.list_requests(name)
		tp.tpf_update_time[name] = true
		return
	end

	local received_request = tp.first_request(name, "receiver")

	if not received_request then return end -- This shouldn't happen, but who knows

	tp.accept_request(received_request)
end

-- Teleport Jump - Relative Position Teleportation by number of nodes
function tp.tpj(player, param)
	if param == "" then
		send_message(player, S("Usage: <x|y|z> <number>"))
		return false
	end

	local args = param:split(" ") -- look into this. Can it crash if the player does not have two parameters?
	if #args < 2 then
		send_message(player, S("Usage: <x|y|z> <number>"))
		return false
	end

	if not tonumber(args[2]) then
		send_message(player, S("Not a number!"))
		return false, S("Not a number!")
	end

	-- Initially generate the target coords from the player's current position (since it's relative) and then perform the math.
	target_coords = minetest.get_player_by_name(player):get_pos()
	if args[1] == "x" then
		target_coords["x"] = target_coords["x"] + tonumber(args[2])
	elseif args[1] == "y" then
		target_coords["y"] = target_coords["y"] + tonumber(args[2])
	elseif args[1] == "z" then
		target_coords["z"] = target_coords["z"] + tonumber(args[2])
	else
		send_message(player, S("Not a valid axis. Valid options are X, Y or Z"))
		return
	end

	if tp.can_teleport(target_coords) == false then
		send_message(player, S("You cannot teleport to a location outside the map!"))
		return
	end
	tp.tpc_teleport_player(player)

	-- Avoid abusing with area requests
	target_coords = nil
end

-- Evade
function tp.tpe(player)
	send_message(player, S("EVADE!"))
	local mindistance = 15
	local maxdistance = 50
	local times = math.random(6,20) -- how many times to jump - minimum,maximum
	local negatives = { '-','' } -- either it's this way or that way: the difference between -10 and 10
	local options = { 'x', 'y', 'z' }
	local isnegative = ''
	local distance = 0
	local axis = ''
	local iteration = 0
	for i = 1,times do
		-- do this every 1 second
		minetest.after(iteration,
			function()
				isnegative = negatives[math.random(2)] -- choose randomly whether this is this way or that
				distance = isnegative .. math.random(mindistance,maxdistance) -- the distance to jump
				axis = options[math.random(3)]
				local command = axis .. " " .. distance
				tp.tpj(player, command)
			end
		)
		iteration = iteration + 0.5
	end
end

-- Teleport To Place (TPP) system.
if tp.enable_tpp_command then
	function tp.tpp(player, param)
		-- Show the available places to the player (taken from shivajiva101's POI mod, thanks!).
		if param == "" then
			local places = {}
			if not tp.available_places then tp.available_places = {} end
			for key, value in pairs(tp.available_places) do
				send_message(player, key)
				table.insert(places, key)
			end
			if #places == 0 then
				send_message(player, S("There are no places yet."))
				return true, S("There are no places yet.")
			end
				send_message(player, S("Usage: /tpp <place>"))
				table.insert(places, S("Usage: /tpp <place>"))
				return true, table.concat(places, "\n")

		-- Teleport player to the specified place (taken from shivajiva101's POI mod, thanks!).
		elseif tp.available_places[param] then
			local pos = {x = tp.available_places[param].x, y = tp.available_places[param].y, z = tp.available_places[param].z}
			tp.tpp_teleport_player(player, pos)
			send_message(player, S("Teleporting to @1.", param))

		-- Check if the place exists.
		elseif not tp.available_places[param] then
			send_message(player, S("There is no place by that name. Keep in mind this is case-sensitive."))
			return
		end
	end

	minetest.register_chatcommand("tpp", {
		description = S("Teleport to a place (i.e., spawn, shop)."),
		params = S("<place> | leave empty to see available places"),
		privs = {},
		func = tp.tpp
	})
end
