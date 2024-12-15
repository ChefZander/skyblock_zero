minetest.register_node("jumpdrive:warp_device", {
	description = "Warp Device",

	tiles = { "jumpdrive_warpdevice.png" },
	groups = { cracky = 5, oddly_breakable_by_hand = 1, handy = 1, pickaxey = 1 },
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.9,
	sounds = sbz_api.sounds.glass(),
	is_ground_content = false,
	light_source = 4
})
