local timer_max = 0
local timer = 0

local function space_movement_step()
    for _, player in pairs(core.get_connected_players()) do
        local controls = player:get_player_control()
        if controls.jump and controls.aux1 and not sbz_api.jetpack_users[player:get_player_name()] then
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
