local antimatter_generator_active_sounds = {}

local function start_antimatter_generator_active_sound(pos)
    local key = core.hash_node_position(pos)

    -- If already playing
    if antimatter_generator_active_sounds[key] then
        return
    end

    local handle = core.sound_play(
        { name = 'mix_hum_click_loop', pitch = 2.0, gain = 0.7 },
        {
            pos = pos,
            gain = 0.0, -- start silent to allow fade-in
            max_hear_distance = 8.0,
            loop = true,
        }
    )

    if handle then
        antimatter_generator_active_sounds[key] = handle
        core.sound_fade(handle, 0.5, 0.8)
    end
end

local function stop_antimatter_generator_active_sound(pos)
    local key = core.hash_node_position(pos)
    local handle = antimatter_generator_active_sounds[key]

    if not handle then
        return
    end

    core.sound_fade(handle, -1.2, 0)

    -- Stop sound after fade finishes
    core.after(1.0, function()
        core.sound_stop(handle)
    end)

    antimatter_generator_active_sounds[key] = nil
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
    sounds = sbz_api.sounds.machine(),
    input_inv = 'input',
    output_inv = 'input',
    on_construct = function(pos)
        local meta = core.get_meta(pos)
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

            start_antimatter_generator_active_sound(pos)

            def.texture = 'antimatter_dust.png'
            core.add_particlespawner(def)

            def.texture = 'matter_dust.png'
            core.add_particlespawner(def)
            return 600
        end

        meta:set_string('infotext', "Can't react")
        stop_antimatter_generator_active_sound(pos)
        return 0
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        local stackname = (core.get_inventory { type = 'player', name = player:get_player_name() })
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
            local meta = core.get_meta(pos)
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
            local meta = core.get_meta(pos)
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

do -- Antimatter Generator recipe scope
    local Antimatter_Generator = 'sbz_power:antimatter_generator'
    local RM = 'sbz_resources:reinforced_matter'
    local MD = 'sbz_resources:matter_dust'
    local Ne = 'sbz_meteorites:neutronium'
    local AD = 'sbz_resources:antimatter_dust'
    core.register_craft({
        output = Antimatter_Generator,
        recipe = {
            { RM, RM, RM },
            { MD, Ne, AD },
            { RM, RM, RM },
        },
    })
end
