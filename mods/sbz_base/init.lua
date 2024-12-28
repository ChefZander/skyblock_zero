local modname = minetest.get_current_modname()
sbz_api = {
    debug = minetest.settings:get_bool("debug", false),
    version = 27,
    gravity = 9.8 / 2,
    delay_function = core.delay_function
}

sbz_api.deg2rad = math.pi / 180
sbz_api.rad2deg = 180 / math.pi

local modpath = minetest.get_modpath("sbz_base")

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
        if key_last then
            f(v, k)
        else
            f(k, v)
        end
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

function iterate_around_pos(pos, func)
    for i = 0, 5 do
        local dir = minetest.wallmounted_to_dir(i)
        func(pos + dir, dir)
    end
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
    player:set_pos({ x = 0, y = 1, z = 0 })

    local inv = player:get_inventory()
    local name = player:get_player_name()
    if inv then
        if inv:contains_item("main", "sbz_progression:questbook") then
            displayDialougeLine(name, "You already had a questbook before joining.")
        else
            if inv:room_for_item("main", "sbz_progression:questbook") then
                inv:add_item("main", "sbz_progression:questbook")
                -- displayDialougeLine(name, "You have been given a Quest Book.")
            else
                displayDialougeLine(name,
                    "Your inventory is full. Can't give you a questbook. Use /qb")
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

minetest.register_chatcommand("core", {
    description = "Go back to the core, if you fell off.",
    privs = {},
    func = function(name, param)
        minetest.get_player_by_name(name):set_pos({ x = 0, y = 1, z = 0 })
        displayDialougeLine(name, "Beamed you back to the Core.")
    end,
})

-- bgm stuffs
local bgm_sounds = {
    "bgm1",
    "bgm2",
    "bgm3",
    "bgm4",
    "bgm5",
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
    if player:get_meta():get_int("hates_bgm") == 1 then return end
    local random_index = math.random(1, #bgm_sounds)
    local sound_name = bgm_sounds[random_index]
    local sound_length = bgm_lengths[random_index]
    if handles[player_name] then minetest.sound_stop(handles[player_name]) end
    handles[player_name] = minetest.sound_play(sound_name, {
        to_player = player_name,
        gain = 1,
    })
    minetest.after(sound_length + math.random(10, 100),
        function() -- i introduce one second of complete silence here, just because -- yeah well I introduce three hundred -- yeah well guess what its random now
            playRandomBGM(player)
        end)
end

minetest.register_chatcommand("toggle_bgm", {
    description = "Toggles background music",
    func = function(name, param)
        local player = minetest.get_player_by_name(name or "")
        if not player then return end
        local meta = player:get_meta()
        local status = meta:get_int("hates_bgm")
        if status == 0 then
            if handles[name] then minetest.sound_stop(handles[name]) end
            meta:set_int("hates_bgm", 1)
            minetest.chat_send_player(name, "You have disabled the background music.")
        else
            meta:set_int("hates_bgm", 0)
            playRandomBGM(player)
            minetest.chat_send_player(name, "You have enabled the background music.")
        end
    end

})

local function table_length(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

minetest.register_on_joinplayer(function(player)
    -- send welcome messages
    minetest.chat_send_player(player:get_player_name(), ("SkyBlock: Zero (Version %s)"):format(sbz_api.version))
    minetest.chat_send_player(player:get_player_name(),
        "‼ reminder: If you fall off, use /core to teleport back to the core.")
    minetest.chat_send_player(player:get_player_name(), "‼ reminder: If lose your Quest Book, use /qb to get it back.")

    -- play bgm
    playRandomBGM(player)

    -- disable the sun, moon, clouds, stars and sky
    player:set_sky({
        base_color = "#000000",
        type = "skybox",
        textures = { "sb_top.png", "sb_bot.png", "sb_front.png", "sb_back.png", "sb_right.png", "sb_left.png" },
        sky_color = {
            day_sky = "#000000",
            day_horizon = "#000000",
            dawn_sky = "#000000",
            dawn_horizon = "#000000",
            night_sky = "#000000",
            night_horizon = "#000000",
            indoors = "#000000",
        },
    })

    player:set_sun({
        visible = false,
        sunrise_visible = false,
    })

    player:set_moon({
        visible = false,
    })

    player:set_clouds({
        density = 0,
        color = "#00000000",
        ambient = "#00000000",
    })

    player:set_stars({
        visible = false,
    })

    -- make player invisible
    player:set_properties({
        zoom_fov = 15, -- allow zooming
    })

    -- set hotbar
    player:hud_set_hotbar_image("hotbar.png")
    player:hud_set_hotbar_selected_image("hotbar_selected.png")

    player:set_physics_override({
        sneak_glitch = true,
    })

    player:set_formspec_prepend([[
        bgcolor[#080808BB;true]
        background9[5,5;1,1;theme_background.png^\[colorize:purple:50;true;10]
        listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
    ]])
end)

core.register_on_respawnplayer(function(ref)
    ref:set_pos({ x = 0, y = 2, z = 0 })
    return true
end)

core.register_chatcommand("killme", {
    description = "Kills you, like in mtg",
    privs = { ["interact"] = true },
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then return false, "No player?" end
        player:set_hp(0, "/killme")
    end
})

-- for the immersion
minetest.register_on_chat_message(function(name, message)
    local players = minetest.get_connected_players()
    if #players == 1 then
        displayDialougeLine(name, "You talk. But there is no one to listen.")
        unlock_achievement(name, "Desolate")
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
    return reg.air or reg.air_equivalent or node == "air"
end

local MP = minetest.get_modpath("sbz_base")

dofile(MP .. "/override_for_areas.lua")
dofile(MP .. "/override_descriptions.lua")
dofile(MP .. "/vm.lua")
dofile(MP .. "/queue.lua")
dofile(MP .. "/override_for_other.lua")
dofile(MP .. "/lag_delayer.lua")

--vector.random_direction was added in 5.10-dev, but I use 5.9, so make sure this exists
--code borrowed from builtin/vector.lua in 5.10-dev
if not vector.random_direction then
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

-- yeah you actually have to do this
-- definition copied from mtg
minetest.override_item("", {
    --    wield_scale = { x = 1, y = 1, z = 2.5 },
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 0,
        groupcaps = {
            crumbly = { times = { [2] = 3.00, [3] = 0.70 }, uses = 0, maxlevel = 1 },
            snappy = { times = { [3] = 0.40 }, uses = 0, maxlevel = 1 },
            oddly_breakable_by_hand = { times = { [1] = 3.50, [2] = 2.00, [3] = 0.70 }, uses = 0 }
        },
        damage_groups = { fleshy = 1 },
    }
})


function table.override(x, y)
    if y == nil then return x end
    x = table.copy(x)
    for k, v in pairs(y) do
        x[k] = v
    end
    return x
end

dofile(MP .. "/sound_api.lua")

sbz_api.filter_node_neighbors = function(start_pos, radius, filtering_function, break_after_one_result)
    local returning = {}
    for x = -radius, radius do
        for y = -radius, radius do
            for z = -radius, radius do
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
    if ndef.air then
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
    knockback_strength = knockback_strength or 1
    owner = owner or ""

    for _ = 1, 500 do
        local raycast = minetest.raycast(pos, pos + vector.random_direction() * r, false, true)
        local wear = 0
        for pointed in raycast do
            if pointed.type == "node" then
                local target_pos = pointed.under
                local nodename = minetest.get_node(target_pos).name
                local ndef = core.registered_nodes[nodename]
                if not ndef then break end
                wear = wear + (1 / minetest.get_item_group(nodename, "explody"))
                --the explody group hence signifies roughly how many such nodes in a straight line it can break before stopping
                --although this is very random
                if wear > power or minetest.is_protected(target_pos, owner) then break end
                if ndef.on_blast then
                    ndef.on_blast(target_pos, power, pos, owner, r)
                else
                    minetest.set_node(target_pos, { name = ndef._exploded or "air" })
                end
            end
        end
    end
    for _, obj in ipairs(core.get_objects_inside_radius(pos, r)) do
        -- this is all messed up
        -- TODO: improve
        local dir = obj:get_pos() - pos
        obj:add_velocity(vector.normalize(dir) * (r - vector.length(dir)) * knockback_strength +
            vector.new(0, sbz_api.gravity, 0))

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

            obj:punch(nil, nil, tool_caps, dir)
        end
    end
    if sound then
        core.sound_play("tnt_explode", {
            gain = 2.5,
            max_hear_distance = 128,
            pos = pos,
        }, true)
    end
end


sbz_api.on_place_recharge = function(charge_per_1_wear, after)
    return function(stack, user, pointed)
        if pointed.type ~= "node" then return end
        local target = pointed.under
        if core.is_protected(target, user:get_player_name()) then
            return core.record_protection_violation(target, user:get_player_name())
        end

        local target_node_name = minetest.get_node(target).name
        if minetest.get_item_group(target_node_name, "sbz_battery") == 0 then return end

        local target_meta = minetest.get_meta(target)
        local targets_power = target_meta:get_int("power")

        local wear = stack:get_wear()
        -- wear repaired = min(wear calculation (may return bigger than wear), the entire wear)
        -- ok this is confusing i knoww, but just remember that wear_repaired is subtracted
        local wear_repaired = math.min(math.floor(targets_power / charge_per_1_wear), wear)
        targets_power = targets_power - (wear_repaired * charge_per_1_wear)
        local targes_def = minetest.registered_nodes[target_node_name]

        target_meta:set_int("power", targets_power)
        targes_def.action(target, target_node_name, target_meta, 0, wear_repaired * charge_per_1_wear)

        stack:set_wear((wear - wear_repaired))
        if after then
            after(stack, user, pointed)
        end
        return stack
    end
end

local old_handler = core.error_handler

core.error_handler = function(error, stack_level)
    return (old_handler(error, stack_level) or "") ..
        ("\n==============\nSkyblock: Zero (Version %s)\n=============="):format(sbz_api.version)
end

core.log("action", "Skyblock: Zero's Base Mod has finished loading.")
