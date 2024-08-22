minetest.register_craftitem("sbz_meteorites:trajectory_visualiser", {
    description = "Trajectory Visualiser",
    inventory_image = "trajectory_visualiser.png"
})

local elapsed = 0

minetest.register_globalstep(function(dtime)
    elapsed = elapsed+dtime
    if elapsed < 1 then return end
    local players = {}
    local meteorites = {}
    local attractors = {}
    for _, obj in pairs(minetest.object_refs) do
        if obj then
            local entity = obj:get_luaentity()
            if not entity then
                if obj:is_player() and obj:get_wielded_item():get_name() == "sbz_meteorites:trajectory_visualiser" then
                    table.insert(players, obj:get_player_name())
                end
            elseif entity.name == "sbz_meteorites:meteorite" then
                table.insert(meteorites, obj)
            elseif entity.name == "sbz_meteorites:gravitational_attractor_entity" then
                table.insert(attractors, vector.round(obj:get_pos()))
            end
        end
    end
    for _, obj in ipairs(meteorites) do
        local pos = obj:get_pos()
        local vel = obj:get_velocity()
        for _ = 1, 100 do
            pos = pos+vel*0.2
            for _, attractor in ipairs(attractors) do
                vel = vel+0.2*sbz_api.get_attraction(pos, attractor)
            end
            local collides = minetest.registered_nodes[minetest.get_node(vector.round(pos)).name].walkable
            for _, player in ipairs(players) do
                minetest.add_particle({
                    pos = pos,
                    expiration_time = 1,
                    size = collides and 50 or 10,
                    texture = "visualiser_trail.png",
                    animation = {type="vertical_frames", aspect_width=8, aspect_height=8, length=0.2},
                    glow = 14,
                    playername = player
                })
            end
            if collides then break end
        end
    end
    elapsed = 0
end)