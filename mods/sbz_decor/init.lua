local modpath = minetest.get_modpath("sbz_decor")

dofile(modpath .. "/deco_wires.lua")

minetest.register_node("sbz_decor:photonlamp", {
    description = "Photon Lamp\n\nLight Source Only. Strength: 14,",
    drawtype = "mesh",
    mesh = "photonlamp.obj",
    tiles = { "photonlamp.png" },
    groups = { matter = 1 },
    light_source = 14,
    selection_box = {
        type = "fixed",
        fixed = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
    },
    collision_box = {
        type = "fixed",
        fixed = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
    },
    use_texture_alpha = "clip",
})
minetest.register_craft({
    output = "sbz_decor:photonlamp",
    recipe = {
        { "sbz_resources:matter_plate",     "sbz_resources:emitter_imitator", "sbz_resources:matter_plate" },
        { "sbz_resources:emitter_imitator", "sbz_resources:matter_blob",      "sbz_resources:emitter_imitator" },
        { "sbz_resources:matter_plate",     "sbz_resources:emitter_imitator", "sbz_resources:matter_plate" }
    }
})


minetest.register_node("sbz_decor:factory_floor", {
    description = "Factory Floor",
    tiles = { "factory_floor.png" },
    groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
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
    output = "sbz_decor:factory_floor 2",
    type = "shapeless",
    recipe = {
        "sbz_resources:matter_blob", 
        "sbz_resources:matter_blob", 
        "sbz_resources:matter_blob", 
        "sbz_resources:matter_blob"
    }
})

minetest.register_node("sbz_decor:factory_floor_tiling", {
    description = "Factory Floor (Tiled)",
    tiles = { "factory_floor_tiling.png" },
    groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
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
    output = "sbz_decor:factory_floor_tiling 4",
    type = "shapeless",
    recipe = { "sbz_decor:factory_floor", "sbz_decor:factory_floor", "sbz_decor:factory_floor", "sbz_decor:factory_floor" }
})