-- Pipeworks mod by Vanessa Ezekowitz - 2013-07-13
--
-- This mod supplies various steel pipes and plastic pneumatic tubes
-- and devices that they can connect to.


pipeworks = {
	worldpath = minetest.get_worldpath(),
	modpath = minetest.get_modpath("pipeworks"),
	logger = function(msg)
		minetest.log("action", "[pipeworks] " .. msg)
	end,
	entity_update_interval = 0.1,
	use_real_entities = true,
	enable_cyclic_mode = true,
	tube_backface_culling = minetest.settings:get_bool("sbz_pipe_backface_culling") or true,
}

-- Load the various other parts of the mod

dofile(pipeworks.modpath .. "/common.lua")
dofile(pipeworks.modpath .. "/models.lua")
dofile(pipeworks.modpath .. "/autoplace_tubes.lua")
dofile(pipeworks.modpath .. "/luaentity.lua")
dofile(pipeworks.modpath .. "/item_transport.lua")
dofile(pipeworks.modpath .. "/tube_register.lua")

dofile(pipeworks.modpath .. "/filter_injector.lua")
dofile(pipeworks.modpath .. "/basic_tubes.lua")
dofile(pipeworks.modpath .. "/basic_blocks.lua")

dofile(pipeworks.modpath .. "/wielder.lua")
dofile(pipeworks.modpath .. "/autocrafter.lua")
dofile(pipeworks.modpath .. "/teleport_tube.lua")
minetest.log("info", "Pipeworks loaded!")
