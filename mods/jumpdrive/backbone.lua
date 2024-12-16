minetest.register_node("jumpdrive:backbone", {
	description = "Jumpdrive Backbone",

	tiles = { "jumpdrive_backbone.png" },
	groups = { cracky = 3, oddly_breakable_by_hand = 3, handy = 1, pickaxey = 1, matter = 1, level = 2 },
	sounds = sbz_api.sounds.glass(),
	is_ground_content = false,
	light_source = 13
})
