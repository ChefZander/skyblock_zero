core.register_biome {
    name = "biome",
}

core.register_ore({
    ore_type = "scatter",
    ore = "sbz_resources:emitter",
    wherein = "air",
    clust_scarcity = 80 * 80 * 80,
    clust_num_ores = 1,
    clust_size = 1,
    y_min = -30000,
    y_max = 30000,
})
