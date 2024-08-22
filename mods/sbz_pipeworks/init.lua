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
	entity_update_interval = 0,
	use_real_entities = true,
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

minetest.log("info", "Pipeworks loaded!")