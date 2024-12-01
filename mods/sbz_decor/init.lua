local modpath = minetest.get_modpath("sbz_decor")


minetest.register_node("sbz_decor:photonlamp", {
    description = "Photon Lamp\n\nLight Source Only. Strength: 14,",
    drawtype = "mesh",
    mesh = "photonlamp.obj",
    tiles = { "photonlamp.png" },
    groups = {
        matter = 1,
        habitat_conducts = 1,
    },
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


minetest.register_node("sbz_decor:factory_floor", unifieddyes.def {
    description = "Factory Floor",
    tiles = { "factory_floor.png" },
    groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
    sunlight_propagates = true,
    walkable = true,
    sounds = sbz_api.sounds.matter(),
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

stairs.register("sbz_decor:factory_floor", {
    stair_front = "factory_floor_sf.png",
    stair_side = "factory_floor_ss.png",
    stair_cross = "factory_floor_sc.png"
})

minetest.register_node("sbz_decor:factory_floor_tiling", unifieddyes.def {
    description = "Factory Floor (Tiled)",
    tiles = { "factory_floor_tiling.png" },
    groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1, ud_param2_colorable = 1 },
    sunlight_propagates = true,
    walkable = true,
    sounds = sbz_api.sounds.matter(),
})

stairs.register("sbz_decor:factory_floor_tiling")

minetest.register_craft({
    output = "sbz_decor:factory_floor_tiling 4",
    type = "shapeless",
    recipe = { "sbz_decor:factory_floor", "sbz_decor:factory_floor", "sbz_decor:factory_floor", "sbz_decor:factory_floor" }
})

minetest.register_node("sbz_decor:factory_ventilator", {
    description = "Factory Ventilator",
    tiles = {
        { name = "factory_ventilator.png", animation = { type = "vertical_frames", length = 1 } },
    },
    groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
    sunlight_propagates = true,
    walkable = true,
    sounds = sbz_api.sounds.matter(),
})
minetest.register_craft({
    output = "sbz_decor:factory_ventilator",
    type = "shapeless",
    recipe = { "sbz_decor:factory_floor", "sbz_decor:factory_floor", "sbz_chem:lithium_powder", "sbz_chem:lead_powder" }
})

minetest.register_node("sbz_decor:factory_warning", unifieddyes.def {
    description = "Factory Warning",
    tiles = { "factory_warning.png" },
    groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
    sunlight_propagates = true,
    walkable = true,
    sounds = sbz_api.sounds.matter(),
})
stairs.register("sbz_decor:factory_warning")
minetest.register_craft({
    output = "sbz_decor:factory_warning 4",
    type = "shapeless",
    recipe = { "sbz_decor:factory_floor", "sbz_decor:factory_floor", "sbz_chem:gold_powder", "sbz_chem:gold_powder" }
})

local MP = minetest.get_modpath("sbz_decor")
dofile(MP .. "/signs.lua")
dofile(MP .. "/cnc.lua")

-- now... Ladders
-- inspired by what i saw from mtg ladders
local ladder_autoplace_limit = 16

core.register_node("sbz_decor:ladder", unifieddyes.def {
    description = "Matter Ladder",
    info_extra = "", -- idk if this is required but leaving it here anyway
    drawtype = "nodebox",
    node_box = {     -- nodebox inspired by that one 3d ladders mod, but i made this myself with nodebox editor
        type = "fixed",
        fixed = {
            { -0.5,   -0.5,    0.375, -0.375, 0.5,     0.5 }, -- NodeBox1
            { 0.375,  -0.5,    0.375, 0.5,    0.5,     0.5 }, -- NodeBox3
            { -0.375, 0.3125,  0.375, 0.375,  0.4375,  0.5 }, -- NodeBox5
            { -0.375, 0.0625,  0.375, 0.375,  0.1875,  0.5 }, -- NodeBox8
            { -0.375, -0.1875, 0.375, 0.375,  -0.0625, 0.5 }, -- NodeBox9
            { -0.375, -0.4375, 0.375, 0.375,  -0.3125, 0.5 }, -- NodeBox10
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {
            -8 / 16, -8 / 16, 3 / 16, 8 / 16, 8 / 16, 8 / 16
        }
    },
    tiles = { "matter_blob.png" },
    inventory_image = "ladder.png",
    groups = {
        matter = 3,
        explody = 3,
        habitat_conducts = 1,
    },
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    on_place = function(stack, placer, pointed, recursed)
        if (recursed or 0) > ladder_autoplace_limit then return end
        if pointed.type == "node" then
            local target = pointed.under
            local node = core.get_node(target)
            if node.name == "sbz_decor:ladder" then
                local dir = minetest.wallmounted_to_dir(node.param2)
                if dir == nil then return end
                dir.y = math.abs(dir.y)

                pointed.under = vector.add(pointed.under, dir)
                pointed.above = vector.add(pointed.above, dir)
                if core.get_node(pointed.under).name == "sbz_decor:ladder" then
                    local result = minetest.registered_nodes["sbz_decor:ladder"].on_place(stack, placer, pointed,
                        (recursed or 0) + 1)
                    return result
                end
                return core.item_place_node(stack, placer, pointed, node.param2)
            end
        end
        return core.item_place_node(stack, placer, pointed)
    end,
    node_placement_prediction = "", -- REQUIRED
    climbable = true,
})

core.register_craft {
    output = "sbz_decor:ladder 12",
    recipe = {
        { "sbz_resources:matter_blob", "",                          "sbz_resources:matter_blob", },
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob", "sbz_resources:matter_blob", },
        { "sbz_resources:matter_blob", "",                          "sbz_resources:matter_blob", },
    }
}
