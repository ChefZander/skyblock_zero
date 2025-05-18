-- instatubes are in other file
unified_inventory.register_craft {
    output = "sbz_resources:sensor_casing_plate 24",
    type = "blast_furnace",
    items = {
        "sbz_resources:reinforced_matter 60",
        "sbz_bio:shockshroom",
        "sbz_bio:cleargrass",
    },
}

sbz_api.blast_furnace_recipes[#sbz_api.blast_furnace_recipes + 1] = {
    recipe = {
        "sbz_resources:reinforced_matter 60",
        "sbz_bio:shockshroom",
        "sbz_bio:cleargrass",
    },
    names = {
        "sbz_resources:reinforced_matter",
        "sbz_bio:shockshroom",
        "sbz_bio:cleargrass",
    },
    output = "sbz_resources:sensor_casing_plate 24",
    chance = 1 / (9 * 6)
}
