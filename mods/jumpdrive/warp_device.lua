core.register_node("jumpdrive:warp_device", {
	description = "Warp Device",

	tiles = { "jumpdrive_warpdevice.png" },
	groups = { cracky = 5, oddly_breakable_by_hand = 1, handy = 1, pickaxey = 1 },
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.9,
	is_ground_content = false,
	light_source = 4,
	
	sounds = {
		footstep = { name = 'gen_muffled_boop_hit', gain = 0.3, pitch = 0.5, fade = 0.0 },
		dig      = { name = 'gen_simple_tap_low', gain = 0.7, pitch = 1.0, fade = 0.0 },
		dug      = { name = 'mix_explode_puffy_metallic', gain = 1.0, pitch = 1.0, fade = 0.0 },
		place    = { name = 'gen_metallic_hit', gain = 1.0, pitch = 1.0, fade = 0.0 },
	},
})
