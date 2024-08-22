minetest.register_craftitem("sbz_meteorites:trajectory_visualiser", {
    description = "Trajectory Visualiser",
    inventory_image = "trajectory_visualiser.png"
})

local elapsed = 0

minetest.register_globalstep(function(dtime)
    elapsed = elapsed+dtime
    if elapsed < 1 then return end
    local players = {}
    for _, player in ipairs(minetest.get_connected_players()) do
        if player:get_wielded_item():get_name() == "sbz_meteorites:trajectory_visualiser" then
            table.insert(players, player:get_player_name())
        end
    end
    for _, obj in pairs(minetest.object_refs) do
        if obj and obj:get_luaentity() and obj:get_luaentity().name == "sbz_meteorites:meteorite" then
            local pos = obj:get_pos()
            local vel = obj:get_velocity()
            for _ = 1, 100 do
                pos = pos+vel
                for _, player in ipairs(players) do
                    minetest.add_particle({
                        pos = pos,
                        expiration_time = 1,
                        size = 10,
                        texture = "visualiser_trail.png",
                        animation = {type="vertical_frames", aspect_width=8, aspect_height=8, length=0.2},
                        glow = 14,
                        playername = player
                    })
                end
            end
        end
    end
    elapsed = 0
end)