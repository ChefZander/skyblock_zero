local function spawn_meteorite(pos)
    local players = minetest.get_connected_players()
    local player = players[math.random(#players)]
    if not pos then
        pos = vector.zero()
        while vector.length(pos) < 80 or vector.length(pos) > 100 or minetest.get_node(pos).name == "ignore" do
            pos = vector.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
        end
        if player then
            pos = player:get_pos() + pos
        end
    end
    return minetest.add_entity(pos, "sbz_meteorites:meteorite")
end

minetest.register_chatcommand("spawn_meteorite", {
    params = "[<x> <y> <z>]",
    description = "Attempts to spawn a meteorite somewhere.",
    privs = { give = true },
    func = function(name, param)
        param = string.split(param, " ")
        if #param == 3 and tonumber(param[1]) ~= "fail" and tonumber(param[2]) ~= "fail" and tonumber(param[3]) ~= "fail" then
            param = vector.new(tonumber(param[1]), tonumber(param[2]), tonumber(param[3]))
        else
            param = nil
        end
        local meteorite = spawn_meteorite(param)
        if not meteorite then
            minetest.chat_send_player(name, "Failed to spawn meteorite.")
            return
        end
        local pos = vector.round(meteorite:get_pos())
        minetest.chat_send_player(name, "Spawned meteorite at " .. pos.x .. " " .. pos.y .. " " .. pos.z .. ".")
    end
})

local storage = minetest.get_mod_storage()
local time_since = storage:get_float("time_since_last_spawn")

local function meteorite_globalstep(dtime)
    time_since = time_since + dtime
    if time_since > 120 then
        time_since = 0
        local spawns = math.random() < 0.25 and 1 or 0
<<<<<<< HEAD
        --        for _, obj in ipairs(minetest.object_refs) do
        --            if obj and obj:get_luaentity() and obj:get_luaentity().name == "sbz_meteorites:gravitational_attractor_entity" and math.random() < 0.2 then
        --                spawns = spawns + obj:get_luaentity().type
        --            end
        --        end
        -- the above is a horrible idea that should never had entered production
=======
        for _, obj in ipairs(minetest.object_refs) do
            if obj and obj:get_luaentity() and obj:get_luaentity().name == "sbz_meteorites:gravitational_attractor_entity" and math.random() < 1/20 then
                spawns = spawns + obj:get_luaentity().type
            end
        end
>>>>>>> c924a96 (do what frog said (meteorite changes))
        if spawns > 0 then for _ = 1, spawns do spawn_meteorite() end end
    end
    storage:set_float("time_since_last_spawn", time_since)
end

minetest.register_globalstep(meteorite_globalstep)

local modpath = minetest.get_modpath("sbz_meteorites")

dofile(modpath .. "/meteorite.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/attractor.lua")
dofile(modpath .. "/waypoints.lua")
dofile(modpath .. "/visualiser.lua")
