local function spawn_meteorite(pos)
    local players = minetest.get_connected_players()
    local player = players[math.random(#players)]
    if not pos then
        pos = vector.zero()
        while vector.length(pos) < 100 or minetest.get_node(pos).name == "ignore" do
            pos = vector.new(math.random(-120, 120), math.random(-120, 120), math.random(-120, 120))
        end
        pos = player:get_pos()+pos
    end
    return minetest.add_entity(pos, "sbz_meteorites:meteorite")
end

minetest.register_chatcommand("spawn_meteorite", {
    params = "[<x> <y> <z>]",
    description = "Attempts to spawn a meteorite somewhere.",
    privs = {give=true},
    func = function (name, param)
        param = string.split(param, " ")
        if #param == 3 and tonumber(param[1]) ~= "fail" and tonumber(param[2]) ~= "fail" and tonumber(param[3]) ~= "fail" then
            param = vector.new(tonumber(param[1]), tonumber(param[2]), tonumber(param[3]))
        else param = nil end
        local meteorite = spawn_meteorite(param)
        if not meteorite then minetest.chat_send_player(name, "Failed to spawn meteorite.") return end
        local pos = vector.round(meteorite:get_pos())
        minetest.chat_send_player(name, "Spawned meteorite at "..pos.x.." "..pos.y.." "..pos.z..".")
    end
})

local storage = minetest.get_mod_storage()
local time_since = storage:get_float("time_since_last_spawn")

minetest.register_globalstep(function(dtime)
    time_since = time_since+dtime
    if time_since > 120 then
        time_since = 0
        if math.random() < 0.2 then
            spawn_meteorite()
        end
    end
    storage:set_float("time_since_last_spawn", time_since)
end)

local modpath = minetest.get_modpath("sbz_meteorites")
dofile(modpath.."/meteorite.lua")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/attractor.lua")