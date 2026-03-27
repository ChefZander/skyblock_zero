local S = core.get_translator(core.get_current_modname())

local core_dust_power = 30
local charged_particle_power = 36
-- 30*10 => 300 power per core dust
-- 36*10 => 360 power per charged particle
sbz_api.register_stateful_generator('sbz_power:simple_charge_generator', {
    description = 'Simple Charge Generator',
    sounds = sbz_api.sounds.machine(),
    tiles = { 'simple_charge_generator_off.png' },

    groups = { dig_immediate = 2, sbz_machine = 1, pipe_connects = 1 },
    sunlight_propagates = true,
    walkable = true,

    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size('main', 1)
        meta:set_string(
            'formspec',
            [[
        formspec_version[7]
        size[8.2,9]
        style_type[list;spacing=.2;size=.8]
        item_image[3.45,1.95;0.9,0.9;sbz_resources:charged_particle]
        list[context;main;3.5,2;1,1;]
        list[current_player;main;0.2,5;8,4;]
        listring[]
             ]]
        )
    end,
    action_interval = 10,
    action = function(pos, node, meta)
        local inv = meta:get_inventory()
        -- check if fuel is there
        if
            not (
                inv:contains_item('main', 'sbz_resources:core_dust')
                or inv:contains_item('main', 'sbz_resources:charged_particle')
            )
        then
            core.add_particlespawner {
                amount = 10,
                time = 1,
                minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                minvel = { x = -0.5, y = -0.5, z = -0.5 },
                maxvel = { x = 0.5, y = 0.5, z = 0.5 },
                minacc = { x = 0, y = 0, z = 0 },
                maxacc = { x = 0, y = 0, z = 0 },
                minexptime = 5,
                maxexptime = 10,
                minsize = 0.5,
                maxsize = 1.0,
                collisiondetection = false,
                vertical = false,
                texture = 'error_particle.png',
                glow = 10,
            }
            meta:set_string('infotext', 'Stopped')
            return 0, true
        end

        local stack = inv:get_stack('main', 1)
        local fuel_name = stack:get_name()
        if stack:is_empty() then
            meta:set_string('infotext', 'Stopped')
            return 0, true
        end

        stack:take_item(1)
        inv:set_stack('main', 1, stack)

        core.add_particlespawner {
            amount = 25,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
            minvel = { x = 0, y = 5, z = 0 },
            maxvel = { x = 0, y = 5, z = 0 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 1,
            maxexptime = 3,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = false,
            vertical = false,
            texture = 'charged_particle.png',
            glow = 10,
        }
        meta:set_string('infotext', 'Running')
        return fuel_name == 'sbz_resources:core_dust' and core_dust_power or charged_particle_power, false
    end,
    input_inv = 'main',
    output_inv = 'main',
    info_generated = 30,
    info_extra = { 'Consumes 1 core dust every 10 seconds' },
    autostate = true,
}, {
    light_source = 14,
    tiles = { 'simple_charge_generator.png' },
})

do -- Simple Charge Generator recipe scope
    local Simple_Charge_Generator = 'sbz_power:simple_charge_generator'
    local CF = 'sbz_power:simple_charged_field'
    local AD = 'sbz_resources:antimatter_dust'
    local MB = 'sbz_resources:matter_blob'
    local MA = 'sbz_resources:matter_annihilator'
    core.register_craft({
        output = Simple_Charge_Generator,
        recipe = {
            { CF, AD, CF },
            { MB, MA, MB },
            { CF, MB, CF },
        },
    })
end

sbz_api.register_generator('sbz_power:simple_charged_field', {
    description = S("Simple Charged Field"),
    drawtype = 'glasslike',
    tiles = { 'simple_charged_field.png' },
    groups = { dig_immediate = 2, cracky = 3, sbz_machine = 1, explody = 5, charged = 1, charged_field = 1 },
    sounds = {
        footstep = { name = 'gen_zap_short', gain = 1.0, pitch = 1.0, fade = 0.0 },
        dig      = { name = 'gen_simple_charged_field_placement_zap', gain = 0.3, pitch = 0.2, fade = 0.0 },
        dug      = { name = 'gen_simple_charged_field_dug', gain = 1.0, pitch = 1.0, fade = 0.0 },
        place    = { name = 'gen_simple_charged_field_placement_zap', gain = 1.0, pitch = 1.0, fade = 0.0 },
    },
    sunlight_propagates = true,
    paramtype = 'light',
    walkable = false,
    power_generated = 3,
    on_dig = function(pos, node, digger)
        core.sound_play('charged_field_shutdown', {
            gain = 5.0,
            max_hear_distance = 32,
            pos = pos,
        })
        core.node_dig(pos, node, digger)
    end,
    info_extra = 'Decays after some time',
})

do -- Simple Charged Field recipe scope
    local Simple_Charged_Field = 'sbz_power:simple_charged_field'
    local CP = 'sbz_resources:charged_particle'
    core.register_craft({
        output = Simple_Charged_Field,
        recipe = {
            { CP, CP, CP },
            { CP, CP, CP },
            { CP, CP, CP },
        },
    })
end

do -- Charged Particle recipe scope
    local Charged_Particle = 'sbz_resources:charged_particle'
    local amount = 9
    local CF = 'sbz_power:simple_charged_field'
    core.register_craft({
        type = 'shapeless',
        output = Charged_Particle .. ' ' .. tostring(amount),
        recipe = { CF },
    })
end

if not sbz_api.server_optimizations then
    core.register_abm {
        label = 'Simple Charged Field Particles',
        nodenames = { 'sbz_power:simple_charged_field' },
        interval = 1,
        chance = 1,
        action = function(pos, node, active_object_count, active_object_count_wider)
            core.add_particlespawner {
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
                texture = 'charged_particle.png',
                glow = 10,
            }
        end,
    }
end

core.register_abm {
    label = 'Simple Charged Field Decay',
    nodenames = { 'sbz_power:simple_charged_field' },
    interval = 100,
    chance = 10,
    action = function(pos, node, active_object_count, active_object_count_wider)
        core.after(1, function()
            -- field decayed
            core.set_node(pos, { name = 'sbz_power:charged_field_residue' })

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
                texture = 'charged_particle.png',
                glow = 10,
            }
        end)
    end,
}

core.register_node('sbz_power:charged_field_residue', {
    description = S("Charged Field Residue"),
    drawtype = 'glasslike',
    tiles = { 'charged_field_residue.png' },
    groups = { unbreakable = 1, charged_field = 1 },
    sunlight_propagates = true,
    diggable = false,
    drop = '',
    paramtype = 'light',
    walkable = true,
    on_punch = function(pos, node, puncher, pointed_thing)
        if puncher.is_fake_player then return end
        sbz_api.displayDialogLine(puncher:get_player_name(), 'The residue is still decaying.')
    end,
})
core.register_abm {
    label = 'Charged Field Residue Decay',
    nodenames = { 'sbz_power:charged_field_residue' },
    interval = 100,
    chance = 10,
    action = function(pos, node, active_object_count, active_object_count_wider)
        -- residue decayed
        core.set_node(pos, { name = 'air' })

        -- plop, again
        core.sound_play('decay', { pos = pos, gain = 1.0 })
    end,
}

core.register_node('sbz_power:solid_charged_field', {
    description = S("Solid Charged Field"),
    info_extra = 'Used for protecting against radiation.',
    tiles = { 'solid_charged_field.png' },
    groups = { dig_immediate = 2, matter = 1, explody = 5, charged = 1, charged_field = 1 },
    sunlight_propagates = true,
    on_dig = function(pos, node, digger)
        core.sound_play('charged_field_shutdown', {
            gain = 5.0,
            max_hear_distance = 32,
            pos = pos,
        })
        core.node_dig(pos, node, digger)
    end,
})

sbz_api.recipe.register_craft {
    type = 'compressing',
    output = 'sbz_power:solid_charged_field',
    items = { 'sbz_power:simple_charged_field 9' },
}

-- Starlight Collector
sbz_api.register_generator('sbz_power:starlight_collector', {
    description = 'Starlight Collector',
    sounds = sbz_api.sounds.matter(),
    drawtype = 'nodebox',
    tiles = {
        'starlight_collector.png',
        'matter_blob.png',
        'matter_blob.png',
        'matter_blob.png',
        'matter_blob.png',
        'matter_blob.png',
    },
    groups = { matter = 1, pipe_connects = 1, network_always_found = 1 },
    sunlight_propagates = true,
    walkable = true,
    node_box = {
        type = 'fixed',
        fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
    },
    paramtype = 'light',
    use_texture_alpha = 'clip',
    action_interval = 1,
    action = function(pos, node, meta)
        meta:set_string('infotext', '')
        local r = math.random(0, 2)
        if r == 1 then return 1 end
        return 0
    end,
    info_extra = 'Has a 1/3 Chance/Second to produce 1 power.',
})

do -- Starlight Collector recipe scope
    local Starlight_Collector = 'sbz_power:starlight_collector'
    local RE = 'sbz_resources:raw_emittrium'
    local PC = 'sbz_power:power_pipe' -- ("Emittrium Power Cable" in-game)
    local MB = 'sbz_resources:matter_blob'
    core.register_craft({
        output = Starlight_Collector,
        recipe = {
            { RE, RE, RE },
            { PC, PC, PC },
            { MB, MB, MB },
        },
    })
end

if not sbz_api.server_optimizations then
    core.register_abm {
        label = 'Starlight Collector Particles',
        nodenames = { 'sbz_power:starlight_collector' },
        interval = 1,
        chance = 0.5,
        action = function(pos, node, active_object_count, active_object_count_wider)
            core.add_particlespawner {
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
                texture = 'star.png',
                glow = 10,
            }
        end,
    }
end

sbz_api.register_generator('sbz_power:creative_generator', {
    description = 'Creative Generator',
    sounds = sbz_audio.machine(),
    tiles = {
        {
            name = 'creative_battery_power_gen.png^[colorize:purple:100',
            animation = { type = 'vertical_frames', length = 0.5 },
        },
    },
    groups = { creative = 1, matter = 1 },
    power_generated = 10 ^ 9,
    disable_pipeworks = true,
})
