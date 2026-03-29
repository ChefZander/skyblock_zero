local S = core.get_translator(core.get_current_modname())

core.register_node("jumpdrive:backbone", {
	description = S("Jumpdrive Backbone"),

	tiles = { "jumpdrive_backbone.png" },
	groups = { cracky = 3, oddly_breakable_by_hand = 3, handy = 1, pickaxey = 1, matter = 1, level = 2 },

	sounds = {
		footstep = { name = 'gen_muffled_boop_hit', gain = 0.3, pitch = 0.5, fade = 0.0 },
		dig      = { name = 'gen_simple_tap_low', gain = 0.7, pitch = 1.0, fade = 0.0 },
		dug      = { name = 'mix_explode_puffy_metallic', gain = 1.0, pitch = 1.0, fade = 0.0 },
		place    = { name = 'gen_metallic_hit', gain = 1.0, pitch = 1.0, fade = 0.0 },
	},

	is_ground_content = false,
	light_source = 13
})
