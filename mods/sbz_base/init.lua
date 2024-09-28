minetest.log("action", "sbz base: init")

local modname = minetest.get_current_modname()
sbz_api = {
    debug = true
}


local modpath = minetest.get_modpath("sbz_base")
local storage = minetest.get_mod_storage()

--vector.random_direction was added in 5.10-dev, but this is defined here for support
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

-- generate an empty world with only the core block
minetest.log("action", "sbz base: register mapgen")
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
minetest.log("action", "sbz base: register new player")
minetest.register_on_newplayer(function(player)
    player:set_pos({ x = 0, y = 1, z = 0 })

    local inv = player:get_inventory()
    local name = player:get_player_name()
    if inv then
        if inv:contains_item("main", "sbz_progression:questbook") then
            displayDialougeLine(name, "How tf did you manage to get a questbook before spawning as a new player??")
        else
            if inv:room_for_item("main", "sbz_progression:questbook") then
                inv:add_item("main", "sbz_progression:questbook")
                -- displayDialougeLine(name, "You have been given a Quest Book.")
            else
                displayDialougeLine(name,
                    "How tf did you manage to fill your inventory before spawning as a new player??")
            end
        end
    end
end)
minetest.register_on_joinplayer(function(ref, last_login)
    minetest.change_player_privs(ref:get_player_name(), {
        home = true,
        tp = true
    })
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
local function playRandomBGM(player_name)
    local random_index = math.random(1, #bgm_sounds)
    local sound_name = bgm_sounds[random_index]
    local sound_length = bgm_lengths[random_index]
    minetest.sound_play(sound_name, {
        to_player = player_name,
        gain = 1.0,
    })
    minetest.after(sound_length + math.random(10, 100),
        function() -- i introduce one second of complete silence here, just because -- yeah well I introduce three hundred -- yeah well guess what its random now
            playRandomBGM(player_name)
        end)
end



-- WHY LUA, WHY
local function table_length(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

minetest.log("action", "sbz base: register join player")
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
    playRandomBGM(player:get_player_name())

    -- disable the sun, moon, clouds, stars and sky
    player:set_sky({
        base_color = "#000000",
        type = "plain",
        sky_color = {
            day_sky = "#000000",
            day_horizon = "#000000",
            dawn_sky = "#000000",
            dawn_horizon = "#000000",
            night_sky = "#000000",
            night_horizon = "#000000",
            indoors = "#000000",
        },
    }, "plain", {})

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
        gravity = 0.5,
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
local dtimer = 0
minetest.register_globalstep(function(dtime)
    minetest.set_timeofday(0)

    for _, player in ipairs(minetest.get_connected_players()) do
        if player:get_meta():get_int("trailHidden") == 0 then
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
function is_node_within_radius(pos, itemstring, radius)
    for dx = -radius, radius do
        for dy = -radius, radius do
            for dz = -radius, radius do
                local current_pos = {
                    x = pos.x + dx,
                    y = pos.y + dy,
                    z = pos.z + dz
                }
                local node = minetest.get_node(current_pos)
                if node.name == itemstring then
                    return true
                end
            end
        end
    end
    return false
end

function count_nodes_within_radius(pos, itemstring, radius)
    local count = 0
    for dx = -radius, radius do
        for dy = -radius, radius do
            for dz = -radius, radius do
                local current_pos = {
                    x = pos.x + dx,
                    y = pos.y + dy,
                    z = pos.z + dz
                }
                local node = minetest.get_node(current_pos)
                if node.name == itemstring then
                    count = count + 1
                end
            end
        end
    end
    return count
end

-- mapgen aliases


minetest.register_alias("mapgen_stone", "air")
minetest.register_alias("mapgen_water_source", "air")
minetest.register_alias("mapgen_river_water_source", "air")

dofile(minetest.get_modpath("sbz_base") .. "/override_descriptions.lua")
dofile(minetest.get_modpath("sbz_base") .. "/override_for_areas.lua")

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
