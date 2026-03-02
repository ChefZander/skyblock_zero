unified_inventory.register_craft_type("punching", {
    description = "Punching",
    icon = "robotic_arm.png^[transformR90",
    width = 1,
    height = 1,
    uses_crafting_grid = false,
})



-- The Core
-- The basis of all progression
-- Core Drops
minetest.register_craftitem("sbz_resources:core_dust", {
    description = "Core Dust",
    inventory_image = "core_dust.png",
    stack_max = 256,
})

unified_inventory.register_craft {
    output = "sbz_resources:core_dust",
    type = "punching",
    items = {
        "sbz_resources:the_core"
    }
}

unified_inventory.register_craft {
    output = "sbz_resources:core_dust",
    type = "punching",
    items = {
        "sbz_resources:emitter"
    }
}

minetest.register_craftitem("sbz_resources:matter_dust", {
    description = "Matter Dust",
    inventory_image = "matter_dust.png",
    stack_max = 256,
})
unified_inventory.register_craft {
    output = "sbz_resources:matter_dust",
    type = "punching",
    items = {
        "sbz_resources:the_core"
    }
}
unified_inventory.register_craft {
    output = "sbz_resources:matter_dust",
    type = "punching",
    items = {
        "sbz_resources:emitter"
    }
}

minetest.register_craftitem("sbz_resources:charged_particle", {
    description = "Charged Particle",
    inventory_image = "charged_particle.png",
    stack_max = 256,
})

unified_inventory.register_craft {
    output = "sbz_resources:charged_particle",
    type = "punching",
    items = {
        "sbz_resources:the_core"
    }
}
unified_inventory.register_craft {
    output = "sbz_resources:charged_particle",
    type = "punching",
    items = {
        "sbz_resources:emitter"
    }
}

-- Other Items
minetest.register_craftitem("sbz_resources:antimatter_dust", {
    description = "Antimatter Dust",
    inventory_image = "antimatter_dust.png",
    stack_max = 256,
})

do -- Antimatter Dust recipe scope
    local Antimatter_Dust = 'sbz_resources:antimatter_dust'
    local CD = 'sbz_resources:core_dust'
    local MD = 'sbz_resources:matter_dust'
    core.register_craft({
        type = 'shapeless',
        output = Antimatter_Dust,
        recipe = { CD, MD }
    })
end

do -- Matter Dust recipe scope
    local Matter_Dust = 'sbz_resources:matter_dust'
    local CD = 'sbz_resources:core_dust'
    local AD = 'sbz_resources:antimatter_dust'
    core.register_craft({
        type = 'shapeless',
        output = Matter_Dust,
        recipe = { CD, AD }
    })
end
