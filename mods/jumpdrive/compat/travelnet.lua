
assert(type(travelnet.get_travelnets) == "function", "old travelnet-api found, please update the travelnet mod")

minetest.register_on_mods_loaded(function()
	for node, def in pairs(minetest.registered_nodes) do
		if def.groups and def.groups.travelnet == 1 then
			minetest.override_item(node, {
				on_movenode = function(_, to_pos)
					local meta = minetest.get_meta(to_pos);
					minetest.log("action", "[jumpdrive] Restoring travelnet @ " .. to_pos.x .. "/" .. to_pos.y .. "/" .. to_pos.z)

					local owner_name = meta:get_string( "owner" );
					local station_name = meta:get_string( "station_name" );
					local station_network = meta:get_string( "station_network" );

					local stations = travelnet.get_travelnets(owner_name)
					if (stations[station_network]
						and stations[station_network][station_name]) then
							-- update station with new position
							stations[station_network][station_name].pos = to_pos
							travelnet.set_travelnets(owner_name, stations)
					end
				end
			})
		end
	end
end)

jumpdrive.register_after_jump(function()
	if travelnet.save_data ~= nil then
		-- write data back to files
		travelnet.save_data()
	end
end)
