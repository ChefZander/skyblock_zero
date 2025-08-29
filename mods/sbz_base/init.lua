-- Oh yeah, i forgot
---@diagnostic disable-next-line: lowercase-global
sbz_api = {
    version = 38,
    is_version_dev = true,
    gravity = 9.8 / 2,
    server_optimizations = (core.settings:get 'sbz_server_mode' or 'auto'),
    deg2rad = math.pi / 180,
    rad2deg = 180 / math.pi,
    enable_switching_station_globalstep = true,
    spawn_zone = core.settings:get 'spawn_zone_range' or 300,
    is_in_spawn_zone = function(pos) -- you can override
        -- check bounds
        local a = math.abs
        if a(pos.x) <= sbz_api.spawn_zone and a(pos.y) <= sbz_api.spawn_zone and a(pos.z) <= sbz_api.spawn_zone then
            return true
        end
        return false
    end,
    accelerated_habitats = false,
    debug = minetest.settings:get_bool('sbz_debug', false),
    logic_gate_linking_range = 15,
}

if sbz_api.server_optimizations == 'auto' then
    sbz_api.server_optimizations = not core.is_singleplayer()
elseif sbz_api.server_optimizations == 'on' then
    sbz_api.server_optimizations = true
elseif sbz_api.server_optimizations == 'off' then
    sbz_api.server_optimizations = false
end

-- Generated with figlet
print(([[
%s[0;32m
 ____  _          _     _            _        _____
/ ___|| | ___   _| |__ | | ___   ___| | ___  |__  /___ _ __ ___
\___ \| |/ / | | | '_ \| |/ _ \ / __| |/ (_)   / // _ \ '__/ _ \
 ___) |   <| |_| | |_) | | (_) | (__|   < _   / /|  __/ | | (_) |
|____/|_|\_\\__, |_.__/|_|\___/ \___|_|\_(_) /____\___|_|  \___/
            |___/
Version: %s
Dev: %s
Server Optimizations: %s
%s[0m
]]):format('\x1b', sbz_api.version, sbz_api.is_version_dev and 'true' or 'false', sbz_api.server_optimizations, '\x1b'))

sbz_api.get_version_string = function()
    local gamename = 'SkyBlock: Zero '
    local version_string = 'Release ' .. sbz_api.version
    if sbz_api.is_version_dev then version_string = version_string .. '-dev' end

    if sbz_api.debug then version_string = version_string .. ' debug ' end
    if sbz_api.server_optimizations then version_string = version_string .. ' server-optimized ' end

    return gamename .. '(' .. version_string .. ')'
end
sbz_api.get_simple_version_string = function()
    return 'SkyBlock: Zero (Release ' .. sbz_api.version .. (sbz_api.is_version_dev and '-dev' or '') .. ')'
end

--vector.random_direction was added in 5.10-dev, but this is defined here for support
--code borrowed from builtin/vector.lua in 5.10-dev
if not vector.random_direction then
    ---@return vector
    function vector.random_direction()
        -- Generate a random direction of unit length, via rejection sampling
        local x, y, z, l2
        repeat -- expected less than two attempts on average (volume sphere vs. cube)
            x, y, z = math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1
            l2 = x * x + y * y + z * z
        until l2 <= 1 and l2 >= 1e-6
        -- normalize
        local l = math.sqrt(l2)
        return vector.new(x / l, y / l, z / l)
    end
end

-- not the exact implementations but BETTER!!

---@param key_last boolean
---@diagnostic disable-next-line: duplicate-set-field
table.foreach = function(t, f, key_last)
    for k, v in pairs(t) do
        local ret
        if key_last then
            ret = f(v, k)
        else
            ret = f(k, v)
        end
        if ret then t[k] = ret end
    end
    return t
end

---@param key_last boolean
---@diagnostic disable-next-line: duplicate-set-field
table.foreachi = function(t, f, key_last)
    for k, v in ipairs(t) do
        if key_last then
            f(v, k)
        else
            f(k, v)
        end
    end
    return t
end

local wallmounted_to_dir = {
    [0] = vector.new(0, 1, 0),
    [1] = vector.new(0, -1, 0),
    [2] = vector.new(1, 0, 0),
    [3] = vector.new(-1, 0, 0),
    [4] = vector.new(0, 0, 1),
    [5] = vector.new(0, 0, -1),
}

function iterate_around_pos(pos, func, include_self)
    for i = 0, 5 do
        local dir = vector.copy(wallmounted_to_dir[i])
        func(pos + dir, dir)
    end
    if include_self then func(pos, vector.zero()) end
end

local vzero = vector.zero()
function sbz_api.iterate_around_pos_nocopy(pos, func, include_self) -- for small optimizations where you know that it wont get polluted
    for i = 0, 5 do
        local dir = wallmounted_to_dir[i]
        func(pos + dir, dir)
    end
    if include_self then func(pos, vzero) end
end

function iterate_around_radius(pos, func, rad)
    rad = rad or 1
    for x = -rad, rad do
        for y = -rad, rad do
            for z = -rad, rad do
                local vec = vector.new(x, y, z)
                vec = vec + pos
                func(vec)
            end
        end
    end
end

minetest.register_on_newplayer(function(player)
    player:set_pos { x = 0, y = 1, z = 0 }

    local inv = player:get_inventory()
    local name = player:get_player_name()
    if inv then
        if inv:contains_item('main', 'sbz_progression:questbook') then
            sbz_api.displayDialogLine(name, 'You already had a questbook before joining.')
        else
            if inv:room_for_item('main', 'sbz_progression:questbook') then
                inv:add_item('main', 'sbz_progression:questbook')
            else
                sbz_api.displayDialogLine(name, "Your inventory is full. Can't give you a questbook. Use /qb")
            end
        end
    end
end)

minetest.register_on_joinplayer(function(ref, last_login)
    local privs = minetest.get_player_privs(ref:get_player_name())
    privs.home = true
    privs.tp = true
    minetest.set_player_privs(ref:get_player_name(), privs)

    ref:override_day_night_ratio(0)
end)

minetest.register_chatcommand('core', {
    description = 'Go back to the core.',
    privs = {},
    func = function(name, param)
        minetest.get_player_by_name(name):set_pos { x = 0, y = 1, z = 0 }
        sbz_api.displayDialogLine(name, 'Sent you back to the Core.') -- i think me renaming "Beamed" to "Sent" is going to make zander mad but i geniuenly have no idea what "Beamed" means so i think most people have no idea too
        -- me, frog, renaming it will also most likely make people investigate its meaning, so we will see :)
    end,
})

-- bgm stuffs
local bgm_sounds = {
    'bgm1',
    'bgm2',
    'bgm3',
    'bgm4',
    'bgm5',
}
local bgm_lengths = {
    280,
    207,
    143,
    121,
    151,
}

local handles = {}

local function playRandomBGM(player)
    if not player then return end
    if player:is_valid() == false then return end
    if player:get_meta() == nil then return end

    local player_name = player:get_player_name()
    local random_index = math.random(1, #bgm_sounds)
    local sound_name = bgm_sounds[random_index]
    local sound_length = bgm_lengths[random_index]
    if handles[player_name] then minetest.sound_stop(handles[player_name]) end
    local volume = player:get_meta():get_int 'volume' / 100
    if volume == 0 and player:get_meta():get_int 'has_set_volume' == 0 then volume = 1 end
    handles[player_name] = minetest.sound_play(sound_name, {
        to_player = player_name,
        gain = volume,
    })
    minetest.after(
        sound_length + math.random(10, 100),
        function() -- i introduce one second of complete silence here, just because -- yeah well I introduce three hundred -- yeah well guess what its random now
            playRandomBGM(player)
        end
    )
end

sbz_api.bgm_handles = handles

minetest.register_chatcommand('bgm_volume', {
    description = 'Adjusts volume of background music',
    params = '[volume, 0 to 200%]',
    func = function(name, param)
        local volume = tonumber(param)
        if volume == nil or volume < 0 or volume > 200 then
            return false, 'Needs to be a number between 0 and 200, 100 is the default volume.'
        end
        local player = minetest.get_player_by_name(name or '')
        if not player then return end
        local meta = player:get_meta()
        meta:set_int('volume', volume)
        meta:set_int('has_set_volume', 1)
        return true,
            'Set the volume to '
                .. volume
                .. "%, the current background music will stay at the value that was before this command, but the next background music's volume will change."
    end,
})

minetest.register_on_joinplayer(function(player)
    -- send welcome messages
    minetest.chat_send_player(player:get_player_name(), sbz_api.get_simple_version_string())
    minetest.chat_send_player(
        player:get_player_name(),
        '‼ reminder: If you fall off, use /core to teleport back to the core.'
    )
    minetest.chat_send_player(
        player:get_player_name(),
        '‼ reminder: If lose your Quest Book, use /qb to get it back.'
    )
    --    minetest.chat_send_player(player:get_player_name(),
    --        "‼ Also, you can hold right click on the core, instead of having to spam your mouse, on mobile you might need to just hold tap")
    -- play bgm
    playRandomBGM(player)

    -- disable the sun, moon, clouds, stars and sky
    player:set_sky {
        base_color = '#000000',
        type = 'skybox',
        textures = { 'sb_top.png', 'sb_bot.png', 'sb_front.png', 'sb_back.png', 'sb_right.png', 'sb_left.png' },
        sky_color = {
            day_sky = '#000000',
            day_horizon = '#000000',
            dawn_sky = '#000000',
            dawn_horizon = '#000000',
            night_sky = '#000000',
            night_horizon = '#000000',
            indoors = '#000000',
        },
    }

    player:set_sun {
        visible = false,
        sunrise_visible = false,
    }

    player:set_moon {
        visible = false,
    }

    player:set_clouds {
        density = 0,
        color = '#00000000',
        ambient = '#00000000',
    }

    player:set_stars {
        visible = false,
    }

    -- make player invisible
    player:set_properties {
        zoom_fov = 15, -- allow zooming
    }

    -- set hotbar
    player:hud_set_hotbar_image 'hotbar.png'
    player:hud_set_hotbar_selected_image 'hotbar_selected.png'

    player:set_physics_override {
        sneak_glitch = true,
    }

    local pinfo = core.get_player_information(player:get_player_name())
    if pinfo.protocol_version < 44 then -- 44 = 5.9.0
        core.show_formspec(
            player:get_player_name(),
            '',
            [[
size[20,18]
real_coordinates[true]
hypertext[0.2,0.2;19.6,17.8;h;<center><bigger>Warning!</bigger></center>
It appears like you are using an outdated version of Luanti/Minetest, or a client based on Luanti/Minetest that hasn't been keeping up to date.
Skyblock Zero on multiplayer is playable with your client, but you may experience errors in the chat, or things not working how they should.

Issues that may arise:
- Machines not being able to be rotated
- Random errors in the chat
- Some entities not rendering (like the turret)
- UI being broken

The only fix for this is to update your client to Luanti 5.9.0 <b>or above</b>. <style size=0>or spoof your protocol version if you are smart and lazy</style>
If you are on Multicraft, or other luanti clients, try switching to regular Luanti instead.
]
button_exit[0.2,16.2;19.6,1.5;exit;Continue to play]
    ]]
        )
    end
end)

core.register_on_respawnplayer(function(ref)
    ref:set_pos { x = 0, y = 2, z = 0 }
    return true
end)

core.register_chatcommand('killme', {
    description = 'Kills you.',
    privs = { ['interact'] = true },
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then return false, 'No player?' end
        player:set_hp(0, '/killme')
    end,
})

-- for the immersion
minetest.register_on_chat_message(function(name, message)
    local players = minetest.get_connected_players()
    if #players == 1 then
        sbz_api.displayDialogLine(name, 'You talk. But there is no one to listen.')
        unlock_achievement(name, 'Desolate')
    end
    return false
end)

minetest.register_globalstep(function(_)
    minetest.set_timeofday(0)
end)

-- inter-mod utils
function count_nodes_within_radius(pos, nodenames, radius)
    local radius_vector = vector.new(radius, radius, radius)
    return #core.find_nodes_in_area(vector.subtract(pos, radius_vector), vector.add(pos, radius_vector), nodenames)
end

-- returns the first node pos
function is_node_within_radius(pos, nodenames, radius)
    local radius_vector = vector.new(radius, radius, radius)
    return core.find_nodes_in_area(vector.subtract(pos, radius_vector), vector.add(pos, radius_vector), nodenames)[1]
end

function is_air(pos)
    local node = core.get_node(pos).name
    local reg = minetest.registered_nodes[node]
    return reg.air or reg.air_equivalent or node == 'air'
end

sbz_api.is_air = is_air

function sbz_api.clamp(x, min, max)
    return math.max(math.min(x, max), min)
end

function sbz_api.make_immutable(t)
    for k, v in pairs(t) do
        if type(v) == 'table' then
            sbz_api.make_immutable(v)
            local mt = table.copy(getmetatable(v) or {})
            if not mt.immutable then
                mt.immutable = true
                mt.newindex = function(t_, k_, v_)
                    error('Immutable!', 2)
                end
                mt.index = v
                setmetatable(v, mt)
            end
        end
    end
    return t
end

--[[
    These 4 lines of code that can pretty much replace vm.lua are from:
    https://github.com/mt-mods/technic/blob/379bedc20d7ab11c758afa52d5916b23dced5354/technic/helpers.lua#L102 to line 107
]]

local get_or_load_node_node
function sbz_api.get_or_load_node(pos)
    get_or_load_node_node = core.get_node_or_nil(pos)
    if get_or_load_node_node then return get_or_load_node_node end
    core.load_area(pos)
    return core.get_node(pos)
end

local MP = minetest.get_modpath 'sbz_base'

dofile(MP .. '/legacy.lua')
dofile(MP .. '/override_for_areas.lua')
dofile(MP .. '/override_descriptions.lua')
dofile(MP .. '/vm.lua')
dofile(MP .. '/queue.lua')
dofile(MP .. '/override_for_other.lua')
dofile(MP .. '/lag_delayer.lua')
dofile(MP .. '/sbz_node_damage.lua')
dofile(MP .. '/sbz_on_hover.lua')
dofile(MP .. '/sbz_player_inside.lua')
dofile(MP .. '/playtime_and_afk.lua')
dofile(MP .. '/dwarf_orb_crafts.lua')
dofile(MP .. '/toggle_areas_hud.lua')
dofile(MP .. '/cache.lua')
dofile(MP .. '/color.lua')
dofile(MP .. '/settings.lua')
dofile(MP .. '/theming.lua')
dofile(MP .. '/default_themes.lua')
dofile(MP .. '/ui.lua')
dofile(MP .. '/recipe.lua')
-- useless cuz of luanti metadata limitations
dofile(MP .. '/serialize.lua')
dofile(MP .. '/serialize_benchmark.lua')
dofile(MP .. '/space_movement.lua')

-- yeah you actually have to do this
-- definition copied from mtg
minetest.override_item('', {
    --    wield_scale = { x = 1, y = 1, z = 2.5 },
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 0,
        groupcaps = {
            crumbly = { times = { [2] = 3.00, [3] = 0.70 }, uses = 0, maxlevel = 1 },
            snappy = { times = { [3] = 0.40 }, uses = 0, maxlevel = 1 },
            oddly_breakable_by_hand = { times = { [1] = 3.50, [2] = 2.00, [3] = 0.70 }, uses = 0 },
        },
        damage_groups = { fleshy = 1 },
    },
})

function table.override(x, y)
    if y == nil then return x end
    x = table.copy(x)
    for k, v in pairs(y) do
        x[k] = v
    end
    return x
end

dofile(MP .. '/sound_api.lua')

sbz_api.filter_node_neighbors = function(start_pos, radius, filtering_function, break_after_one_result)
    local returning = {}
    for x = -radius, radius do
        for y = -radius, radius do
            for z = -radius, radius do
                if not (x == 0 and y == 0 and z == 0) then
                    local pos = vector.add(start_pos, vector.new(x, y, z))
                    local filter_results = { filtering_function(pos) }

                    if #filter_results == 1 then
                        returning[#returning + 1] = filter_results[1]
                    elseif #filter_results ~= 0 then
                        returning[#returning + 1] = filter_results
                    end
                    if break_after_one_result and #filter_results > 0 then return returning end
                end
            end
        end
    end
    return returning
end

-- for funny_air
function sbz_api.line_of_sight(p1, p2, iters)
    iters = iters or 0
    if iters > 128 then
        return false -- we probably entered an infinite loop.... so yea now we wont
    end
    if vector.equals(p1:apply(math.floor), p2:apply(math.floor)) then return true end
    local success, pos = core.line_of_sight(p1, p2)
    if success then return true end
    local nodename = core.get_node(pos).name
    local ndef = core.registered_nodes[nodename]
    if ndef.air or (ndef.groups and ndef.groups.transparent and ndef.groups.transparent >= 1) then
        -- we need to somehow advance pos to like the next node..
        -- p1 -> pos -> p2
        -- yeah i dont knoww, oh wait vector.direction is that isnt it?
        local dir = vector.direction(p1, p2)
        local newpos = pos + dir
        return sbz_api.line_of_sight(newpos, p2, iters + 1)
    else
        return false
    end
end

function sbz_api.punch(target, hitter, time_from_last_punch, tool_caps, dir)
    if (target:is_player()) and hitter ~= nil and not hitter.is_fake_player then
        target:punch(hitter, time_from_last_punch, tool_caps, dir)
    else
        -- entity damage mechanism, see... uhh... the f#ck@ng lua api xD
        -- at first i thought "why the hell is this here"
        -- now i know
        time_from_last_punch = time_from_last_punch or 0
        local damage = 0
        local armor_groups = target:get_armor_groups()
        for group, gdamage in pairs(tool_caps.damage_groups or {}) do
            damage = damage
                + gdamage
                    * sbz_api.clamp(time_from_last_punch / (tool_caps.full_punch_interval or 0), 0, 1)
                    * ((armor_groups[group] or 0) / 100)
        end
        target:set_hp(math.max(0, target:get_hp() - damage))
    end
end

--- Async is todo, and it wont be true async, just the function would be delayed, useful for something like a detonator
---@param pos vector
---@param power number
---@param r number
---@param async boolean
sbz_api.explode = function(pos, r, power, async, owner, extra_damage, knockback_strength, sound)
    if async then
        sbz_api.delay_if_laggy(function()
            sbz_api.explode(pos, r, power, false, owner, extra_damage, knockback_strength, sound)
        end)
        return
    end
    extra_damage = extra_damage or power
    knockback_strength = knockback_strength or 2.5
    owner = owner or ''

    for _ = 1, 500 do
        local raycast = minetest.raycast(pos, pos + vector.random_direction() * r, false, true)
        local wear = 0
        for pointed in raycast do
            if pointed.type == 'node' then
                local target_pos = pointed.under
                local nodename = minetest.get_node(target_pos).name
                local ndef = core.registered_nodes[nodename]
                if not ndef then break end
                wear = wear + (1 / minetest.get_item_group(nodename, 'explody'))
                --the explody group hence signifies roughly how many such nodes in a straight line it can break before stopping
                --although this is very random
                if wear > power or minetest.is_protected(target_pos, owner) then break end
                if ndef.on_blast then
                    ndef.on_blast(target_pos, power, pos, owner, r)
                else
                    minetest.set_node(target_pos, { name = ndef._exploded or 'air' })
                end
            end
        end
    end
    for _, obj in ipairs(core.get_objects_inside_radius(pos, r)) do
        -- this is all messed up
        -- TODO: improve
        local dir = obj:get_pos() - pos
        local len = vector.length(dir)
        if sbz_api.can_move_object(obj:get_armor_groups()) then
            obj:add_velocity(vector.normalize(dir) * (r - vector.length(dir)) * knockback_strength)
        end
        -- this is intentional. HP is only removed when there is line of sight, but velocity is added anyway
        if sbz_api.line_of_sight(pos, obj:get_pos()) == true then
            local dmg = math.abs(vector.length(vector.normalize(dir) * (r - vector.length(dir))) * extra_damage)
            local groups = obj:get_armor_groups()
            local tool_caps = {
                full_punch_interval = 0,
                damage_groups = {},
            }

            -- pick whichever damage group is more protected
            if (groups.matter or 0) <= (groups.antimatter or 0) then
                tool_caps.damage_groups.matter = dmg
            else
                tool_caps.damage_groups.antimatter = dmg
            end

            sbz_api.punch(obj, nil, 100, tool_caps, dir)
        end
    end
    if sound then
        core.sound_play('tnt_explode', {
            gain = 2.5,
            max_hear_distance = 128,
            pos = pos,
        }, true)
    end
end

sbz_api.on_place_recharge = function(charge_per_1_wear, after)
    return function(stack, user, pointed)
        if pointed.type ~= 'node' then return end
        local target = pointed.under
        if core.is_protected(target, user:get_player_name()) then
            return core.record_protection_violation(target, user:get_player_name())
        end

        local target_node_name = minetest.get_node(target).name
        if minetest.get_item_group(target_node_name, 'sbz_battery') == 0 then return end

        local target_meta = minetest.get_meta(target)
        local targets_power = target_meta:get_int 'power'

        local wear = stack:get_wear()
        -- wear repaired = min(wear calculation (may return bigger than wear), the entire wear)
        -- ok this is confusing i knoww, but just remember that wear_repaired is subtracted
        local wear_repaired = math.min(math.floor(targets_power / charge_per_1_wear), wear)
        targets_power = targets_power - (wear_repaired * charge_per_1_wear)
        local targes_def = minetest.registered_nodes[target_node_name]

        target_meta:set_int('power', targets_power)
        targes_def.action(target, target_node_name, target_meta, 0, wear_repaired * charge_per_1_wear)

        stack:set_wear((wear - wear_repaired))
        if after then after(stack, user, pointed) end
        return stack
    end
end

sbz_api.powertool_charge = function(charge_per_1_wear, after)
    ---@return ItemStack, number
    return function(stack, usable_power)
        local used_power = 0
        local wear = stack:get_wear()
        local wear_repaired = math.min(math.floor(usable_power / charge_per_1_wear), wear)
        used_power = wear_repaired * charge_per_1_wear

        stack:set_wear(wear - wear_repaired)
        if after then after(stack) end
        return stack, used_power
    end
end

function sbz_api.can_move_object(armor_groups)
    if armor_groups.no_move then return false end
    if armor_groups.immortal and not armor_groups.can_move then return false end
    return true
end

function sbz_api.get_pos_with_eye_height(placer)
    local p = placer:get_pos()
    if not placer.is_fake_player then p.y = p.y + (placer:get_properties().eye_height or 0) end
    return p
end

-- USE THIS AS A LAG MEASURING FUNCTION
-- Do not use core.get_us_time()
---@return number
function sbz_api.clock_ms()
    return os.clock() * 1000
end

function sbz_api.benchmark(name, f)
    local t0 = os.clock()
    f()
    core.debug(name .. ' TOOK: ' .. (os.clock() - t0) * 1000 .. 'ms')
end

core.register_entity('sbz_base:debug_entity', {
    initial_properties = {
        static_save = false,
        pointable = false,
        visual = 'cube',
        visual_size = { x = 1.2, y = 1.2, z = 1.2 },
        use_texture_alpha = true,
        glow = 14,
        damage_texture_modifier = '',
        shaded = false,
        backface_culling = true,
        textures = {
            'matter_blob.png^[opacity:200',
            'matter_blob.png^[opacity:200',
            'matter_blob.png^[opacity:200',
            'matter_blob.png^[opacity:200',
            'matter_blob.png^[opacity:200',
            'matter_blob.png^[opacity:200',
        },
    },
    on_activate = function(self, staticdata, dtime_s)
        if staticdata and #staticdata ~= 0 then
            self.object:set_properties {
                colors = {
                    staticdata,
                    staticdata,
                    staticdata,
                    staticdata,
                    staticdata,
                    staticdata,
                },
            }
        end
        core.after(8, function()
            if self.object:is_valid() then self.object:remove() end
        end)
    end,
})

-- errors come last.
local old_handler = core.error_handler

core.error_handler = function(error, stack_level)
    return (old_handler(error, stack_level) or '')
        .. ('\n==============\n%s\n=============='):format(sbz_api.get_version_string())
end

core.log('action', "Skyblock: Zero's Base Mod has finished loading.")
core.log(
    'info',
    "If you see warnings about ABMs taking a long time, don't worry, its most likely just trees being generated."
)
