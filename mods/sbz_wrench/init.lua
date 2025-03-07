local modpath = minetest.get_modpath("sbz_wrench")

wrench = {
	translator = minetest.get_translator("sbz_wrench"),
	sbz = true,
	blacklisted_items = {},
	has_pipeworks = true
}

dofile(modpath .. "/api.lua")
dofile(modpath .. "/functions.lua")
dofile(modpath .. "/tool.lua")
