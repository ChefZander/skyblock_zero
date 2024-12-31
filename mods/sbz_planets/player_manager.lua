local area = vector.new(30, 30, 30)

core.register_globalstep(function(dtime)
    -- so... yeah.. i need to apply acceleration to the player, towards the center of the planet... if there is one nearby
    -- and also remove the default gravity when there is a planet nearby
    local players = core.get_connected_players()
    for k, v in pairs(players) do
        local pos = v:get_pos()
        local planets = sbz_api.planets.area:get_areas_in_area(pos - area, pos + area, true, true, true)

        if next(planets) ~= nil then
            local _, planet = next(planets)
            local data = core.deserialize(planet.data)
            local type = data[1]
            local type_def = sbz_api.planets.types[type]
            if type_def.light and not sbz_api.forced_light[v:get_player_name()] then
                v:override_day_night_ratio(type_def.light / 14)
            end
        else
            if not sbz_api.forced_light[v:get_player_name()] then
                v:override_day_night_ratio(0)
            end
        end
    end
end)
