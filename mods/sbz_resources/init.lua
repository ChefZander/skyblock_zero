minetest.log("action", "sbz resources: init")
local modpath = minetest.get_modpath("sbz_resources")

-- The Core
-- The basis of all progression

local function core_interact(pos, node, puncher, pointed_thing)
    minetest.sound_play("punch_core", {
        gain = 1.0,
        max_hear_distance = 32,
    })

    local items = { "sbz_resources:core_dust", "sbz_resources:matter_dust", "sbz_resources:charged_particle" }
    local item = items[math.random(#items)]

    if puncher and puncher:is_player() then
        local inv = puncher:get_inventory()
        if inv then
            local leftover = inv:add_item("main", item)
            if not leftover:is_empty() then
                minetest.add_item(pos, leftover)
            end
        end

        unlock_achievement(puncher:get_player_name(), "Introduction")
    end
end

minetest.log("action", "sbz resources: adding the_core")
minetest.register_node("sbz_resources:the_core", {
    description = "The Core",
    tiles = { "the_core.png" },
    groups = { unbreakable = 1 },
    drop = "",
    sunlight_propagates = true,
    paramtype = "light",
    light_source = 14,
    walkable = true,
    on_punch = core_interact,
    on_rightclick = core_interact,
})

-- Core Particles
minetest.register_abm({
    label = "Core Particles",
    nodenames = { "sbz_resources:the_core" },
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.add_particlespawner({
            amount = 1,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
            minvel = { x = -0.5, y = -0.5, z = -0.5 },
            maxvel = { x = 0.5, y = 0.5, z = 0.5 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 10,
            maxexptime = 20,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = false,
            vertical = false,
            texture = "core_particle.png",
            glow = 10
        })
    end,
})

-- Core Drops
minetest.register_craftitem("sbz_resources:core_dust", {
    description = "Core Dust",
    inventory_image = "core_dust.png",
    stack_max = 256,
})
minetest.register_craftitem("sbz_resources:matter_dust", {
    description = "Matter Dust",
    inventory_image = "matter_dust.png",
    stack_max = 256,
})
minetest.register_craftitem("sbz_resources:charged_particle", {
    description = "Charged Particle",
    inventory_image = "charged_particle.png",
    stack_max = 256,
})

-- Other Items
minetest.register_craftitem("sbz_resources:antimatter_dust", {
    description = "Antimatter Dust",
    inventory_image = "antimatter_dust.png",
    stack_max = 256,
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:antimatter_dust",
    recipe = { "sbz_resources:core_dust", "sbz_resources:matter_dust" }
})

-- dofiles
dofile(modpath .. "/power.lua")
dofile(modpath .. "/emitters.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/tools.lua")
dofile(modpath .. "/extractor.lua")
dofile(modpath .. "/generator.lua")
dofile(modpath .. "/storinators.lua")
dofile(modpath .. "/items.lua")
dofile(modpath .. "/organics.lua")
dofile(modpath .. "/infinite_storinator.lua")
