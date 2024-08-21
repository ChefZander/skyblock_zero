minetest.register_node("sbz_resources:matter_blob", {
    description = "Matter Blob",
    drawtype = "glasslike",
    tiles = { "matter_blob.png" },
    groups = { matter = 1, cracky = 3, explody = 3 },
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

minetest.register_node("sbz_resources:matter_stair", {
    description = "Matter Stair",
    tiles = { "matter_blob.png" },
    drawtype = "nodebox",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 0,   0.5 },
            { -0.5, 0,    0,    0.5, 0.5, 0.5 },
        }
    },
    groups = { matter = 1, cracky = 3 },
    sunlight_propagates = true,
    walkable = true,
    sounds = {
        footstep = { name = "step", gain = 1.0 },
    },
    on_punch = function(pos, node, puncher)
        minetest.sound_play("step", { pos = pos, gain = 1.0 })
    end,
    use_texture_alpha = "clip"
})
minetest.register_craft({
    output = "sbz_resources:matter_stair 3",
    recipe = {
        { "sbz_resources:matter_blob", "",                          "" },
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob", "" },
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob", "sbz_resources:matter_blob" }
    }
})
minetest.register_craft({
    output = "sbz_resources:matter_stair 3",
    recipe = {
        { "",                          "",                          "sbz_resources:matter_blob" },
        { "",                          "sbz_resources:matter_blob", "sbz_resources:matter_blob" },
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob", "sbz_resources:matter_blob" }
    }
})

minetest.register_node("sbz_resources:emitter_imitator", {
    description = "Emitter Immitator\n\nLight Source Only. Strength: 10.",
    drawtype = "glasslike",
    tiles = { "emitter_imitator.png" },
    groups = { matter = 1, explody = 3 },
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