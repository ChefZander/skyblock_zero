local S = core.get_translator(core.get_current_modname())

local modpath = core.get_modpath 'sbz_decor'

core.register_node('sbz_decor:photonlamp', {
    description = S("Photon Lamp"),
    drawtype = 'mesh',
    mesh = 'photonlamp.obj',
    tiles = { 'photonlamp.png' },
    groups = {
        matter = 1,
        habitat_conducts = 1,
    },
    light_source = 14,
    selection_box = {
        type = 'fixed',
        fixed = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
    },
    use_texture_alpha = 'clip',
})
do -- Photon Lamp recipe scope
    local Photon_Lamp = 'sbz_decor:photonlamp'
    local MP = 'sbz_resources:matter_plate'
    local EI = 'sbz_resources:emitter_imitator'
    local MB = 'sbz_resources:matter_blob'
    core.register_craft {
        output = Photon_Lamp,
        recipe = {
            { MP, EI, MP },
            { EI, MB, EI },
            { MP, EI, MP },
        }
    }
end

core.register_node(
    'sbz_decor:factory_floor',
    unifieddyes.def {
        description = S("Factory Floor"),
        tiles = { 'factory_floor.png' },
        groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
        sounds = {
            footstep = { name = 'mix_factory_metal_hit', gain = 0.2, pitch = 1.0, fade = 0.0 },
            dig      = { name = 'mix_metal_hit', gain = 0.7, pitch = 0.6, fade = 0.0 },
            dug      = { name = 'mix_thunk_slightly_metallic', gain = 1.0, pitch = 0.6, fade = 0.0 },
            place    = { name = 'mix_metal_hit', gain = 0.5, pitch = 0.8, fade = 0.0 },
        },
        sunlight_propagates = true,
        walkable = true,
    }
)
core.register_craft {
    output = 'sbz_decor:factory_floor 2',
    type = 'shapeless',
    recipe = {
        'sbz_resources:matter_blob',
        'sbz_resources:matter_blob',
        'sbz_resources:matter_blob',
        'sbz_resources:matter_blob',
    },
}

stairs.register('sbz_decor:factory_floor', {
    stair_front = 'factory_floor_sf.png',
    stair_side = 'factory_floor_ss.png',
    stair_cross = 'factory_floor_sc.png',
})

core.register_node(
    'sbz_decor:factory_floor_tiling',
    unifieddyes.def {
        description = S("Factory Floor (Tiled)"),
        tiles = { 'factory_floor_tiling.png' },
        groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1, ud_param2_colorable = 1 },
        sounds = {
            footstep = { name = 'mix_factory_metal_hit', gain = 0.2, pitch = 1.0, fade = 0.0 },
            dig      = { name = 'mix_metal_hit', gain = 0.7, pitch = 0.6, fade = 0.0 },
            dug      = { name = 'mix_thunk_slightly_metallic', gain = 1.0, pitch = 0.6, fade = 0.0 },
            place    = { name = 'mix_metal_hit', gain = 0.5, pitch = 0.8, fade = 0.0 },
        },
        sunlight_propagates = true,
        walkable = true,
    }
)

stairs.register 'sbz_decor:factory_floor_tiling'

core.register_craft {
    output = 'sbz_decor:factory_floor_tiling 4',
    type = 'shapeless',
    recipe = {
        'sbz_decor:factory_floor',
        'sbz_decor:factory_floor',
        'sbz_decor:factory_floor',
        'sbz_decor:factory_floor',
    },
}

core.register_node('sbz_decor:factory_ventilator', {
    description = S("Factory Ventilator"),
    tiles = {
        { name = 'factory_ventilator.png', animation = { type = 'vertical_frames', length = 1 } },
    },
    groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
    sounds = {
        footstep = { name = 'mix_factory_metal_hit', gain = 0.2, pitch = 1.0, fade = 0.0 },
        dig      = { name = 'mix_metal_hit', gain = 0.7, pitch = 0.6, fade = 0.0 },
        dug      = { name = 'mix_thunk_slightly_metallic', gain = 1.0, pitch = 0.6, fade = 0.0 },
        place    = { name = 'mix_metal_hit', gain = 0.5, pitch = 0.8, fade = 0.0 },
    },
    on_construct = function(pos)
        local meta = core.get_meta(pos)

        local handle = core.sound_play({ name = "foley_bathroom_fan_loop", fade = 0.5 }, {
            pos = pos,
            gain = 0.2,
            pitch = 0.8,
            max_hear_distance = 16,
            loop = true
        })

        meta:set_int("factory_fan_handle", handle)
    end,
    on_destruct = function(pos)
        local meta = core.get_meta(pos)
        local handle = meta:get_int("factory_fan_handle")

        if handle then
            core.sound_stop(handle)
        end
    end,

    sunlight_propagates = true,
    walkable = true,
})
core.register_craft {
    output = 'sbz_decor:factory_ventilator',
    type = 'shapeless',
    recipe = {
        'sbz_decor:factory_floor',
        'sbz_decor:factory_floor',
        'sbz_chem:lithium_powder',
        'sbz_chem:cobalt_powder',
    },
}

core.register_node(
    'sbz_decor:factory_warning',
    unifieddyes.def {
        description = S("Factory Warning"),
        tiles = { 'factory_warning.png' },
        groups = { matter = 1, cracky = 3, explody = 3, moss_growable = 1 },
        sunlight_propagates = true,
        walkable = true,
        sounds = sbz_api.sounds.matter(),
    }
)
stairs.register 'sbz_decor:factory_warning'
core.register_craft {
    output = 'sbz_decor:factory_warning 4',
    type = 'shapeless',
    recipe = { 'sbz_decor:factory_floor', 'sbz_decor:factory_floor', 'sbz_chem:gold_powder', 'sbz_chem:gold_powder' },
}

core.register_node('sbz_decor:mystery_terrarium', {
    description = S("Mystery Terrarium"),
    tiles = {
        { name = 'mystery_terrarium.png', animation = { type = 'vertical_frames', length = 1 } },
    },
    groups = { matter = 1, cracky = 3, explody = 3 },
    sunlight_propagates = true,
    walkable = true,
    sounds = sbz_api.sounds.matter(),
})
core.register_craft {
    output = 'sbz_decor:mystery_terrarium',
    type = 'shapeless',
    recipe = { 'sbz_bio:habitat_regulator', 'sbz_bio:screen_inverter_potion', 'sbz_chem:thorium_powder' },
}

core.register_node(
    'sbz_decor:large_server_rack',
    unifieddyes.def {
        description = S("Large Server Rack"),
        info_extra = 'Just decoration.',
        tiles = {
            { name = 'large_server_rack_back.png' },
            { name = 'large_server_rack_back.png' },
            { name = 'large_server_rack.png', animation = { type = 'vertical_frames', length = 3 } },
            { name = 'large_server_rack_back.png' },
            { name = 'large_server_rack_back.png' },
            { name = 'large_server_rack_back.png' },
        },
        paramtype2 = 'colorfacedir',
        groups = { matter = 1, cracky = 3, explody = 3 },
        light_source = 10,
        sunlight_propagates = true,
        sounds = sbz_api.sounds.matter(),
    }
)

core.register_craft {
    output = 'sbz_decor:large_server_rack',
    type = 'shapeless',
    recipe = { 'sbz_resources:matter_blob', 'sbz_resources:luanium' },
}

local MP = core.get_modpath 'sbz_decor'
dofile(MP .. '/signs.lua')
dofile(MP .. '/cnc.lua')

-- now... Ladders
-- inspired by what i saw from mtg ladders
local ladder_autoplace_limit = 16

local get_ladder_on_place = function(ladder_name)
    return sbz_api.on_place_precedence(function(stack, placer, pointed, recursed)
        if (recursed or 0) > ladder_autoplace_limit then return end
        if pointed.type == 'node' then
            local target = pointed.under
            local node = core.get_node(target)
            if node.name == ladder_name then
                local dir = core.facedir_to_dir(node.param2)
                local up = vector.new(0, 1, 0)
                pointed.under = vector.add(pointed.under, up)
                pointed.above = vector.add(pointed.above, up)
                if core.get_node(pointed.under).name == ladder_name then
                    local result =
                        core.registered_nodes[ladder_name].on_place(stack, placer, pointed, (recursed or 0) + 1)
                    return result
                end
                return core.item_place_node(stack, placer, pointed, node.param2)
            end
        end
        return core.item_place_node(stack, placer, pointed)
    end)
end

core.register_node(
    'sbz_decor:ladder',
    unifieddyes.def {
        description = S("Matter Ladder"),
        sounds = sbz_api.sounds.matter(),
        drawtype = 'nodebox',
        node_box = { -- nodebox inspired by that one 3d ladders mod, but i made this myself with nodebox editor
            type = 'fixed',
            fixed = {
                { -0.5, -0.5, 0.375, -0.375, 0.5, 0.5 }, -- NodeBox1
                { 0.375, -0.5, 0.375, 0.5, 0.5, 0.5 }, -- NodeBox3
                { -0.375, 0.3125, 0.375, 0.375, 0.4375, 0.5 }, -- NodeBox5
                { -0.375, 0.0625, 0.375, 0.375, 0.1875, 0.5 }, -- NodeBox8
                { -0.375, -0.1875, 0.375, 0.375, -0.0625, 0.5 }, -- NodeBox9
                { -0.375, -0.4375, 0.375, 0.375, -0.3125, 0.5 }, -- NodeBox10
            },
        },
        selection_box = {
            type = 'fixed',
            fixed = {
                -8 / 16,
                -8 / 16,
                3 / 16,
                8 / 16,
                8 / 16,
                8 / 16,
            },
        },
        tiles = { 'matter_blob.png' },
        inventory_image = 'ladder.png',
        groups = {
            matter = 3,
            explody = 3,
            habitat_conducts = 1,
        },
        paramtype = 'light',
        paramtype2 = 'facedir',
        sunlight_propagates = true,
        on_place = get_ladder_on_place 'sbz_decor:ladder',
        node_placement_prediction = '',
        climbable = true,
    }
)

core.register_node(
    'sbz_decor:antimatter_ladder',
    unifieddyes.def {
        description = S("Antimatter Ladder"),
        sounds = sbz_api.sounds.antimatter(),
        drawtype = 'nodebox',
        node_box = { -- nodebox inspired by that one 3d ladders mod, but i made this myself with nodebox editor
            type = 'fixed',
            fixed = {
                { -0.5, -0.5, 0.375, -0.375, 0.5, 0.5 }, -- NodeBox1
                { 0.375, -0.5, 0.375, 0.5, 0.5, 0.5 }, -- NodeBox3
                { -0.375, 0.3125, 0.375, 0.375, 0.4375, 0.5 }, -- NodeBox5
                { -0.375, 0.0625, 0.375, 0.375, 0.1875, 0.5 }, -- NodeBox8
                { -0.375, -0.1875, 0.375, 0.375, -0.0625, 0.5 }, -- NodeBox9
                { -0.375, -0.4375, 0.375, 0.375, -0.3125, 0.5 }, -- NodeBox10
            },
        },
        selection_box = {
            type = 'fixed',
            fixed = {
                -8 / 16,
                -8 / 16,
                3 / 16,
                8 / 16,
                8 / 16,
                8 / 16,
            },
        },
        tiles = { 'antimatter_blob.png' },
        inventory_image = 'antimatter_ladder.png',
        groups = {
            matter = 3,
            explody = 3,
            habitat_conducts = 1,
        },
        light_source = 3,
        paramtype = 'light',
        paramtype2 = 'colorfacedir', --"facedir",
        sunlight_propagates = true,
        on_place = get_ladder_on_place 'sbz_decor:antimatter_ladder',
        node_placement_prediction = '',
        climbable = true,
    }
)

core.register_alias_force('sbz_decor:anitmatter_ladder', 'sbz_decor:antimatter_ladder')

do -- Antimatter Ladder recipe scope
    local Antimatter_Ladder = 'sbz_decor:antimatter_ladder'
    local amount = 12
    local AB = 'sbz_resources:antimatter_blob'
    core.register_craft {
        output = Antimatter_Ladder .. ' ' .. tostring(amount),
        recipe = {
            { AB, '', AB },
            { AB, AB, AB },
            { AB, '', AB },
        }
    }
end

do -- Ladder recipe scope
    local Ladder = 'sbz_decor:ladder'
    local amount = 12
    local MB = 'sbz_resources:matter_blob'
    core.register_craft {
        output = Ladder .. ' ' .. tostring(amount),
        recipe = {
            { MB, '', MB },
            { MB, MB, MB },
            { MB, '', MB },
        }
    }
end
