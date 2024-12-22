local modname = minetest.get_current_modname()
sbz_api = {
    debug = minetest.settings:get_bool("debug", false)
}

sbz_api.deg2rad = math.pi / 180
sbz_api.rad2deg = 180 / math.pi

local modpath = minetest.get_modpath("sbz_base")
local storage = minetest.get_mod_storage()

-- apply forced game settings
core.settings:set("enable_damage", "false")
core.settings:set("enable_pvp", "false")

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

-- generate an empty world with only the core block
minetest.register_on_generated(function(minp, maxp, seed)
    if minp.x <= 0 and maxp.x >= 0 and minp.y <= 0 and maxp.y >= 0 and minp.z <= 0 and maxp.z >= 0 then
        local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
        local data = vm:get_data()

        local area = VoxelArea:new { MinEdge = emin, MaxEdge = emax }
        local c_air = minetest.get_content_id("air")
        local c_stone = minetest.get_content_id("sbz_resources:the_core")

        for z = minp.z, maxp.z do
            for y = minp.y, maxp.y do
                for x = minp.x, maxp.x do
                    local vi = area:index(x, y, z)
                    data[vi] = c_air
                end
            end
        end

        -- place the core
        if minp.x <= 0 and maxp.x >= 0 and minp.y <= 0 and maxp.y >= 0 and minp.z <= 0 and maxp.z >= 0 then
            local vi = area:index(0, 0, 0)
            data[vi] = c_stone
        end

        vm:set_data(data)
        vm:calc_lighting()
        vm:write_to_map()
    end
end)

-- new players always spawn on the core
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

-- also allow /core
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
    minetest.chat_send_player(player:get_player_name(), "SkyBlock: Zero")
    minetest.chat_send_player(player:get_player_name(), "          by Zander (@zanderdev)")

    local num_nodes = table_length(minetest.registered_nodes)
    local num_items = table_length(minetest.registered_craftitems)
    minetest.chat_send_player(player:get_player_name(),
        "✔ Loaded " .. num_nodes .. " Nodes, " .. num_items .. " Items and " .. #quests .. " Quests.")

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
        visual = "sprite",
        visual_size = { x = 1, y = 2 },
        textures = { "transparent16.png", "transparent16.png" },

        zoom_fov = 15, -- allow zooming
    })

    -- set hotbar
    -- player:hud_set_hotbar_itemcount(32) -- nerds only
    player:hud_set_hotbar_image("hotbar.png")
    player:hud_set_hotbar_selected_image("hotbar_selected.png")

    -- space gravity yeeeah
    player:set_physics_override({
        sneak_glitch = true, -- sneak glitch is super based
    })

    player:set_formspec_prepend([[
        bgcolor[#080808BB;true]
        background9[5,5;1,1;theme_background.png^\[colorize:purple:50;true;10]
        listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
    ]])
end)

-- for the immersion
minetest.register_on_chat_message(function(name, message)
    local players = minetest.get_connected_players()
    if #players == 1 then
        displayDialougeLine(name, "You talk. But there is no one to listen.")
        unlock_achievement(name, "Desolate")
    end
    return false
end)

-- everything pitch dark always

sbz_api.players_with_temporarily_hidden_trails = {}

minetest.register_globalstep(function(_)
    minetest.set_timeofday(0)

    for _, player in ipairs(minetest.get_connected_players()) do
        -- let the trail indicate that like yeah a globalstep happened
        if player:get_meta():get_int("trailHidden") == 0 and not sbz_api.players_with_temporarily_hidden_trails[player:get_player_name()] then
            local pos = player:get_pos()
            minetest.add_particlespawner({
                amount = 1,
                time = 1,
                minpos = { x = pos.x - 0, y = pos.y - 0, z = pos.z - 0 },
                maxpos = { x = pos.x + 0, y = pos.y + 0, z = pos.z + 0 },
                minvel = { x = 0, y = 0, z = 0 },
                maxvel = { x = 0, y = 0, z = 0 },
                minacc = { x = 0, y = 0, z = 0 },
                maxacc = { x = 0, y = 0, z = 0 },
                minexptime = 1,
                maxexptime = 1,
                minsize = 1.0,
                maxsize = 1.0,
                collisiondetection = true,
                vertical = false,
                texture = "star.png",
                glow = 10
            })
        end
    end
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

-- mapgen aliases


minetest.register_alias("mapgen_stone", "air")
minetest.register_alias("mapgen_water_source", "air")
minetest.register_alias("mapgen_river_water_source", "air")

local MP = minetest.get_modpath("sbz_base")

dofile(MP .. "/override_for_areas.lua")
dofile(MP .. "/override_descriptions.lua")
dofile(MP .. "/vm.lua")
dofile(MP .. "/queue.lua")
dofile(MP .. "/override_for_other.lua")

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

--- Async is todo, and it wont be true async, just the function would be delayed, useful for something like a detonator
---@param pos vector
---@param power number
---@param r number
---@param async boolean
sbz_api.explode = function(pos, r, power, async, owner)
    owner = owner or ""
    for _ = 1, 500 do
        local raycast = minetest.raycast(pos, pos + vector.random_direction() * r, false)
        local wear = 0
        for pointed in raycast do
            if pointed.type == "node" then
                local nodename = minetest.get_node(pointed.under).name
                wear = wear + (1 / minetest.get_item_group(nodename, "explody"))
                --the explody group hence signifies roughly how many such nodes in a straight line it can break before stopping
                --although this is very random
                if wear > power or minetest.is_protected(pointed.under, owner) then break end
                minetest.set_node(pointed.under, { name = minetest.registered_nodes[nodename]._exploded or "air" })
            end
        end
    end
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, r)) do
        if obj:is_player() then
            local dir = obj:get_pos() - pos
            obj:add_velocity((vector.normalize(dir) + vector.new(0, 0.5, 0)) * 0.5 * (r - vector.length(dir)))
        end
    end
end

minetest.log("action", "Skyblock: Zero's Base Mod has finished loading.")