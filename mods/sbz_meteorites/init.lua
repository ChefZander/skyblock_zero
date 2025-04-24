local function spawn_meteorite(pos)
    if not pos then
        for _, ref in pairs(minetest.get_connected_players()) do
            local player_pos = ref:get_pos()
            local attempts = 0
            local relative_pos
            repeat
                relative_pos = vector.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
                pos = player_pos + relative_pos
                attempts = attempts + 1
            until attempts >= 256 or vector.length(relative_pos) > 80 and vector.length(relative_pos) < 100 and minetest.get_node(pos).name == "air"
        end
    end -- DO NOT TURN THIS INTO AN if/else when refactoring, read the code and figure out why
    if pos then
        return minetest.add_entity(pos, "sbz_meteorites:meteorite")
    end
end

minetest.register_chatcommand("spawn_meteorite", {
    params = "([<x> <y> <z>] | [\"here\"]) [number]",
    description = "Attempts to spawn a meteorite somewhere.",
    privs = { give = true },
    func = function(name, param)
        local split = string.split(param, " ", false)
        local num_of_meteorites = 1
        local pos = nil
        -- do not read below
        if type(tonumber(split[1])) == "number" and type(tonumber(split[2])) ~= "number" then
            num_of_meteorites = math.max(1, tonumber(split[1]))
        elseif split[1] == "here" and minetest.get_player_by_name(name) then
            pos = minetest.get_player_by_name(name):get_pos()
            if tonumber(split[2]) ~= nil then
                num_of_meteorites = math.max(1, tonumber(split[2]))
            end
        else
            if tonumber(split[1]) ~= nil and tonumber(split[2]) ~= nil and tonumber(split[3]) ~= nil then
                pos = vector.new(tonumber(split[1]), tonumber(split[2]), tonumber(split[3]))
                if tonumber(split[4]) ~= nil then
                    num_of_meteorites = math.min(1, tonumber(split[4]))
                end
            end
        end
        local meteorite
        for _ = 1, num_of_meteorites do
            meteorite = spawn_meteorite(pos)
        end
        if not meteorite then
            minetest.chat_send_player(name, "Failed to spawn meteorite.")
            return
        end
        local mpos = vector.round(meteorite:get_pos())
        if num_of_meteorites == 1 then
            minetest.chat_send_player(name, "Spawned meteorite at " .. mpos.x .. " " .. mpos.y .. " " .. mpos.z .. ".")
        else
            minetest.chat_send_player(name, "Spawned meteorites.")
        end
    end
})

local storage = minetest.get_mod_storage()
local time_since = storage:get_float("time_since_last_spawn")

local function meteorite_globalstep(dtime)
    time_since = time_since + dtime
    if time_since > 120 then
        time_since = 0
        if math.random() < 0.25 then spawn_meteorite() end
        --        for _, obj in ipairs(minetest.object_refs) do
        --            if obj and obj:get_luaentity() and obj:get_luaentity().name == "sbz_meteorites:gravitational_attractor_entity" and math.random() < 0.2 then
        --                spawns = spawns + obj:get_luaentity().type
        --            end
        --        end
        -- the above is a horrible idea that should never had entered production
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
dofile(modpath .. "/meteorite_maker.lua")
