minetest.register_craft({
	output = "smartshop:shop",
	recipe = {
		{ "sbz_decor:matter_sign", "sbz_resources:storinator", "sbz_decor:matter_sign" },
		{ "sbz_decor:matter_sign", "sbz_resources:storinator", "sbz_decor:matter_sign" },
		{ "sbz_decor:matter_sign", "sbz_decor:photonlamp",     "sbz_decor:matter_sign" },
	},
})

minetest.register_craft({
	output = "smartshop:storage",
	recipe = {
		{ "sbz_resources:reinforced_matter", "sbz_resources:warp_crystal",          "sbz_resources:reinforced_matter" },
		{ "smartshop:shop",                  "sbz_resources:storinator_neutronium", "smartshop:shop" },
		{ "sbz_resources:reinforced_matter", "pipeworks:tube_1",                    "sbz_resources:reinforced_matter" },
	},
})
