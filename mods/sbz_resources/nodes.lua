minetest.register_node("sbz_resources:matter_blob", {
    description = "Matter Blob",
    drawtype = "glasslike",
    tiles = { "matter_blob.png" },
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
    groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
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
        fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }
    },
    groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
    walkable = true,
    sounds = {
        footstep = { name = "step", gain = 1.0 },
    },
    on_punch = function(pos, node, puncher)
        minetest.sound_play("step", { pos = pos, gain = 1.0 })
    end,
    node_placement_prediction = "",
    on_place = function(itemstack, user, pointed)
        if pointed.type ~= "node" then return itemstack end
        local ydir = pointed.under.y - pointed.above.y
        local node = minetest.get_node(pointed.under)
        if node.name == "sbz_resources:matter_slab" and (node.param2 == 0 and ydir < 0 or node.param2 == 23 and ydir > 0) then
            minetest.set_node(pointed.under, { name = "sbz_resources:matter_blob" })
            itemstack:take_item()
            return itemstack
        end
        if ydir > 0 then return minetest.item_place_node(itemstack, user, pointed, 23) end
        if ydir < 0 then return minetest.item_place_node(itemstack, user, pointed, 0) end
        local exact_pos = minetest.pointed_thing_to_face_pos(user, pointed).y % 1
        return minetest.item_place_node(itemstack, user, pointed,
            (exact_pos > 0.5 and exact_pos < 1 or exact_pos > -0.5 and exact_pos < 0) and 0 or 23)
    end,
    allow_moss_growth = function(pos, node, dir)
        return dir.y == 0 or node.param2 == 0 and dir.y < 0 or node.param2 == 23 and dir.y > 0
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
        fixed = { -0.5, 0.375, -0.5, 0.5, 0.5, 0.5 }
    },
    groups = { matter = 2, cracky = 3, explody = 8, moss_growable = 1 },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = true,
    sounds = {
        footstep = { name = "step", gain = 1.0 },
    },
    on_punch = function(pos, node, puncher)
        minetest.sound_play("step", { pos = pos, gain = 1.0 })
    end,
    allow_moss_growth = function(pos, node, dir)
        return dir.y > 0
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
    groups = { antimatter = 1, cracky = 3, explody = 3, slippery = 255, },
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
        { "sbz_resources:antimatter_blob", "",                              "" },
        { "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob", "" },
        { "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob" }
    }
})
minetest.register_craft({
    output = "sbz_resources:matter_stair 8",
    recipe = {
        { "",                              "",                              "sbz_resources:antimatter_blob" },
        { "",                              "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob" },
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
        fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 }
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
    on_place = function(itemstack, user, pointed)
        if pointed.type ~= "node" then return itemstack end
        if pointed.under.y > pointed.above.y then return minetest.item_place_node(itemstack, user, pointed, 23) end
        if pointed.under.y < pointed.above.y then return minetest.item_place_node(itemstack, user, pointed, 0) end
        local exact_pos = minetest.pointed_thing_to_face_pos(user, pointed).y % 1
        return minetest.item_place_node(itemstack, user, pointed,
            (exact_pos > 0.5 and exact_pos < 1 or exact_pos > -0.5 and exact_pos < 0) and 0 or 23)
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
        fixed = { -0.5, 0.375, -0.5, 0.5, 0.5, 0.5 }
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
        { "sbz_resources:antimatter_blob", "sbz_resources:core_dust",   "sbz_resources:antimatter_blob" },
        { "sbz_resources:core_dust",       "sbz_resources:matter_blob", "sbz_resources:core_dust" },
        { "sbz_resources:antimatter_blob", "sbz_resources:core_dust",   "sbz_resources:antimatter_blob" }
    }
})



minetest.register_node("sbz_resources:stone", {
    description = "Stone",
    tiles = { "stone.png" },
    groups = { matter = 1, moss_growable = 1 },
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
    recipe = { "sbz_resources:stone" }
})


minetest.register_node("sbz_resources:reinforced_matter", {
    description = "Reinforced Matter",
    tiles = { "reinforced_matter.png" },
    groups = { matter = 1, moss_growable = 1 },
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
        { "",                               "sbz_resources:antimatter_plate", "" },
        { "sbz_resources:antimatter_plate", "sbz_resources:antimatter_blob",  "sbz_resources:antimatter_plate" },
        { "",                               "sbz_resources:antimatter_plate", "" }
    }
})

minetest.register_abm({
    label = "Annihilate matter and antimatter",
    nodenames = { "group:matter" },
    neighbors = { "group:antimatter" },
    interval = 1,
    chance = 1,
    action = function(pos)
        minetest.add_particlespawner({
            amount = 1000,
            time = 0.2,
            minpos = { x = pos.x - 1 / 3, y = pos.y - 1 / 3, z = pos.z - 1 / 3 },
            maxpos = { x = pos.x + 1 / 3, y = pos.y + 1 / 3, z = pos.z + 1 / 3 },
            minvel = { x = -5, y = -5, z = -5 },
            maxvel = { x = 5, y = 5, z = 5 },
            minacc = { x = -1, y = -1, z = -1 },
            maxacc = { x = 1, y = 1, z = 1 },
            minexptime = 5,
            maxexptime = 10,
            minsize = 0.5,
            maxsize = 1.5,
            collisiondetection = false,
            vertical = false,
            texture = "star.png",
            glow = 10
        })
        minetest.remove_node(pos)
        -- copied from sbz_meteorites
        for _ = 1, 100 do
            local raycast = minetest.raycast(pos, pos + vector.random_direction() * 8, false)
            local wear = 0
            for pointed in raycast do
                if pointed.type == "node" then
                    local nodename = minetest.get_node(pointed.under).name
                    wear = wear + (1 / minetest.get_item_group(nodename, "explody")) +
                        minetest.get_item_group(nodename, "sbz_machine")
                    --the explody group hence signifies roughly how many such nodes in a straight line it can break before stopping
                    --although this is very random
                    if wear > 1 then break end
                    minetest.set_node(pointed.under, { name = minetest.registered_nodes[nodename]._exploded or "air" })
                end
            end
        end
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 8)) do
            if obj:is_player() then
                local dir = obj:get_pos() - pos
                obj:add_velocity((vector.normalize(dir) + vector.new(0, 0.5, 0)) * 1.5 * (8 - vector.length(dir)))
            end
        end
    end
})

minetest.register_node("sbz_resources:emittrium_glass", {
    description = "Emittrium Glass",
    drawtype = "glasslike_framed_optional",
    tiles = { "emittrium_glass.png", "emittrium_glass_shine.png" },
    use_texture_alpha = "clip",
    paramtype = "light",
    sunlight_propagates = true,
    groups = { matter = 1, transparent = 1 }
})

minetest.register_craft({
    output = "sbz_resources:emittrium_glass 16",
    recipe = {
        { "sbz_resources:raw_emittrium",   "sbz_resources:antimatter_dust", "sbz_resources:raw_emittrium" },
        { "sbz_resources:antimatter_dust", "",                              "sbz_resources:antimatter_dust" },
        { "sbz_resources:raw_emittrium",   "sbz_resources:antimatter_dust", "sbz_resources:raw_emittrium" }
    }
})

local water_image = "water.png^[opacity:127"

minetest.register_node("sbz_resources:water_source", {
    description = "Water Source",
    drawtype = "liquid",
    tiles = { water_image },
    inventory_image = water_image,
    use_texture_alpha = "clip",
    groups = { habitat_conducts = 1, transparent = 1, liquid_capturable = 1 },
    post_effect_color = "#4000ff80",
    paramtype = "light",
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "source",
    liquid_alternative_source = "sbz_resources:water_source",
    liquid_alternative_flowing = "sbz_resources:water_flowing"
})

minetest.register_node("sbz_resources:water_flowing", {
    description = "Flowing Water",
    drawtype = "flowingliquid",
    tiles = { water_image },
    special_tiles = { water_image, water_image },
    inventory_image = water_image,
    use_texture_alpha = "clip",
    groups = { habitat_conducts = 1, transparent = 1, not_in_creative_inventory = 1 },
    post_effect_color = "#4000ff80",
    paramtype = "light",
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "flowing",
    liquid_alternative_source = "sbz_resources:water_source",
    liquid_alternative_flowing = "sbz_resources:water_flowing"
})
