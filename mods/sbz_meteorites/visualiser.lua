sbz_api.register_machine("sbz_meteorites:meteorite_radar", {
    disallow_pipeworks = true,
    description = "Meteorite Radar",
    drawtype = "mesh",
    mesh = "meteorite_radar.obj",
    tiles = { "meteorite_radar.png" },
    collision_box = {
        type = "fixed",
        fixed = { -0.5, -0.5, -0.5, 0.5, 0.25, 0.5 }
    },
    selection_box = {
        type = "fixed",
        fixed = { -0.5, -0.5, -0.5, 0.5, 0.25, 0.5 }
    },
    groups = { matter = 1 },
    power_needed = 20,
    action_interval = 0,
    on_construct = function(pos)
        minetest.sound_play({ name = "machine_build" }, { pos = pos })
    end,
    action = function(radar_pos)
        local players = {}
        local meteorites = {}
        local attractors = {}
        local repulsors = {}
        for _, obj in pairs(minetest.get_objects_inside_radius(radar_pos, 150)) do
            if obj then
                local entity = obj:get_luaentity()
                if not entity then
                    if obj:is_player() then
                        table.insert(players, obj:get_player_name())
                    end
                elseif entity.name == "sbz_meteorites:meteorite" then
                    table.insert(meteorites, obj)
                elseif entity.name == "sbz_meteorites:gravitational_attractor_entity" then
                    table.insert(entity.type < 0 and repulsors or attractors, vector.round(obj:get_pos()))
                end
            end
        end
        if #meteorites > 0 then
            minetest.add_particle({
                pos = radar_pos + vector.new(0, 1.5, 0),
                expiration_time = 1,
                size = 10,
                texture = "antenna.png",
                animation = { type = "vertical_frames", aspect_width = 18, aspect_height = 18, length = 0.5 },
                glow = 14
            })

            minetest.sound_play(
                { name = "alarm", gain = 0.7 },
                { pos = radar_pos, max_hear_distance = 64 }
            )
        end
        for _, obj in ipairs(meteorites) do
            obj:get_luaentity():show_waypoint()
            local pos = obj:get_pos()
            local vel = obj:get_velocity()
            for _ = 1, 500 do
                pos = pos + vel * 0.2
                for _, attractor in ipairs(attractors) do
                    vel = vel + 51.2 * sbz_api.get_attraction(pos, attractor)
                end
                for _, repulsor in ipairs(repulsors) do
                    vel = vel - 51.2 * sbz_api.get_attraction(pos, repulsor)
                end
                local collides = minetest.registered_nodes[minetest.get_node(vector.round(pos)).name].walkable
                for _, player in ipairs(players) do
                    minetest.add_particle({
                        pos = pos,
                        expiration_time = 1,
                        size = collides and 50 or 10,
                        texture = "visualiser_trail.png",
                        animation = { type = "vertical_frames", aspect_width = 8, aspect_height = 8, length = 0.2 },
                        glow = 14,
                        playername = player
                    })
                end
                if collides then break end
            end
        end
    end
})

minetest.register_craft({
    output = "sbz_meteorites:meteorite_radar",
    recipe = {
        { "",                          "sbz_chem:titanium_alloy_ingot",  "" },
        { "",                          "sbz_chem:titanium_alloy_ingot",  "" },
        { "sbz_resources:matter_blob", "sbz_resources:emittrium_circuit", "sbz_resources:matter_blob" }
    }
})
