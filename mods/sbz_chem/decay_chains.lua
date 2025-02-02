--[[
Recipes for the decay accelerator
Currently, just used to make plutonium
If you want to add more, feel free to do so :D
]]

unified_inventory.register_craft_type("decay_accelerating", {
    description = "Decay Accelerating",
    icon = "decay_accel_front.png",
    width = 1,
    height = 1,
    uses_crafting_grid = false,
})

unified_inventory.register_craft {
    output = "sbz_chem:plutonium_powder",
    type = "decay_accelerating",
    items = {
        "sbz_chem:uranium_powder"
    }
}
