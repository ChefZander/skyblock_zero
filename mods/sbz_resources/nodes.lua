minetest.register_node("sbz_resources:matter_blob", unifieddyes.def {
    description = "Matter Blob",
    tiles = { "matter_blob.png" },
    groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
    walkable = true,
    sounds = sbz_api.sounds.matter(),
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
stairs.register("sbz_resources:matter_blob")
minetest.register_alias("sbz_resources:matter_stair", "sbz_resources:matter_blob_stair")
minetest.register_alias("sbz_resources:matter_slab", "sbz_resources:matter_blob_slab")

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
    sounds = sbz_api.sounds.matter(),
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

minetest.register_node("sbz_resources:antimatter_blob", unifieddyes.def {
    description = "Antimatter Blob",
    tiles = { "antimatter_blob.png" },
    groups = { antimatter = 1, cracky = 3, explody = 3, slippery = 32767, },
    walkable = true,
    light_source = 3,
    sounds = sbz_api.sounds.antimatter(),
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

stairs.register("sbz_resources:antimatter_blob")
minetest.register_alias("sbz_resources:antimatter_stair", "sbz_resources:antimatter_blob_stair")
minetest.register_alias("sbz_resources:antimatter_slab", "sbz_resources:antimatter_blob_slab")

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
    sounds = sbz_api.sounds.antimatter(),
    on_punch = function(pos, node, puncher)
        minetest.sound_play("invertedstep", { pos = pos, gain = 1.0 })
    end
})

minetest.register_craft({
    output = "sbz_resources:antimatter_platform 8",
    recipe = {
        { "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob" }
    }
})

minetest.register_node("sbz_resources:emitter_imitator", {
    description = "Emitter Immitator",
    tiles = { "emitter_imitator.png" },
    groups = { matter = 1, explody = 3 },
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
        { "",                        "sbz_resources:core_dust",       "" },
        { "sbz_resources:core_dust", "sbz_resources:antimatter_blob", "sbz_resources:core_dust" },
        { "",                        "sbz_resources:core_dust",       "" }
    }
})



minetest.register_node("sbz_resources:stone", unifieddyes.def {
    description = "Stone",
    tiles = { "stone.png" },
    groups = { matter = 1, moss_growable = 1, charged = 1 },
    walkable = true,
    sounds = sbz_api.sounds.matter(),
})

stairs.register("sbz_resources:stone")

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
    walkable = true,
    sounds = sbz_api.sounds.matter(),
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
    walkable = true,
    sounds = sbz_api.sounds.matter(),
})

minetest.register_craft({
    output = "sbz_resources:reinforced_antimatter",
    recipe = {
        { "",                               "sbz_resources:antimatter_plate", "" },
        { "sbz_resources:antimatter_plate", "sbz_resources:antimatter_blob",  "sbz_resources:antimatter_plate" },
        { "",                               "sbz_resources:antimatter_plate", "" }
    }
})
if false then -- annoying as hell
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
                        minetest.set_node(pointed.under,
                            { name = minetest.registered_nodes[nodename]._exploded or "air" })
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
end

minetest.register_node("sbz_resources:emittrium_glass", {
    description = "Emittrium Glass",
    drawtype = "glasslike_framed_optional",
    tiles = { "emittrium_glass.png", "emittrium_glass_shine.png" },
    use_texture_alpha = "clip",
    paramtype = "light",
    sunlight_propagates = true,
    groups = { matter = 1, transparent = 1, explody = 100 },
    sounds = sbz_api.sounds.glass(),
})

minetest.register_craft({
    output = "sbz_resources:emittrium_glass 16",
    recipe = {
        { "sbz_resources:raw_emittrium",   "sbz_resources:antimatter_dust", "sbz_resources:raw_emittrium" },
        { "sbz_resources:antimatter_dust", "",                              "sbz_resources:antimatter_dust" },
        { "sbz_resources:raw_emittrium",   "sbz_resources:antimatter_dust", "sbz_resources:raw_emittrium" }
    }
})

minetest.register_node("sbz_resources:colorium_glass", unifieddyes.def {
    description = "Colorium Glass",
    drawtype = "glasslike_framed_optional",
    tiles = { "emittrium_glass.png^[colorize:#ffffff:255", "emittrium_glass_shine.png^[colorize:#ffffff:255" },
    use_texture_alpha = "clip",
    paramtype = "light",
    sunlight_propagates = true,
    groups = { matter = 1, transparent = 1, explody = 100 },
    sounds = sbz_api.sounds.glass(),
})

core.register_craft {
    output = "sbz_resources:colorium_glass 8",
    recipe = {
        { "sbz_resources:emittrium_glass", "sbz_resources:emittrium_glass", "sbz_resources:emittrium_glass", },
        { "sbz_resources:emittrium_glass", "unifieddyes:colorium",          "sbz_resources:emittrium_glass", },
        { "sbz_resources:emittrium_glass", "sbz_resources:emittrium_glass", "sbz_resources:emittrium_glass", },
    }
}


minetest.register_node("sbz_resources:clear_colorium_glass", unifieddyes.def {
    description = "Clear Colorium Glass",
    drawtype = "glasslike_framed_optional",
    tiles = { "emittrium_glass_border.png^[colorize:#ffffff:255", "blank.png" },
    use_texture_alpha = "clip",
    paramtype = "light",
    sunlight_propagates = true,
    groups = { matter = 1, transparent = 1, explody = 100 },
    sounds = sbz_api.sounds.glass(),
    info_extra = "Recipe requires cleargrass but it returns it back once you've crafted with it."
})

core.register_craft {
    output = "sbz_resources:clear_colorium_glass 8",
    recipe = {
        { "sbz_resources:colorium_glass", "sbz_resources:colorium_glass", "sbz_resources:colorium_glass" },
        { "sbz_resources:colorium_glass", "sbz_bio:cleargrass",           "sbz_resources:colorium_glass" },
        { "sbz_resources:colorium_glass", "sbz_resources:colorium_glass", "sbz_resources:colorium_glass" },
    },
    replacements = {
        { "sbz_bio:cleargrass", "sbz_bio:cleargrass" }
    }
}

minetest.register_node("sbz_resources:stained_colorium_glass", unifieddyes.def {
    description = "Stained Colorium Glass",
    drawtype = "glasslike_framed",
    tiles = { "emittrium_glass_border.png^[colorize:#ffffff:255", "(blank.png^[invert:rgba^[opacity:150)" },
    inventory_image = core.inventorycube "stained_glass_inv.png",
    use_texture_alpha = "blend",
    backface_culling = true,
    paramtype = "light",
    sunlight_propagates = true,
    groups = { matter = 1, transparent = 1, explody = 100 },
    sounds = sbz_api.sounds.glass(),
    info_extra = { "Recipe requires razorgrass, but it returns it back once you've crafted with it." }
})

core.register_craft {
    output = "sbz_resources:stained_colorium_glass 8",
    recipe = {
        { "sbz_resources:colorium_glass", "sbz_resources:colorium_glass", "sbz_resources:colorium_glass" },
        { "sbz_resources:colorium_glass", "sbz_bio:razorgrass",           "sbz_resources:colorium_glass" },
        { "sbz_resources:colorium_glass", "sbz_resources:colorium_glass", "sbz_resources:colorium_glass" },
    },
    replacements = {
        { "sbz_bio:razorgrass", "sbz_bio:razorgrass" }
    }
}

minetest.register_node("sbz_resources:compressed_core_dust", {
    description = "Compressed core dust",
    tiles = {
        "compressed_core_dust.png"
    },
    info_extra = { "You can use this to protect against antimatter" },
    groups = { matter = 2, oddly_breakable_by_hand = 1, explody = 5 },
    sounds = sbz_api.sounds.matter(),
})

minetest.register_craft({
    output = "sbz_resources:compressed_core_dust",
    recipe = {
        { "sbz_resources:core_dust", "sbz_resources:core_dust", "sbz_resources:core_dust" },
        { "sbz_resources:core_dust", "sbz_resources:core_dust", "sbz_resources:core_dust" },
        { "sbz_resources:core_dust", "sbz_resources:core_dust", "sbz_resources:core_dust" },
    }
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:core_dust 9",
    recipe = { "sbz_resources:compressed_core_dust" }
})

-- sands
minetest.register_node("sbz_resources:sand", unifieddyes.def {
    description = "Sand",
    tiles = { "sand.png" },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, explody = 80 },

    walkable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})

minetest.register_node("sbz_resources:red_sand", {
    description = "Red Sand",
    tiles = { "sand.png^[colorize:red:128" },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, float = 1, explody = 80 },
    walkable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})

minetest.register_node("sbz_resources:gravel", {
    description = "Gravel",
    tiles = { "gravel.png" },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, explody = 40 },
    walkable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})

core.register_node("sbz_resources:dark_sand", {
    description = "Dark Sand",
    tiles = { "sand.png^[colorizehsl:0:0:-50" },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, float = 0, explody = 80 },

    walkable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})

core.register_node("sbz_resources:black_sand", {
    description = "Black Sand",
    tiles = { "sand.png^[colorizehsl:0:0:-80" },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, float = 1, explody = 80 },

    walkable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})

core.register_node("sbz_resources:white_sand", {
    description = "White Sand",
    tiles = { "sand.png^[colorizehsl:0:0" },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, float = 0, explody = 80 },

    walkable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})
