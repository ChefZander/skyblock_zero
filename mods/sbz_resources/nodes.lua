minetest.register_node("sbz_resources:matter_blob", {
    description = "Matter Blob",
    drawtype = "glasslike",
    tiles = { "matter_blob.png" },
    groups = { matter = 1, cracky = 3 },
    sunlight_propagates = true,
    walkable = true,
    sounds = {
        footstep = { name = "step", gain = 1.0 },
    },
    on_punch = function(pos, node, puncher)
        minetest.sound_play("step", { pos = pos, gain = 1.0 })
    end,
})
minetest.register_craft({
    output = "sbz_resources:matter_blob",
    recipe = {
        { "sbz_resources:matter_dust", "sbz_resources:matter_dust", "sbz_resources:matter_dust" },
        { "sbz_resources:matter_dust", "sbz_resources:matter_dust", "sbz_resources:matter_dust" },
        { "sbz_resources:matter_dust", "sbz_resources:matter_dust", "sbz_resources:matter_dust" }
    }
})

sbz_api.register_generator("sbz_resources:simple_charged_field", {
    description = "Simple Charged Field\n\nGenerates: 3 power.\nDecaying: 10% chance every 100s. (when placed)",
    drawtype = "glasslike",
    tiles = { "simple_charged_field.png" },
    groups = { matter = 1, cracky = 3, sbz_machine = 1 },
    sunlight_propagates = true,
    walkable = false,
    power_generated = 3,
    on_dig = function(pos, node, digger)
        minetest.sound_play("charged_field_shutdown", {
            gain = 5.0,
            max_hear_distance = 32,
            pos = pos,
        })
        minetest.node_dig(pos, node, digger)
    end,
})
minetest.register_craft({
    output = "sbz_resources:simple_charged_field",
    recipe = {
        { "sbz_resources:charged_particle", "sbz_resources:charged_particle", "sbz_resources:charged_particle" },
        { "sbz_resources:charged_particle", "sbz_resources:charged_particle", "sbz_resources:charged_particle" },
        { "sbz_resources:charged_particle", "sbz_resources:charged_particle", "sbz_resources:charged_particle" }
    }
})
minetest.register_abm({
    label = "Simple Charged Field Particles",
    nodenames = { "sbz_resources:simple_charged_field" },
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.add_particlespawner({
            amount = 5,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
            minvel = { x = -2, y = -2, z = -2 },
            maxvel = { x = 2, y = 2, z = 2 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 10,
            maxexptime = 20,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = false,
            vertical = false,
            texture = "charged_particle.png",
            glow = 10
        })
    end,
})
minetest.register_abm({
    label = "Simple Charged Field Decay",
    nodenames = { "sbz_resources:simple_charged_field" },
    interval = 100,
    chance = 10,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.after(1, function()
            -- field decayed
            minetest.set_node(pos, { name = "sbz_resources:charged_field_residue" })

            -- plop
            minetest.sound_play("decay", { pos = pos, gain = 1.0 })

            -- more particles!
            minetest.add_particlespawner({
                amount = 100,
                time = 1,
                minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                minvel = { x = -5, y = -5, z = -5 },
                maxvel = { x = 5, y = 5, z = 5 },
                minacc = { x = 0, y = 0, z = 0 },
                maxacc = { x = 0, y = 0, z = 0 },
                minexptime = 10,
                maxexptime = 20,
                minsize = 0.5,
                maxsize = 1.0,
                collisiondetection = false,
                vertical = false,
                texture = "charged_particle.png",
                glow = 10
            })
        end)
    end,
})

minetest.register_node("sbz_resources:charged_field_residue", {
    description = "Charged Field Residue",
    drawtype = "glasslike",
    tiles = { "charged_field_residue.png" },
    groups = { unbreakable = 1 },
    sunlight_propagates = true,
    walkable = true,
    on_punch = function(pos, node, puncher, pointed_thing)
        displayDialougeLine(puncher:get_player_name(), "The residue is still decaying.")
    end,
})
minetest.register_abm({
    label = "Charged Field Residue Decay",
    nodenames = { "sbz_resources:charged_field_residue" },
    interval = 100,
    chance = 10,
    action = function(pos, node, active_object_count, active_object_count_wider)
        -- residue decayed
        minetest.set_node(pos, { name = "air" })

        -- plop, again
        minetest.sound_play("decay", { pos = pos, gain = 1.0 })
    end,
})

minetest.register_node("sbz_resources:emitter_imitator", {
    description = "Emitter Immitator\n\nLight Source Only. Strength: 10.",
    drawtype = "glasslike",
    tiles = { "emitter_imitator.png" },
    groups = { matter = 1 },
    sunlight_propagates = true,
    paramtype = "light",
    light_source = 10,
    walkable = true,
    on_punch = function(pos, node, puncher, pointed_thing)
        minetest.add_particlespawner({
            amount = 50,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
            minvel = { x = -5, y = -5, z = -5 },
            maxvel = { x = 5, y = 5, z = 5 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 30,
            maxexptime = 50,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = false,
            vertical = false,
            texture = "star.png",
            glow = 10
        })
    end,
})
minetest.register_craft({
    output = "sbz_resources:emitter_imitator",
    recipe = {
        { "sbz_resources:antimatter_dust", "sbz_resources:antimatter_dust", "sbz_resources:antimatter_dust" },
        { "sbz_resources:antimatter_dust", "sbz_resources:matter_blob",     "sbz_resources:antimatter_dust" },
        { "sbz_resources:antimatter_dust", "sbz_resources:antimatter_dust", "sbz_resources:antimatter_dust" }
    }
})


minetest.register_node("sbz_resources:stone", {
    description = "Stone",
    tiles = { "stone.png" },
    groups = { matter = 1 },
    sunlight_propagates = true,
    walkable = true,
})
minetest.register_craft({
    output = "sbz_resources:stone",
    recipe = {
        { "sbz_resources:pebble", "sbz_resources:pebble", "sbz_resources:pebble" },
        { "sbz_resources:pebble", "sbz_resources:pebble", "sbz_resources:pebble" },
        { "sbz_resources:pebble", "sbz_resources:pebble", "sbz_resources:pebble" }
    }
})


minetest.register_node("sbz_resources:reinforced_matter", {
    description = "Reinforced Matter",
    tiles = { "reinforced_matter.png" },
    groups = { matter = 1 },
    sunlight_propagates = true,
    walkable = true,
})
minetest.register_craft({
    output = "sbz_resources:reinforced_matter",
    recipe = {
        { "",                           "sbz_resources:matter_plate", "" },
        { "sbz_resources:matter_plate", "sbz_resources:matter_blob",  "sbz_resources:matter_plate" },
        { "",                           "sbz_resources:matter_plate", "" }
    }
})

-- Starlight Collector
sbz_api.register_generator("sbz_resources:starlight_collector", {
    description = "Starlight Collector",
    drawtype = "nodebox",
    tiles = { "starlight_collector.png", "matter_blob.png", "matter_blob.png", "matter_blob.png", "matter_blob.png", "matter_blob.png" },
    groups = { matter = 1, pipe_connects=1 },
    sunlight_propagates = true,
    walkable = true,
    node_box = {
        type = "fixed",
        fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
    },

    power_generated = 1,
})

minetest.register_craft({
    output = "sbz_resources:starlight_collector 2",
    recipe = {
        { "",                            "",                            "" },
        { "sbz_resources:raw_emittrium", "sbz_resources:raw_emittrium", "sbz_resources:raw_emittrium" },
        { "sbz_resources:matter_blob",   "sbz_resources:matter_blob",   "sbz_resources:matter_blob" }
    }
})
minetest.register_abm({
    label = "Starlight Collector Particles",
    nodenames = { "sbz_resources:starlight_collector" },
    interval = 1,
    chance = 0.5,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.add_particlespawner({
            amount = 2,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y + 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 1, z = pos.z + 0.5 },
            minvel = { x = 0, y = -2, z = 0 },
            maxvel = { x = 0, y = -1, z = 0 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 1,
            maxexptime = 1,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = true,
            vertical = false,
            texture = "star.png",
            glow = 10
        })
    end,
})
