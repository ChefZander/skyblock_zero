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
    output = "sbz_resources:matter_stair 8",
    recipe = {
        { "sbz_resources:matter_blob", "",                          "" },
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob", "" },
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob", "sbz_resources:matter_blob" }
    }
})
minetest.register_craft({
    output = "sbz_resources:matter_stair 8",
    recipe = {
        { "",                          "",                          "sbz_resources:matter_blob" },
        { "",                          "sbz_resources:matter_blob", "sbz_resources:matter_blob" },
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob", "sbz_resources:matter_blob" }
    }
})

minetest.register_node("sbz_resources:matter_slab", {
    description = "Matter Slab",
    tiles = { "matter_blob.png" },
    drawtype = "nodebox",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = { -0.5, -0.5, -0.5, 0.5, 0,   0.5 }
    },
    groups = { matter = 1, cracky = 3 },
    walkable = true,
    sounds = {
        footstep = { name = "step", gain = 1.0 },
    },
    on_punch = function(pos, node, puncher)
        minetest.sound_play("step", { pos = pos, gain = 1.0 })
    end,
    on_place = function (itemstack, user, pointed)
        if pointed.type ~= "node" then return itemstack end
        if pointed.under.y > pointed.above.y then return minetest.item_place_node(itemstack, user, pointed, 23) end
        if pointed.under.y < pointed.above.y then return minetest.item_place_node(itemstack, user, pointed, 0) end
        local exact_pos = minetest.pointed_thing_to_face_pos(user, pointed).y%1
        return minetest.item_place_node(itemstack, user, pointed, (exact_pos > 0.5 and exact_pos < 1 or exact_pos > -0.5 and exact_pos < 0) and 0 or 23)
    end
})

minetest.register_craft({
    output = "sbz_resources:matter_slab 6",
    recipe = {
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob", "sbz_resources:matter_blob" }
    }
})

minetest.register_node("sbz_resources:matter_platform", {
    description = "Matter Platform",
    tiles = { "matter_blob.png^platform_overlay.png^[makealpha:255,0,0" },
    use_texture_alpha = "clip",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = { -0.5, 0.375, -0.5, 0.5, 0.5,   0.5 }
    },
    groups = { matter = 2, cracky = 3 },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = true,
    sounds = {
        footstep = { name = "step", gain = 1.0 },
    },
    on_punch = function(pos, node, puncher)
        minetest.sound_play("step", { pos = pos, gain = 1.0 })
    end
})

minetest.register_craft({
    output = "sbz_resources:matter_platform 8",
    recipe = {
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob" }
    }
})
minetest.register_node("sbz_resources:antimatter_blob", {
    description = "Antimatter Blob",
    drawtype = "glasslike",
    tiles = { "antimatter_blob.png" },
    groups = { antimatter = 1, cracky = 3, explody = 3 },
    sunlight_propagates = true,
    walkable = true,
	light_source = 3,
    sounds = {
        footstep = { name = "invertedstep", gain = 1.0 },
    },
    on_punch = function(pos, node, puncher)
        minetest.sound_play("invertedstep", { pos = pos, gain = 1.0 })
    end,
})
minetest.register_craft({
    output = "sbz_resources:antimatter_blob",
    recipe = {
        { "sbz_resources:antimatter_dust", "sbz_resources:antimatter_dust", "sbz_resources:antimatter_dust" },
        { "sbz_resources:antimatter_dust", "sbz_resources:antimatter_dust", "sbz_resources:antimatter_dust" },
        { "sbz_resources:antimatter_dust", "sbz_resources:antimatter_dust", "sbz_resources:antimatter_dust" }
    }
})

minetest.register_node("sbz_resources:antimatter_stair", {
    description = "Antimatter Stair",
    tiles = { "antimatter_blob.png" },
    drawtype = "nodebox",
    paramtype2 = "facedir",
	light_source = 2,
    node_box = {
        type = "fixed",
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 0,   0.5 },
            { -0.5, 0,    0,    0.5, 0.5, 0.5 },
        }
    },
    groups = { antimatter = 1, cracky = 3 },
    walkable = true,
    sounds = {
        footstep = { name = "invertedstep", gain = 1.0 },
    },
    on_punch = function(pos, node, puncher)
        minetest.sound_play("invertedstep", { pos = pos, gain = 1.0 })
    end,
    use_texture_alpha = "clip"
})
minetest.register_craft({
    output = "sbz_resources:antimatter_stair 8",
    recipe = {
        { "sbz_resources:antimatter_blob", "",                          "" },
        { "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob", "" },
        { "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob" }
    }
})
minetest.register_craft({
    output = "sbz_resources:matter_stair 8",
    recipe = {
        { "",                          "",                          "sbz_resources:antimatter_blob" },
        { "",                          "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob" },
        { "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob" }
    }
})

minetest.register_node("sbz_resources:antimatter_slab", {
    description = "Antimatter Slab",
    tiles = { "antimatter_blob.png" },
    drawtype = "nodebox",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = { -0.5, -0.5, -0.5, 0.5, 0,   0.5 }
    },
    groups = { antimatter = 1, cracky = 3 },
	light_source = 2,
    walkable = true,
    sounds = {
        footstep = { name = "invertedstep", gain = 1.0 },
    },
    on_punch = function(pos, node, puncher)
        minetest.sound_play("invertedstep", { pos = pos, gain = 1.0 })
    end,
    on_place = function (itemstack, user, pointed)
        if pointed.type ~= "node" then return itemstack end
        if pointed.under.y > pointed.above.y then return minetest.item_place_node(itemstack, user, pointed, 23) end
        if pointed.under.y < pointed.above.y then return minetest.item_place_node(itemstack, user, pointed, 0) end
        local exact_pos = minetest.pointed_thing_to_face_pos(user, pointed).y%1
        return minetest.item_place_node(itemstack, user, pointed, (exact_pos > 0.5 and exact_pos < 1 or exact_pos > -0.5 and exact_pos < 0) and 0 or 23)
    end
})

minetest.register_craft({
    output = "sbz_resources:antimatter_slab 6",
    recipe = {
        { "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob" }
    }
})

minetest.register_node("sbz_resources:antimatter_platform", {
    description = "Antimatter Platform",
    tiles = { "antimatter_blob.png^platform_overlay.png^[makealpha:255,0,0" },
    use_texture_alpha = "clip",
	light_source = 2,
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = { -0.5, 0.375, -0.5, 0.5, 0.5,   0.5 }
    },
    groups = { antimatter = 2, cracky = 3 },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = true,
    sounds = {
        footstep = { name = "invertedstep", gain = 1.0 },
    },
    on_punch = function(pos, node, puncher)
        minetest.sound_play("invertedstep", { pos = pos, gain = 1.0 })
    end
})

minetest.register_craft({
    output = "sbz_resources:matter_platform 8",
    recipe = {
        { "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob" }
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
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:pebble 9",
    recipe = {"sbz_resources:stone"}
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
minetest.register_node("sbz_resources:reinforced_antimatter", {
    description = "Reinforced Antimatter",
    tiles = { "reinforced_antimatter.png" },
    groups = { antimatter = 1 },
	light_source = 5,
    sunlight_propagates = true,
    walkable = true,
})
minetest.register_craft({
    output = "sbz_resources:reinforced_antimatter",
    recipe = {
        { "",                           "sbz_resources:antimatter_plate", "" },
        { "sbz_resources:antimatter_plate", "sbz_resources:antimatter_blob",  "sbz_resources:antimatter_plate" },
        { "",                           "sbz_resources:antimatter_plate", "" }
    }
})
