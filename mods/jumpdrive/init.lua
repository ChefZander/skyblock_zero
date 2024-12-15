jumpdrive = {
	config = {
		-- allowed radius
		max_radius = tonumber(minetest.settings:get("jumpdrive.max_radius")) or 16,
		max_area_radius = tonumber(minetest.settings:get("jumpdrive.max_area_radius")) or 25,


		-- base storage value
		powerstorage = 200000,
	},

	-- blacklisted nodes
	blacklist = {}
}

-- max volume in nodes ( ((radius*2) + 1) ^ 3 )
jumpdrive.config.max_area_volume = (jumpdrive.config.max_radius * 2 + 1) ^ 3

local MP = minetest.get_modpath("jumpdrive")

-- common functions
dofile(MP .. "/upgrade.lua")
dofile(MP .. "/bookmark.lua")
dofile(MP .. "/infotext.lua")
dofile(MP .. "/hooks.lua")
dofile(MP .. "/compat/compat.lua")
dofile(MP .. "/is_area_empty.lua")
dofile(MP .. "/is_area_protected.lua")

-- move logic
dofile(MP .. "/move/move_objects.lua")
dofile(MP .. "/move/move_mapdata.lua")
dofile(MP .. "/move/move_metadata.lua")
dofile(MP .. "/move/move_nodetimers.lua")
dofile(MP .. "/move/move_players.lua")
dofile(MP .. "/move/move.lua")

dofile(MP .. "/mapgen.lua")
dofile(MP .. "/common.lua")
dofile(MP .. "/logic.lua")
dofile(MP .. "/backbone.lua")
dofile(MP .. "/warp_device.lua")
dofile(MP .. "/crafts.lua")

-- engine
dofile(MP .. "/engine.lua")
dofile(MP .. "/formspec.lua")
dofile(MP .. "/jump.lua")

-- fleet
dofile(MP .. "/fleet/fleet_functions.lua")
dofile(MP .. "/fleet/fleet_logic.lua")
dofile(MP .. "/fleet/fleet_controller.lua")
dofile(MP .. "/fleet/fleet_formspec.lua")

-- blacklist nodes
dofile(MP .. "/blacklist.lua")
dofile(MP .. "/station.lua")

if minetest.get_modpath("monitoring") then
	-- enable metrics
	dofile(MP .. "/metrics.lua")
end

if minetest.get_modpath("mtt") and mtt.enabled then
	dofile(MP .. "/mtt.lua")
end

print("[OK] Jumpdrive")
