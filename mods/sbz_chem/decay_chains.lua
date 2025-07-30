--[[
Recipes for the decay accelerator
Currently, just used to make plutonium
If you want to add more, feel free to do so :D
]]
-- Ok so, no decay chains, just plutonium OR lead

sbz_api.recipe.register_craft_type({
    type = "decay_accelerating",
    description = "Decay Accelerating",
    icon = "decay_accel_front.png",
    single = true
})


for k, v in pairs { "sbz_chem:uranium_powder", "sbz_chem:thorium_powder", "sbz_chem:plutonium_powder" } do
    sbz_api.recipe.register_craft {
        output = "sbz_chem:plutonium_powder",
        type = "decay_accelerating",
        items = { v }
    }

    sbz_api.recipe.register_craft {
        output = "sbz_chem:lead_powder",
        type = "decay_accelerating",
        items = { v }
    }
end
