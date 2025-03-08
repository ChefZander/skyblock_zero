--
-- Register teleport tube for tubetool
--

local S = metatool.S

local nodenameprefix = "pipeworks:teleport_tube_"

-- teleport tubes
local nodes = {}
for i = 1, 10 do
	table.insert(nodes, nodenameprefix .. i)
end

local ns = metatool.ns('copytool')

local tp_tube_form_index = {}

metatool.form.register_form('copytool:teleport_tube_list', {
	on_create = function(player, data)
		local list = ""
		for i, tube in ipairs(data.tubes) do
			local dist = math.floor(tube.distance or -1)
			list = list .. ",1" ..
				"," .. (dist < 0 and "???" or dist) .. "m" .. (i == 1 and " (targeted)" or "") ..
				"," .. minetest.formspec_escape(metatool.util.pos_to_string(tube.pos)) ..
				"," .. (tube.can_receive and "yes" or "no")
		end
		local form = metatool.form.Form({ width = 12, height = 10 })
		form:raw("label[0.1,0.5;" ..
			"Found " .. #data.tubes .. " teleport tubes, channel: " ..
			minetest.formspec_escape(data.channel) .. "]" ..
			"button_exit[0,9;6,1;wp;Waypoint]" ..
			"button_exit[6,9;6,1;exit;Exit]" ..
			"tablecolumns[indent;text,width=15;text,width=15;text,align=center]" ..
			"table[0,1;12,8;items;1,Distance,Location,Receive" .. list .. ";]")
		return form
	end,
	on_receive = function(player, fields, data)
		local name = player:get_player_name()
		local evt = minetest.explode_table_event(fields.items)
		if tp_tube_form_index[name] and (evt.type == "DCL" or (fields.wp and fields.quit)) then
			local tube = data.tubes[tp_tube_form_index[name]]
			if tube and tube.pos and data.channel then
				local id = player:hud_add({
					hud_elem_type = "waypoint",
					name = S("%s\n\nReceive: %s", data.channel, tube.can_receive and "yes" or "no"),
					text = "m",
					number = 0xE0B020,
					world_pos = tube.pos
				})
				minetest.after(60, function() if player then player:hud_remove(id) end end)
			else
				minetest.chat_send_player(player:get_player_name(), 'Invalid tube entry in database')
			end
		elseif evt.type == "CHG" or evt.type == "DCL" then
			tp_tube_form_index[name] = evt.row > 1 and evt.row - 1 or nil
		end
	end
})

local definition = {
	name = 'teleport_tube',
	nodes = nodes,
	group = "teleport tube",
	protection_bypass_read = "interact",
}

function definition:before_info(pos, player)
	-- No actual protection checks because this only operates on stored data
	local meta = minetest.get_meta(pos)
	local channel = meta:get_string("channel")
	if not ns.allow_teleport_tube_info(player, channel) then
		minetest.chat_send_player(
			player:get_player_name(),
			('You are not allowed to list locations on channel %s.'):format(channel)
		)
		return false
	end
	return true
end

function definition:info(node, pos, player)
	if not ns.pipeworks_tptube_api_check(player) then return end
	local meta = minetest.get_meta(pos)
	local channel = meta:get("channel")
	if not channel then
		minetest.chat_send_player(
			player:get_player_name(),
			'Invalid channel, impossible to list connected tubes.'
		)
		return
	end
	local tubes = ns.get_teleport_tubes(channel, pos)
	metatool.form.show(player, 'copytool:teleport_tube_list', { pos = pos, channel = channel, tubes = tubes })
end

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	-- get and store channel and receive setting
	local channel = meta:get_string("channel")
	local receive = meta:get_int("can_receive")
	local description
	if channel == "" then
		description = "Teleport tube configuration cleaner"
	else
		description = meta:get_string("infotext")
	end

	-- return data required for replicating this tube settings
	return {
		description = description,
		channel = channel,
		receive = receive,
	}
end

function definition:paste(node, pos, player, data)
	local name = player:get_player_name()
	local receive = data.receive
	-- check and update receive setting if placing private receiver but player is not owner
	if receive == 1 then
		local owner, mode = ns.explode_teleport_tube_channel(data.channel)
		if owner ~= name and mode == ";" then
			receive = 0
			if type(player) == "userdata" then
				minetest.chat_send_player(name, "Receive was disabled because you're not owner of private receiver.")
			end
		end
	end
	-- restore settings and update teleport tube
	if type(pipeworks.tptube) == "table" and type(pipeworks.tptube.update_tube) == "function" then
		-- using pipeworks api, update_tube will also check permissions
		pipeworks.tptube.update_tube(pos, data.channel, receive, name)
		pipeworks.tptube.update_meta(minetest.get_meta(pos))
	else
		-- through formspec handler, no api available
		local fields = {
			set_channel = 1,
			key_enter_field = "channel",
			channel = data.channel,
			["cr" .. receive] = receive,
		}
		local nodedef = minetest.registered_nodes[node.name]
		nodedef.on_receive_fields(pos, "", fields, player)
	end
end

return definition
