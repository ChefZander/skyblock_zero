local timer_max = 0
local timer = 0

core.register_privilege("space", {
    description = "Allows toggling space movement",
    give_to_singleplayer = false,
})

-- Get/set persistent space mode in player meta
local function is_space_enabled(player)
    local meta = player:get_meta()
    return meta:get_int("space_enabled") == 1
end

-- Toggle space movement ability on/off
local function set_space_enabled(player, enabled)
    local meta = player:get_meta()
    meta:set_int("space_enabled", enabled and 1 or 0)
end

core.register_chatcommand("space", {
    description = "Toggle space movement",
    privs = { space = true }, -- must have "space" priv
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Player not online"
        end

        local enabled = not is_space_enabled(player)
        set_space_enabled(player, enabled)

        return true, "Space mode: " .. (enabled and "ON" or "OFF")
    end
})

local function space_movement_step()
    for _, player in pairs(core.get_connected_players()) do
        local controls = player:get_player_control()
        local name = player:get_player_name()

        if controls.jump and controls.aux1
                and is_space_enabled(player)
                and not sbz_api.jetpack_users[name] then
            player_monoids.gravity:add_change(player, 0, 'sbz_api:space_movement')
        else
            player_monoids.gravity:del_change(player, 'sbz_api:space_movement')
        end
    end
end

core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= timer_max then
        timer = 0
        space_movement_step()
    end
end)
