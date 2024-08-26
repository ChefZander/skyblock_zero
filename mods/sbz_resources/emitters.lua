-- Emitter Node
minetest.register_node("sbz_resources:emitter", {
    description = "Emitter",
    tiles = { "emitter.png" },
    groups = { unbreakable = 1, transparent = 1 },
    drop = "",
    sunlight_propagates = true,
    paramtype = "light",
    light_source = 14,
    walkable = true,
    on_punch = function(pos, node, puncher, pointed_thing)
        local itemstack = puncher:get_wielded_item()
        local tool_name = itemstack:get_name()

        if tool_name == "sbz_resources:matter_annihilator" then
            if math.random(1, 10) == 1 then
                puncher:get_inventory():add_item("main", "sbz_resources:raw_emittrium")
                minetest.sound_play("punch_core", {
                    gain = 1.0,
                    max_hear_distance = 32,
                })
                minetest.add_particlespawner({
                    amount = 50,
                    time = 1,
                    minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                    maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                    minvel = { x = -1, y = -1, z = -1 },
                    maxvel = { x = 1, y = 1, z = 1 },
                    minacc = { x = 0, y = 0, z = 0 },
                    maxacc = { x = 0, y = 0, z = 0 },
                    minexptime = 3,
                    maxexptime = 5,
                    minsize = 0.5,
                    maxsize = 1.0,
                    collisiondetection = false,
                    vertical = false,
                    texture = "raw_emittrium.png",
                    glow = 10
                })
                unlock_achievement(puncher:get_player_name(), "Obtain Emittrium")
            else
                minetest.sound_play("punch_core", {
                    gain = 1.0,
                    max_hear_distance = 32,
                })
            end
        else
            minetest.sound_play("punch_core", {
                gain = 1.0,
                max_hear_distance = 32,
            })
            displayDialougeLine(puncher:get_player_name(), "Emitters can only be mined using tools or machines.")
        end
    end
})


minetest.register_abm({
    label = "Emitter Particles",
    nodenames = { "sbz_resources:emitter" },
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.add_particlespawner({
            amount = 5,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
            minvel = { x = -5, y = -5, z = -5 },
            maxvel = { x = 5, y = 5, z = 5 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 30,
            maxexptime = 50,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = false,
            vertical = false,
            texture = "star.png",
            glow = 10
        })
    end,
})

minetest.register_ore({
    ore_type = "scatter",
    ore = "sbz_resources:emitter",
    wherein = "air",
    clust_scarcity = 80 * 80 * 80,
    clust_num_ores = 1,
    clust_size = 1,
    _min = -31000,
    y_max = 31000,
})

-- Emitter Resources
minetest.register_craftitem("sbz_resources:raw_emittrium", {
    description = "Raw Emittrium",
    inventory_image = "raw_emittrium.png",
    stack_max = 16,
})
