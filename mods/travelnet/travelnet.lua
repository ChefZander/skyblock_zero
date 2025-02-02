local default_travelnets = {
	{ nodename = "travelnet:travelnet", color = "#ffffff", light_source = minetest.LIGHT_MAX, recipe = travelnet.travelnet_recipe },
}

for _, cfg in ipairs(default_travelnets) do
	travelnet.register_travelnet_box(cfg)
end
