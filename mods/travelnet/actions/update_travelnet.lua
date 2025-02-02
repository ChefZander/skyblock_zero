local S = minetest.get_translator("travelnet")

return function (node_info, fields, player)
	local pos = node_info.pos
	local meta = node_info.meta
	local player_name = player:get_player_name()

	if not pos or not fields or not meta or not player_name then
		return false, S("Invalid data or node.")
	end

	local owner_name      = node_info.props.owner_name
	local station_network = node_info.props.station_network
	local station_name	  = node_info.props.station_name
	local description     = node_info.props.description

	local new_owner_name, new_station_network, new_station_name

	if not description then
		return false, S("Unknown node.")
	end

	if owner_name == fields.owner_name
		and station_network == fields.station_network
		and station_name == fields.station_name
	then
		return true, { formspec = travelnet.formspecs.primary }
	end

	-- sanitize inputs
	local error_message = ''
	if travelnet.is_falsey_string(fields.station_name) then
		error_message = S('Please provide a station name.')
	end
	if travelnet.is_falsey_string(fields.station_network) then
		error_message = error_message .. ' '
			..S('Please provide a network name.')
	end
	if travelnet.is_falsey_string(fields.owner_name) then
		error_message = error_message .. ' '
			..S('Please provide an owner.')
	end
	if '' ~= error_message then
		return false, error_message
	end

	-- players with travelnet_remove priv can dig the station
	if not minetest.get_player_privs(player_name)[travelnet.remove_priv]
		-- the function travelnet.allow_dig(..) may allow additional digging
		and not travelnet.allow_dig(player_name, owner_name, station_network, pos)
		-- the owner can remove the station
		and owner_name ~= player_name
		-- stations without owner can be removed/edited by anybody
		and owner_name ~= ""
	then
		return false, S("This @1 belongs to @2. You can't edit it.",
				description,
				tostring(owner_name)
			)
	end

	local timestamp = os.time()
	if owner_name ~= fields.owner_name then
		if not minetest.get_player_privs(player_name)[travelnet.attach_priv]
			and not travelnet.allow_attach(player_name, owner_name, fields.station_network) then
			minetest.record_protection_violation(pos, player_name)
			return false, S("You don't have permission to change the owner of this travelnet")
		end

		-- new owner -> remove station from old network then add to new owner
		-- but only if there is space on the network
		-- get the new network

		local old_travelnets = travelnet.get_travelnets(owner_name)
		local new_travelnets = travelnet.get_travelnets(fields.owner_name)

		local new_network = new_travelnets[fields.station_network]
		if not new_network then
			new_network = {}
			new_travelnets[fields.station_network] = new_network
		end

		-- does a station with the new name already exist?
		if new_network[fields.station_name] then
			return false, S('Station "@1" already exists on network "@2" of player "@3".',
					fields.station_name, fields.station_network, fields.owner_name)
		end

		-- does the new network have space at all?
		if travelnet.MAX_STATIONS_PER_NETWORK ~= 0 and 1 + #new_network > travelnet.MAX_STATIONS_PER_NETWORK then
			return false,
				S('Network "@1", already contains the maximum number (@2) of '
					.. 'allowed stations per network. Please choose a '
					.. 'different network name.', fields.station_network,
						travelnet.MAX_STATIONS_PER_NETWORK)
		end

		-- get the old network
		local old_network = old_travelnets[station_network]
		if not old_network then
			print("TRAVELNET: failed to get old network when re-owning "
				.. "travelnet/elevator at pos " .. minetest.pos_to_string(pos))
			return false, S("Station does not have network.")
		end

		-- remove old station from old network
		old_network[station_name] = nil
		-- add new station to new network
		new_network[fields.station_name] = { pos = pos, timestamp = timestamp }

		-- update meta
		meta:set_string("station_name",    fields.station_name)
		meta:set_string("station_network", fields.station_network)
		meta:set_string("owner",           fields.owner_name)
		meta:set_int   ("timestamp",       timestamp)

		minetest.chat_send_player(player_name,
			S('Station "@1" has been renamed to "@2", '
				.. 'moved from network "@3" to network "@4" '
				.. 'and from owner "@5" to owner "@6".',
				station_name, fields.station_name,
				station_network, fields.station_network,
				owner_name, fields.owner_name))

		new_owner_name = fields.owner_name
		new_station_network = fields.station_network
		new_station_name = fields.station_name

		travelnet.log("action", "changed station '" .. station_name .. "' to '" .. fields.station_name ..
			"' moved network from '" .. station_network .. "' to '" .. fields.station_network .. "'" ..
			"' from player '" .. owner_name .. "' to '" .. fields.owner_name .. "'")

		travelnet.set_travelnets(owner_name, old_travelnets)
		travelnet.set_travelnets(fields.owner_name, new_travelnets)

	elseif station_network ~= fields.station_network then
		-- same owner but different network -> remove station from old network
		-- but only if there is space on the new network and no other station with that name
		-- get the new network
		local travelnets = travelnet.get_travelnets(owner_name)
		local network = travelnets[fields.station_network]
		if not network then
			network = {}
			travelnets[fields.station_network] = network
		end

		-- does a station with the new name already exist?
		if network[fields.station_name] then
			return false, S('Station "@1" already exists on network "@2".',
					fields.station_name, fields.station_network)
		end

		-- does the new network have space at all?
		if travelnet.MAX_STATIONS_PER_NETWORK ~= 0 and 1 + #network > travelnet.MAX_STATIONS_PER_NETWORK then
			return false,
				S('Network "@1", already contains the maximum number (@2) of '
					.. 'allowed stations per network. Please choose a '
					.. 'different network name.', fields.station_network,
						travelnet.MAX_STATIONS_PER_NETWORK)
		end
		-- get the old network
		local old_network = travelnets[station_network]
		if not old_network then
			print("TRAVELNET: failed to get old network when re-networking "
				.. "travelnet/elevator at pos " .. minetest.pos_to_string(pos))
			return false, S("Station does not have network.")
		end
		-- remove old station from old network
		old_network[station_name] = nil
		-- add new station to new network
		network[fields.station_name] = { pos = pos, timestamp = timestamp }
		-- update meta
		meta:set_string("station_name",    fields.station_name)
		meta:set_string("station_network", fields.station_network)
		meta:set_int   ("timestamp",       timestamp)

		minetest.chat_send_player(player_name,
			S('Station "@1" has been renamed to "@2" and moved '
				.. 'from network "@3" to network "@4".',
				station_name, fields.station_name,
				station_network, fields.station_network))

		new_station_network = fields.station_network
		new_station_name = fields.station_name

		travelnet.log("action", "changed station '" .. station_name .. "' to '" .. fields.station_name ..
			"' moved network from '" .. station_network .. "' to '" .. fields.station_network .. "'" ..
			"' for player '" .. owner_name .. "'")

		travelnet.set_travelnets(owner_name, travelnets)

	else
		-- only name changed -> change name but keep timestamp to preserve order
		local travelnets = travelnet.get_travelnets(owner_name)
		local network = travelnets[station_network]
		if not network then
			network = {}
			travelnets[station_network] = network
		end

		-- does a station with the new name already exist?
		if network[fields.station_name] then
			return false, S('Station "@1" already exists on network "@2".',
					fields.station_name, station_network)
		end

		-- get the old station table
		local old_station = network[station_name]
		if not old_station then
			return false, S("Station does exist.")
		end
		-- apply the old table to the new station
		network[fields.station_name] = old_station
		-- remove old station
		network[station_name] = nil
		-- update station name in node meta
		meta:set_string("station_name", fields.station_name)

		minetest.chat_send_player(player_name,
			S('Station "@1" has been renamed to "@2" on network "@3".',
				station_name, fields.station_name, station_network))

		new_station_name = fields.station_name

		travelnet.log("action", "changed station '" .. station_name .. "' to '" .. fields.station_name ..
			"' on network '" .. station_network .. "'" ..
			"' for player '" .. owner_name .. "'")

		travelnet.set_travelnets(owner_name, travelnets)
	end

	meta:set_string("infotext",
			S("Station '@1'" .. " " ..
				"on network '@2' (owned by @3)" .. " " ..
				"ready for usage.",
				tostring(new_station_name or station_name),
				tostring(new_station_network or station_network),
				tostring(new_owner_name or owner_name)
			))

	return true, { formspec = travelnet.formspecs.primary, options = {
		station_name = new_station_name or station_name,
		station_network = new_station_network or station_network,
		owner_name = new_owner_name or owner_name
	} }
end
