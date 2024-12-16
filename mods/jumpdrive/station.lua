core.register_node("jumpdrive:station", {
    description = "Jumpdrive Station",
    tiles = {
        "jumpdrive_station.png",
    },
    groups = { matter = 1 },
})

core.register_craft {
    output = "jumpdrive:station 2",
    recipe = {
        { "jumpdrive:backbone",      "sbz_chem:aluminum_block", "jumpdrive:backbone" },
        { "sbz_chem:aluminum_block", "jumpdrive:engine",        "sbz_chem:aluminum_block" },
        { "jumpdrive:backbone",      "sbz_chem:aluminum_block", "jumpdrive:backbone" },
    }
}
