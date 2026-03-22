--
-- Per-generator, per-player sound tracking.
--
-- active_generators: set of position hashes for generators currently running.
-- sounds: map of (pos_key .. "_" .. player_name) -> sound handle.
-- fading_out: map of (pos_key .. "_" .. player_name) -> sound handle currently
--             fading out, pending cleanup on the next cycle.
--
local active_generators = {}
local sounds = {}
local fading_out = {}

local HEAR_RADIUS = 16 -- nodes, true sphere
local CYCLE = 1        -- seconds between per-player distance checks

local function sound_key(pos_key, player_name)
    return pos_key .. '_' .. player_name
end

local function set_generator_active(pos, is_active)
    local key = core.hash_node_position(pos)
    if is_active then
        active_generators[key] = pos
    else
        -- Fade out sound for all players currently hearing this generator.
        for _, player in ipairs(core.get_connected_players()) do
            local player_name = player:get_player_name()
            local sk = sound_key(key, player_name)
            if sounds[sk] then
                core.sound_fade(sounds[sk], -1.2, 0.0)
                fading_out[sk] = sounds[sk]
                sounds[sk] = nil
            end
        end
        active_generators[key] = nil
    end
end

-- Update sounds for a single player across all active generators.
local function update_player_sound(player)
    local player_name = player:get_player_name()
    local ppos = player:get_pos()

    for key, gpos in pairs(active_generators) do
        local sk = sound_key(key, player_name)

        -- Clean up any completed fade-out from the previous cycle.
        if fading_out[sk] then
            core.sound_stop(fading_out[sk])
            fading_out[sk] = nil
        end

        local in_range = vector.distance(ppos, gpos) <= HEAR_RADIUS

        if sounds[sk] then
            -- Sound already playing: fade out if player has left range.
            if not in_range then
                core.sound_fade(sounds[sk], -1.2, 0.0)
                fading_out[sk] = sounds[sk]
                sounds[sk] = nil
            end
        elseif in_range then
            -- Player has entered range: start sound with fade-in.
            local handle = core.sound_play(
                { name = 'mix_hum_click_loop', pitch = 2.0, gain = 0.8, fade = 0.5 },
                {
                    pos = gpos,
                    to_player = player_name,
                    max_hear_distance = HEAR_RADIUS,
                    loop = true,
                }
            )
            if handle then
                sounds[sk] = handle
            end
        end
    end
end

-- Globalstep cycle.
local timer = 0
core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < CYCLE then
        return
    end
    timer = 0
    for _, player in ipairs(core.get_connected_players()) do
        update_player_sound(player)
    end
end)

-- Stop and clean up all sounds for a player when they leave.
core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    for key, _ in pairs(active_generators) do
        local sk = sound_key(key, player_name)
        if sounds[sk] then
            core.sound_stop(sounds[sk])
            sounds[sk] = nil
        end
        if fading_out[sk] then
            core.sound_stop(fading_out[sk])
            fading_out[sk] = nil
        end
    end
end)


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
    sounds = sbz_audio.machine(),
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

            set_generator_active(pos, true)

            def.texture = 'antimatter_dust.png'
            core.add_particlespawner(def)

            def.texture = 'matter_dust.png'
            core.add_particlespawner(def)
            return 600
        end

        meta:set_string('infotext', "Can't react")
        set_generator_active(pos, false)
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
    on_destruct = function(pos)
        set_generator_active(pos, false)
    end,
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
