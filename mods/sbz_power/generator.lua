local core_dust_power = 30
local charged_particle_power = 36
-- 30*10 => 300 power per core dust
-- 36*10 => 360 power per charged particle
sbz_api.register_stateful_generator('sbz_power:simple_charge_generator', {
    description = 'Simple Charge Generator',
    tiles = { 'simple_charge_generator_off.png' },

    groups = { dig_immediate = 2, sbz_machine = 1, pipe_connects = 1 },
    sunlight_propagates = true,
    walkable = true,

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
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

        minetest.add_particlespawner {
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

minetest.register_craft {
    output = 'sbz_power:simple_charge_generator',
    recipe = {
        { 'sbz_power:simple_charged_field', 'sbz_resources:antimatter_dust', 'sbz_power:simple_charged_field' },
        { 'sbz_resources:matter_blob', 'sbz_resources:matter_annihilator', 'sbz_resources:matter_blob' },
        { 'sbz_power:simple_charged_field', 'sbz_resources:matter_blob', 'sbz_power:simple_charged_field' },
    },
}

sbz_api.register_generator('sbz_power:simple_charged_field', {
    description = 'Simple Charged Field',
    drawtype = 'glasslike',
    tiles = { 'simple_charged_field.png' },
    groups = { dig_immediate = 2, cracky = 3, sbz_machine = 1, explody = 5, charged = 1, charged_field = 1 },
    sunlight_propagates = true,
    paramtype = 'light',
    walkable = false,
    power_generated = 3,
    on_dig = function(pos, node, digger)
        minetest.sound_play('charged_field_shutdown', {
            gain = 5.0,
            max_hear_distance = 32,
            pos = pos,
        })
        minetest.node_dig(pos, node, digger)
    end,
    info_extra = 'Decays after some time',
})

minetest.register_craft {
    output = 'sbz_power:simple_charged_field',
    recipe = {
        { 'sbz_resources:charged_particle', 'sbz_resources:charged_particle', 'sbz_resources:charged_particle' },
        { 'sbz_resources:charged_particle', 'sbz_resources:charged_particle', 'sbz_resources:charged_particle' },
        { 'sbz_resources:charged_particle', 'sbz_resources:charged_particle', 'sbz_resources:charged_particle' },
    },
}

if not sbz_api.server_optimizations then
    minetest.register_abm {
        label = 'Simple Charged Field Particles',
        nodenames = { 'sbz_power:simple_charged_field' },
        interval = 1,
        chance = 1,
        action = function(pos, node, active_object_count, active_object_count_wider)
            minetest.add_particlespawner {
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

minetest.register_abm {
    label = 'Simple Charged Field Decay',
    nodenames = { 'sbz_power:simple_charged_field' },
    interval = 100,
    chance = 10,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.after(1, function()
            -- field decayed
            minetest.set_node(pos, { name = 'sbz_power:charged_field_residue' })

            -- plop
            minetest.sound_play('decay', { pos = pos, gain = 1.0 })

            -- more particles!
            minetest.add_particlespawner {
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

minetest.register_node('sbz_power:charged_field_residue', {
    description = 'Charged Field Residue',
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
minetest.register_abm {
    label = 'Charged Field Residue Decay',
    nodenames = { 'sbz_power:charged_field_residue' },
    interval = 100,
    chance = 10,
    action = function(pos, node, active_object_count, active_object_count_wider)
        -- residue decayed
        minetest.set_node(pos, { name = 'air' })

        -- plop, again
        minetest.sound_play('decay', { pos = pos, gain = 1.0 })
    end,
}

core.register_node('sbz_power:solid_charged_field', {
    description = 'Solid Charged Field',
    info_extra = 'Used for protecting against radiation.',
    tiles = { 'solid_charged_field.png' },
    groups = { dig_immediate = 2, matter = 1, explody = 5, charged = 1, charged_field = 1 },
    sunlight_propagates = true,
    on_dig = function(pos, node, digger)
        minetest.sound_play('charged_field_shutdown', {
            gain = 5.0,
            max_hear_distance = 32,
            pos = pos,
        })
        minetest.node_dig(pos, node, digger)
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
        local r = math.random(0, 2)
        if r == 1 then return 1 end
        return 0
    end,
    info_extra = 'Has a 1/3 Chance/Second to produce 1 power.',
})

minetest.register_craft {
    output = 'sbz_power:starlight_collector',
    recipe = {
        { 'sbz_resources:raw_emittrium', 'sbz_resources:raw_emittrium', 'sbz_resources:raw_emittrium' },
        { 'sbz_power:power_pipe', 'sbz_power:power_pipe', 'sbz_power:power_pipe' },
        { 'sbz_resources:matter_blob', 'sbz_resources:matter_blob', 'sbz_resources:matter_blob' },
    },
}
if not sbz_api.server_optimizations then
    minetest.register_abm {
        label = 'Starlight Collector Particles',
        nodenames = { 'sbz_power:starlight_collector' },
        interval = 1,
        chance = 0.5,
        action = function(pos, node, active_object_count, active_object_count_wider)
            minetest.add_particlespawner {
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

sbz_api.register_stateful_generator('sbz_power:antimatter_generator', {
    description = 'Antimatter Generator',
    info_extra = {
        'Generates 600 power',
        'Needs 1 antimatter/s and 1 matter/s',
    },
    groups = { matter = 1, pipe_connects = 1, disallow_pipeworks = 1, tubedevice = 1, tubedevice_receiver = 1 },
    tiles = {
        'antimatter_gen_top.png',
        'antimatter_gen_top.png',
        'antimatter_gen_side.png',
    },
    input_inv = 'input',
    output_inv = 'input',
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()

        inv:set_size('antimatter', 1)
        inv:set_size('matter', 1)

        meta:set_string(
            'formspec',
            [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]

item_image[1.4,1.9;1,1;sbz_resources:matter_dust]
list[context;matter;1.5,2;1,1;]

item_image[5.7,1.9;1,1;sbz_resources:antimatter_dust]
list[context;antimatter;5.8,2;1,1;]

list[current_player;main;0.2,5;8,4;]
]]
        )
    end,

    autostate = true,
    action = function(pos, node, meta, supply, demand)
        local inv = meta:get_inventory()

        if
            inv:contains_item('matter', 'sbz_resources:matter_dust')
            and inv:contains_item('antimatter', 'sbz_resources:antimatter_dust')
        then
            inv:remove_item('matter', 'sbz_resources:matter_dust')
            inv:remove_item('antimatter', 'sbz_resources:antimatter_dust')
            meta:set_string('infotext', 'Running')
            local def = {
                amount = 25,
                time = 1,
                collisiondetection = false,
                vertical = false,
                glow = 14,
                size = 3,
                pos = pos,
                vel = { min = -vector.new(5, 5, 5), max = vector.new(5, 5, 5) },
                exptime = 3,
            }
            def.texture = 'antimatter_dust.png'
            minetest.add_particlespawner(def)

            def.texture = 'matter_dust.png'
            minetest.add_particlespawner(def)
            return 600
        end

        meta:set_string('infotext', "Can't react")
        return 0
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        local stackname = (minetest.get_inventory { type = 'player', name = player:get_player_name() })
            :get_stack(from_list, from_index)
            :get_name()

        if to_list == 'matter' then
            if stackname == 'sbz_resources:matter_dust' then
                return count
            else
                return 0
            end
        elseif to_list == 'antimatter' then
            if stackname == 'sbz_resources:antimatter_dust' then
                return count
            else
                return 0
            end
        end
        return count
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local stackname = stack:get_name()
        local count = stack:get_count()
        if listname == 'antimatter' then
            if stackname == 'sbz_resources:antimatter_dust' then
                return count
            else
                return 0
            end
        elseif listname == 'matter' then
            if stackname == 'sbz_resources:matter_dust' then
                return count
            else
                return 0
            end
        end
        return stack:get_count()
    end,
    tube = {
        insert_object = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local stackname = stack:get_name()
            if stackname == 'sbz_resources:antimatter_dust' then
                return inv:add_item('antimatter', stack)
            elseif stackname == 'sbz_resources:matter_dust' then
                return inv:add_item('matter', stack)
            end
            return stack
        end,
        can_insert = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            stack = stack:peek_item(10) --if can insert 10, then yeah... because 1 results in a mess
            local stackname = stack:get_name()
            if stackname == 'sbz_resources:matter_dust' then
                return inv:room_for_item('matter', stack)
            elseif stackname == 'sbz_resources:antimatter_dust' then
                return inv:room_for_item('antimatter', stack)
            end
            return false
        end,
        connect_sides = { left = 1, right = 1, back = 1, front = 1, top = 1, bottom = 1 },
    },
}, {
    tiles = {
        'antimatter_gen_top.png',
        'antimatter_gen_top.png',
        {
            name = 'antimatter_gen_side_on.png',
            animation = { type = 'vertical_frames', aspect_w = 16, aspect_h = 16, length = 1.0 },
        },
    },
    light_source = 14,
})

core.register_lbm {
    label = 'Upgrade legacy antimatter generator',
    name = 'sbz_power:antimatter_generator_upgrade_v1',
    nodenames = { 'sbz_power:antimatter_generator' },
    action = function(pos, node, dtime_s)
        local meta = core.get_meta(pos)

        meta:set_string(
            'formspec',
            [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]

item_image[1.4,1.9;1,1;sbz_resources:matter_dust]
list[context;matter;1.5,2;1,1;]

item_image[5.7,1.9;1,1;sbz_resources:antimatter_dust]
list[context;antimatter;5.8,2;1,1;]

list[current_player;main;0.2,5;8,4;]
]]
        )
        local inv = meta:get_inventory()

        inv:set_size('antimatter', 1)
        inv:set_size('matter', 1)
    end,
}

minetest.register_craft {
    output = 'sbz_power:antimatter_generator',
    recipe = {
        { 'sbz_resources:reinforced_matter', 'sbz_resources:reinforced_matter', 'sbz_resources:reinforced_matter' },
        { 'sbz_resources:matter_dust', 'sbz_meteorites:neutronium', 'sbz_resources:antimatter_dust' },
        { 'sbz_resources:reinforced_matter', 'sbz_resources:reinforced_matter', 'sbz_resources:reinforced_matter' },
    },
}

sbz_api.register_generator('sbz_power:creative_generator', {
    description = 'Creative Generator',
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
