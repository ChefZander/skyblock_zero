local S = core.get_translator(core.get_current_modname())

core.register_node(
    'sbz_resources:matter_blob',
    unifieddyes.def {
        description = S("Matter Blob"),
        tiles = { 'matter_blob.png' },
        groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
        walkable = true,
        sounds = sbz_api.sounds.matter(),
        on_punch = function(pos, node, puncher)
            core.sound_play('step', { pos = pos, gain = 1.0 })
        end,
    }
)
stairs.register 'sbz_resources:matter_blob'
core.register_alias('sbz_resources:matter_stair', 'sbz_resources:matter_blob_stair')
core.register_alias('sbz_resources:matter_slab', 'sbz_resources:matter_blob_slab')

local platform_nodebox = {
    type = 'fixed',
    fixed = { -0.5, 0.375, -0.5, 0.5, 0.5, 0.5 },
}

local platform_selbox = {
    type = 'fixed',
    fixed = { -0.5, 0.25, -0.5, 0.5, 0.5, 0.5 },
}

core.register_node(
    'sbz_resources:matter_platform',
    unifieddyes.def {
        description = S("Matter Platform"),
        tiles = { 'matter_blob.png^platform_overlay.png^[makealpha:255,0,0' },
        use_texture_alpha = 'clip',
        drawtype = 'nodebox',
        paramtype2 = 'color',
        node_box = platform_nodebox,
        selection_box = platform_selbox,
        groups = { matter = 2, cracky = 3, explody = 8, moss_growable = 1 },
        paramtype = 'light',
        sunlight_propagates = true,
        walkable = true,
        sounds = sbz_api.sounds.matter(),
        on_punch = function(pos, node, puncher)
            core.sound_play('step', { pos = pos, gain = 1.0 })
        end,
        allow_moss_growth = function(pos, node, dir)
            return dir.y > 0
        end,
    }
)

do -- Matter Platform recipe scope
    local Matter_Platform = 'sbz_resources:matter_platform'
    local amount = 8
    local MB = 'sbz_resources:matter_blob'
    core.register_craft {
        output = Matter_Platform .. ' ' .. tostring(amount),
        recipe = {
            { MB, MB },
        }
    }
end


do -- Matter Blob recipe scope
    local Matter_Blob = 'sbz_resources:matter_blob'
    local MP = 'sbz_resources:matter_platform'
    core.register_craft {
        type = 'shapeless',
        output = Matter_Blob,
        recipe = {
            MP, MP, MP, MP
        },
    }
end

core.register_node(
    'sbz_resources:antimatter_blob',
    unifieddyes.def {
        description = S("Antimatter Blob"),
        tiles = { 'antimatter_blob.png' },
        groups = { antimatter = 1, cracky = 3, explody = 3, slippery = 32767 },
        walkable = true,
        light_source = 3,
        sounds = sbz_api.sounds.antimatter(),
        on_punch = function(pos, node, puncher)
            core.sound_play('invertedstep', { pos = pos, gain = 1.0 })
        end,
    }
)

do -- Antimatter Blob recipe scope
    local Antimatter_Blob = 'sbz_resources:antimatter_blob'
    local AD = 'sbz_resources:antimatter_dust'
    core.register_craft {
        output = Antimatter_Blob,
        recipe = {
            { AD, AD, AD },
            { AD, AD, AD },
            { AD, AD, AD },
        }
    }
end

sbz_api.recipe.register_craft {
    type = 'crushing',
    output = 'sbz_resources:antimatter_dust 9',
    items = {
        'sbz_resources:antimatter_blob',
    },
}

do -- Antimatter Blob recipe scope
    local Antimatter_Blob = 'sbz_resources:antimatter_blob'
    local AP = 'sbz_resources:antimatter_platform'
    core.register_craft {
        type = 'shapeless',
        output = Antimatter_Blob,
        recipe = {
            AP, AP, AP, AP
        },
    }
end

stairs.register 'sbz_resources:antimatter_blob'
core.register_alias('sbz_resources:antimatter_stair', 'sbz_resources:antimatter_blob_stair')
core.register_alias('sbz_resources:antimatter_slab', 'sbz_resources:antimatter_blob_slab')

core.register_node(
    'sbz_resources:antimatter_platform',
    unifieddyes.def {
        description = S("Antimatter Platform"),
        tiles = { 'antimatter_blob.png^platform_overlay.png^[makealpha:255,0,0' },
        use_texture_alpha = 'clip',
        paramtype2 = 'color',
        light_source = 2,
        drawtype = 'nodebox',
        node_box = platform_nodebox,
        selection_box = platform_selbox,
        groups = { antimatter = 2, cracky = 3, explody = 100 },
        paramtype = 'light',
        sunlight_propagates = true,
        walkable = true,
        sounds = sbz_api.sounds.antimatter(),
        on_punch = function(pos, node, puncher)
            core.sound_play('invertedstep', { pos = pos, gain = 1.0 })
        end,
    }
)

do -- Antimatter Platform recipe scope
    local Antimatter_Platform = 'sbz_resources:antimatter_platform'
    local amount = 8
    local AB = 'sbz_resources:antimatter_blob'
    core.register_craft {
        output = Antimatter_Platform .. ' ' .. tostring(amount),
        recipe = {
            { AB, AB },
        }
    }
end

core.register_node('sbz_resources:emitter_imitator', {
    description = S("Emitter Imitator"),
    sounds = {
        footstep = { name = 'mix_gassy_quack_hit', gain = 0.2, pitch = 0.5, fade = 0.0 },
        dig    = { name = 'mix_gassy_quack_hit', gain = 0.4, pitch = 0.8, fade = 0.0 },
        dug      = { name = 'gen_fried_noise_explode', gain = 1.0, pitch = 1.0, fade = 0.0 },
        place    = { name = 'mix_gassy_quack_hit', gain = 1.0, pitch = 1.0, fade = 0.0 },
    },
    tiles = { 'emitter_imitator.png' },
    groups = { matter = 1, explody = 3 },
    paramtype = 'light',
    light_source = 10,
    walkable = true,
    on_punch = function(pos, node, puncher, pointed_thing)
        core.add_particlespawner {
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
            texture = 'star.png',
            glow = 10,
        }
    end,
})

do -- Emitter Imitator recipe scope
    local Emitter_Imitator = 'sbz_resources:emitter_imitator'
    local CD = 'sbz_resources:core_dust'
    local AB = 'sbz_resources:antimatter_blob'
    core.register_craft {
        output = Emitter_Imitator,
        recipe = {
            { '', CD, '' },
            { CD, AB, CD },
            { '', CD, '' },
        }
    }
end

core.register_node(
    'sbz_resources:stone',
    unifieddyes.def {
        description = S("Stone"),
        tiles = { 'stone.png' },
        groups = { matter = 1, moss_growable = 1, charged = 1 },
        walkable = true,
        sounds = sbz_api.sounds.matter(),
    }
)

stairs.register 'sbz_resources:stone'

do -- Stone recipe scope
    local Stone = 'sbz_resources:stone'
    local Pe = 'sbz_resources:pebble'
    core.register_craft {
        output = Stone,
        recipe = {
            { Pe, Pe, Pe },
            { Pe, Pe, Pe },
            { Pe, Pe, Pe },
        }
    }
end

do -- Pebble recipe scope
    local Pebble = 'sbz_resources:pebble'
    local amount = 9
    local St = 'sbz_resources:stone'
    core.register_craft {
        type = 'shapeless',
        output = Pebble .. ' ' .. tostring(amount),
        recipe = {
            St
        },
    }
end

core.register_node('sbz_resources:reinforced_matter', {
    description = S("Reinforced Matter"),
    tiles = { 'reinforced_matter.png' },
    groups = { matter = 1, moss_growable = 1 },
    walkable = true,
    sounds = sbz_api.sounds.matter(),
})

do -- Reinforced Matter recipe scope
    local Reinforced_Matter = 'sbz_resources:reinforced_matter'
    local MP = 'sbz_resources:matter_plate'
    local MB = 'sbz_resources:matter_blob'
    core.register_craft {
        output = Reinforced_Matter,
        recipe = {
            { '', MP, '' },
            { MP, MB, MP },
            { '', MP, '' },
        }
    }
end

core.register_node('sbz_resources:reinforced_antimatter', {
    description = S("Reinforced Antimatter"),
    tiles = { 'reinforced_antimatter.png' },
    groups = { antimatter = 1 },
    light_source = 5,
    walkable = true,
    sounds = sbz_api.sounds.antimatter(),
})

do -- Reinforced Antimatter recipe scope
    local Reinforced_Antimatter = 'sbz_resources:reinforced_antimatter'
    local AP = 'sbz_resources:antimatter_plate'
    local AB = 'sbz_resources:antimatter_blob'
    core.register_craft {
        output = Reinforced_Antimatter,
        recipe = {
            { '', AP, '' },
            { AP, AB, AP },
            { '', AP, '' },
        }
    }
end

if false then -- annoying as hell
    core.register_abm {
        label = 'Annihilate matter and antimatter',
        nodenames = { 'group:matter' },
        neighbors = { 'group:antimatter' },
        interval = 1,
        chance = 1,
        action = function(pos)
            core.add_particlespawner {
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
                texture = 'star.png',
                glow = 10,
            }
            core.remove_node(pos)
            -- copied from sbz_meteorites
            for _ = 1, 100 do
                local raycast = core.raycast(pos, pos + vector.random_direction() * 8, false)
                local wear = 0
                for pointed in raycast do
                    if pointed.type == 'node' then
                        local nodename = core.get_node(pointed.under).name
                        wear = wear
                            + (1 / core.get_item_group(nodename, 'explody'))
                            + core.get_item_group(nodename, 'sbz_machine')
                        --the explody group hence signifies roughly how many such nodes in a straight line it can break before stopping
                        --although this is very random
                        if wear > 1 then break end
                        core.set_node(
                            pointed.under,
                            { name = core.registered_nodes[nodename]._exploded or 'air' }
                        )
                    end
                end
            end
            for _, obj in ipairs(core.get_objects_inside_radius(pos, 8)) do
                if obj:is_player() then
                    local dir = obj:get_pos() - pos
                    obj:add_velocity((vector.normalize(dir) + vector.new(0, 0.5, 0)) * 1.5 * (8 - vector.length(dir)))
                end
            end
        end,
    }
end

core.register_node('sbz_resources:emittrium_glass', {
    description = S("Emittrium Glass"),
    drawtype = 'glasslike_framed_optional',
    tiles = { 'emittrium_glass.png', 'emittrium_glass_shine.png' },
    use_texture_alpha = 'clip',
    paramtype = 'light',
    sunlight_propagates = true,
    groups = { matter = 1, transparent = 1, explody = 100 },
    sounds = sbz_api.sounds.glass(),
})

do -- Emittrium Glass recipe scope
    local Emittrium_Glass = 'sbz_resources:emittrium_glass'
    local amount = 16
    local RE = 'sbz_resources:raw_emittrium'
    local AD = 'sbz_resources:antimatter_dust'
    core.register_craft {
        output = Emittrium_Glass .. ' ' .. tostring(amount),
        recipe = {
            { RE, AD, RE },
            { AD, '', AD },
            { RE, AD, RE },
        },
    }
end

core.register_node(
    'sbz_resources:colorium_glass',
    unifieddyes.def {
        description = S("Colorium Glass"),
        drawtype = 'glasslike_framed_optional',
        tiles = { 'emittrium_glass.png^[colorize:#ffffff:255', 'emittrium_glass_shine.png^[colorize:#ffffff:255' },
        use_texture_alpha = 'clip',
        paramtype = 'light',
        sunlight_propagates = true,
        groups = { matter = 1, transparent = 1, explody = 100, charged = 1 },
        sounds = sbz_api.sounds.glass(),
    }
)

do -- Colorium Glass recipe scope
    local Colorium_Glass = 'sbz_resources:colorium_glass'
    local amount = 8
    local EG = 'sbz_resources:emittrium_glass'
    local Co = 'unifieddyes:colorium'
    core.register_craft {
        output = Colorium_Glass .. ' ' .. tostring(amount),
        recipe = {
            { EG, EG, EG },
            { EG, Co, EG },
            { EG, EG, EG },
        }
    }
end

core.register_node(
    'sbz_resources:clear_colorium_glass',
    unifieddyes.def {
        description = S("Clear Colorium Glass"),
        drawtype = 'glasslike_framed_optional',
        tiles = { 'emittrium_glass_border.png^[colorize:#ffffff:255', 'blank.png' },
        use_texture_alpha = 'clip',
        paramtype = 'light',
        sunlight_propagates = true,
        groups = { matter = 1, transparent = 1, explody = 100, charged = 1 },
        sounds = sbz_api.sounds.glass(),
        info_extra = "Recipe requires cleargrass but it returns it back once you've crafted with it.",
    }
)

do -- Clear Colorium Glass recipe scope
    local Clear_Colorium_Glass = 'sbz_resources:clear_colorium_glass'
    local amount = 8
    local CG = 'sbz_resources:colorium_glass'
    local Cl = 'sbz_bio:cleargrass'
    core.register_craft {
        output = Clear_Colorium_Glass .. ' ' .. tostring(amount),
        recipe = {
            { CG, CG, CG },
            { CG, Cl, CG },
            { CG, CG, CG },
        }
    }
end

core.register_node(
    'sbz_resources:stained_colorium_glass',
    unifieddyes.def {
        description = S("Stained Colorium Glass"),
        drawtype = 'glasslike_framed',
        tiles = { 'emittrium_glass_border.png^[colorize:#ffffff:255', '(blank.png^[invert:rgba^[opacity:150)' },
        inventory_image = core.inventorycube 'stained_glass_inv.png',
        use_texture_alpha = 'blend',
        backface_culling = true,
        paramtype = 'light',
        sunlight_propagates = true,
        groups = { matter = 1, transparent = 1, explody = 100, charged = 1 },
        sounds = sbz_api.sounds.glass(),
        info_extra = { "Recipe requires razorgrass, but it returns it back once you've crafted with it." },
    }
)

do -- Stained Colorium Glass recipe scope
    local Stained_Colorium_Glass = 'sbz_resources:stained_colorium_glass'
    local amount = 8
    local CG = 'sbz_resources:colorium_glass'
    local Ra = 'sbz_bio:razorgrass'
    core.register_craft {
        output = Stained_Colorium_Glass .. ' ' .. tostring(amount),
        recipe = {
            { CG, CG, CG },
            { CG, Ra, CG },
            { CG, CG, CG },
        }
    }
end

core.register_node('sbz_resources:compressed_core_dust', {
    description = S("Compressed Core Dust"),
    tiles = {
        'compressed_core_dust.png',
    },
    groups = { matter = 2, oddly_breakable_by_hand = 1, explody = 10, charged = 1 },
    sounds = sbz_api.sounds.matter(),
})

do -- Compressed Core Dust recipe scope
    local Compressed_Core_Dust = 'sbz_resources:compressed_core_dust'
    local CD = 'sbz_resources:core_dust'
    core.register_craft {
        output = Compressed_Core_Dust,
        recipe = {
            { CD, CD, CD },
            { CD, CD, CD },
            { CD, CD, CD },
        }
    }
end

do -- Core Dust recipe scope
    local Core_Dust = 'sbz_resources:core_dust'
    local amount = 9
    local CC = 'sbz_resources:compressed_core_dust'
    core.register_craft {
        type = 'shapeless',
        output = Core_Dust .. ' ' .. tostring(amount),
        recipe = {
            CC
        },
    }
end

-- sands
core.register_node(
    'sbz_resources:sand',
    unifieddyes.def {
        description = S("Sand"),
        tiles = { 'sand.png' },
        groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, explody = 80 },

        walkable = true,
        sounds = sbz_api.sounds.sand(),
        light_source = 3,
    }
)

core.register_node('sbz_resources:red_sand', {
    description = S("Red Sand"),
    tiles = { 'sand.png^[colorize:red:128' },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, float = 1, explody = 80 },
    walkable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})

core.register_node('sbz_resources:gravel', {
    description = S("Gravel"),
    tiles = { 'gravel.png' },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, explody = 40 },
    walkable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})

core.register_node('sbz_resources:dust', {
    description = S("Dust"),
    info_extra = 'Great for scaffolding (no seriously, you can climb it).\nIt is temporary, it will go away after some time.',
    tiles = { 'dust.png' },
    groups = { matter = 1, charged = 1, sand = 1, explody = 40, soil = 2, oddly_breakable_by_hand = 1 },
    walkable = false,
    climbable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})

core.register_abm {
    label = 'Dust Decay',
    nodenames = { 'sbz_resources:dust' },
    interval = 100,
    chance = 10,
    action = function(pos, node, active_object_count, active_object_count_wider)
        -- field decayed
        core.set_node(pos, { name = 'air' })

        -- plop
        core.sound_play('decay', { pos = pos, gain = 1.0 })

        -- more particles!
        core.add_particlespawner {
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
            texture = 'dust.png',
            glow = 10,
        }
    end,
}

core.register_node('sbz_resources:clay', {
    description = S("Clay"),
    tiles = { 'clay.png' },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, explody = 40 },
    walkable = true,
    sounds = sbz_api.sounds.matter(),
    light_source = 3,
})

core.register_node(
    'sbz_resources:bricks',
    unifieddyes.def {
        description = S("Bricks"),
        tiles = { 'bricks.png' },
        paramtype2 = 'color',
        groups = {
            matter = 1,
            charged = 1,
            sand = 1,
            falling_node = 1,
            explody = 40,
            soil = 2,
            oddly_breakable_by_hand = 1,
        },
        walkable = true,
        sounds = sbz_api.sounds.matter(),
        light_source = 3,
    }
)

core.register_craft {
    type = 'cooking',
    output = 'sbz_resources:bricks',
    recipe = 'sbz_bio:dirt',
}

stairs.register 'sbz_resources:bricks'

core.register_node('sbz_resources:dark_sand', {
    description = S("Dark Sand"),
    tiles = { 'sand.png^[colorizehsl:0:0:-50' },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, float = 0, explody = 80 },

    walkable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})

core.register_node('sbz_resources:black_sand', {
    description = S("Black Sand"),
    tiles = { 'sand.png^[colorizehsl:0:0:-80' },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, float = 1, explody = 80 },

    walkable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})

core.register_node('sbz_resources:white_sand', {
    description = S("White Sand"),
    tiles = { 'sand.png^[colorizehsl:0:0' },
    groups = { matter = 1, charged = 1, sand = 1, falling_node = 1, float = 0, explody = 80 },

    walkable = true,
    sounds = sbz_api.sounds.sand(),
    light_source = 3,
})

do -- Matter Blob recipe scope
    local Matter_Blob = 'sbz_resources:matter_blob'
    local MD = 'sbz_resources:matter_dust'
    core.register_craft {
        output = Matter_Blob,
        recipe = {
            { MD, MD, MD },
            { MD, MD, MD },
            { MD, MD, MD },
        }
    }
end

sbz_api.recipe.register_craft {
    output = 'sbz_resources:matter_dust 9',
    type = 'crushing',
    items = {
        'sbz_resources:matter_blob',
    },
}
