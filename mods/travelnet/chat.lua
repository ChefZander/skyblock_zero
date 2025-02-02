
minetest.register_chatcommand("travelnet", {
    params = "[network?]",
    description = "Shows the travelnet formspec for the network",
    privs = {
        teleport = true
    },
    func = function(playername, network_name)
        if network_name == "" then
            network_name = travelnet.default_network
        end
        local networks = travelnet.get_travelnets(playername)
        local network = networks[network_name]
        if not network then
            return false, "Network '" .. network_name .. "' not found"
        end

        local first_station_name = next(network)
        if not first_station_name then
            return false, "No stations found on network '" .. network_name .. "'"
        end

        local first_station = network[first_station_name]
        local pos = first_station.pos
        local meta = minetest.get_meta(pos)

        travelnet.show_current_formspec(pos, meta, playername)
    end
})