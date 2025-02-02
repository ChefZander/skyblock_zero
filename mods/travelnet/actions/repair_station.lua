local S = minetest.get_translator("travelnet")

return function (node_info, _, player)
	local owner_name      = node_info.props.owner_name
	local station_name    = node_info.props.station_name
	local station_network = node_info.props.station_network

	if not owner_name
	   or not station_name
	   or travelnet.is_falsey_string(station_network)
	then
		if node_info.props.is_elevator then
			return travelnet.actions.add_station(node_info, _, player)
		end
		return false, S("Update failed! Resetting this box on the travelnet.")
	end

	local travelnets = travelnet.get_travelnets(owner_name)
	local network = travelnets[station_network]
	if not network then
		network = {}
		travelnets[station_network] = network
	end

	-- if the station got lost from the network for some reason (savefile corrupted?) then add it again
	if not network[station_name] then
		local timestamp = node_info.meta:get_int("timestamp")
		if not timestamp or type(timestamp) ~= "number" or timestamp < 100000 then
			timestamp = os.time()
		end

		-- add this station
		network[station_name] = {
			pos = node_info.pos,
			timestamp = timestamp
		}

		minetest.chat_send_player(owner_name,
				S("Station '@1'" .. " " ..
					"has been reattached to the network '@2'.", station_name, station_network))

		travelnet.log("action", "repared station '" .. owner_name .. "' on network '" .. station_network ..
			"' for player '" .. owner_name .. "'")
		travelnet.set_travelnets(owner_name, travelnets)
	end
	return true, { formspec = travelnet.formspecs.primary }
end
