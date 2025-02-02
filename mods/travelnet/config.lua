-- set this to 0 if you want no limit
travelnet.MAX_STATIONS_PER_NETWORK = tonumber(minetest.settings:get("travelnet.MAX_STATIONS_PER_NETWORK")) or 24

-- set this to true if you want a simulated beam effect
travelnet.travelnet_effect_enabled = minetest.settings:get_bool("travelnet.travelnet_effect_enabled", false)
-- set this to true if you want a sound to be played when the travelnet is used
travelnet.travelnet_sound_enabled  = true --minetest.settings:get_bool("travelnet.travelnet_sound_enabled", true) -- the sound makes frog happy, the sound must be kept

-- if you set this to false, travelnets cannot be created
-- (this may be useful if you want nothing but the elevators on your server)
travelnet.travelnet_enabled        = true --minetest.settings:get_bool("travelnet.travelnet_enabled", true)

travelnet.travelnet_cleanup_lbm    = minetest.settings:get_bool("travelnet.travelnet_cleanup_lbm", false)

-- if you set travelnet.elevator_enabled to false, you will not be able to
-- craft, place or use elevators
travelnet.elevator_enabled         = false --minetest.settings:get_bool("travelnet.elevator_enabled", true)
-- if you set this to false, doors will be disabled
travelnet.doors_enabled            = false --minetest.settings:get_bool("travelnet.doors_enabled", true)

-- starts an abm which re-adds travelnet stations to networks in case the savefile got lost
travelnet.abm_enabled              = minetest.settings:get_bool("travelnet.abm_enabled", false)

-- change these if you want other receipes for travelnet or elevator
travelnet.travelnet_recipe         = {
	{ "sbz_resources:phlogiston_circuit", "sbz_resources:phlogiston_circuit", "sbz_resources:phlogiston_circuit" },
	{ "sbz_resources:warp_crystal",       "sbz_resources:warp_crystal",       "sbz_resources:warp_crystal", },
	{ "sbz_resources:phlogiston",         "sbz_resources:phlogiston",         "sbz_resources:phlogiston" }
}

--[[
travelnet.elevator_recipe          = {
	{ xcompat.materials.steel_ingot, xcompat.materials.glass, xcompat.materials.steel_ingot },
	{ xcompat.materials.steel_ingot, "",                      xcompat.materials.steel_ingot },
	{ xcompat.materials.steel_ingot, xcompat.materials.glass, xcompat.materials.steel_ingot }
}
]]

travelnet.tiles_elevator           = {
	"travelnet_elevator_front.png",
	"travelnet_elevator_inside_controls.png",
	"travelnet_elevator_sides_outside.png",
	"travelnet_elevator_inside_ceiling.png",
	"travelnet_elevator_inside_floor.png",
	"travelnet_top.png"
}
travelnet.elevator_inventory_image = "travelnet_elevator_inv.png"

travelnet.node_box                 = {
	type = "fixed",
	fixed = {
		{ -0.5,   -0.5,   0.4375, 0.5,     1.5,     0.5 }, -- Back
		{ -0.5,   -0.5,   -0.5,   -0.4375, 1.5,     0.5 }, -- Right
		{ 0.4375, -0.5,   -0.5,   0.5,     1.5,     0.5 }, -- Left
		{ -0.5,   -0.5,   -0.5,   0.5,     -0.4375, 0.5 }, -- Floor
		{ -0.5,   1.4375, -0.5,   0.5,     1.5,     0.5 }, -- Roof
	}
}

-- if this function returns true, the player with the name player_name is
-- allowed to add a box to the network named network_name, which is owned
-- by the player owner_name;
-- if you want to allow *everybody* to attach stations to all nets, let the
-- function always return true;
-- if the function returns false, players with the travelnet_attach priv
-- can still add stations to that network
-- params: player_name, owner_name, network_name
travelnet.allow_attach             = function()
	return minetest.settings:get_bool("travelnet.allow_attach", false)
end


-- if this returns true, a player named player_name can remove a travelnet station
-- from network_name (owned by owner_name) even though he is neither the owner nor
-- has the travelnet_remove priv
-- params: player_name, owner_name, network_name, pos
travelnet.allow_dig = function()
	return minetest.settings:get_bool("travelnet.allow_dig", false)
end


-- if this function returns false, then player player_name will not be allowed to use
-- the travelnet station_name_start on networ network_name owned by owner_name to travel to
-- the station station_name_target on the same network;
-- if this function returns true, the player will be transfered to the target station;
-- you can use this code to i.e. charge the player money for the transfer or to limit
-- usage of stations to players in the same fraction on PvP servers
-- params: player_name, owner_name, network_name, station_name_start, station_name_target
travelnet.allow_travel = function(player_name, owner_name)
	local setting = minetest.settings:get_bool("travelnet.allow_travel", true)
	return setting or player_name == owner_name
end

-- allows an custom attach priv
travelnet.attach_priv = minetest.settings:get("travelnet.attach_priv") or "travelnet_attach"

-- allows an custom remove priv
travelnet.remove_priv = minetest.settings:get("travelnet.remove_priv") or "travelnet_remove"
