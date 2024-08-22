pipeworks.register_tube("pipeworks:tube", {
    description = "Basic Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = false } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = false } },
})

pipeworks.register_tube("pipeworks:accelerator_tube", {
    description = "Accelerating Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = false, color = "lime" } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = false, color = "lime" } },

    node_def = {
        tube = {
            can_go = function(pos, node, velocity, stack)
                velocity.speed = velocity.speed + 1
                return pipeworks.notvel(pipeworks.meseadjlist, velocity)
            end
        }
    },
})

pipeworks.register_tube("pipeworks:high_priority_tube", {
    description = "High Priority Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = false, color = "red" } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = false, color = "red" } },
    node_def = {
        tube = {
            priority = 150,
        }
    }
})

pipeworks.register_tube("pipeworks:low_priority_tube", {
    description = "Low Priority Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = false, color = "green" } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = false, color = "green" } },
    node_def = {
        tube = {
            priority = -1,
        }
    }
})


minetest.register_node("pipeworks:one_way_tube", {
    description = "One way tube",
    tiles = {
        { name = "one_way_tube_top.png",              backface_culling = false },
        { name = "one_way_tube_top.png",              backface_culling = false },
        { name = "basic_tube_plain.png",              backface_culling = false },
        { name = "basic_tube_plain.png",              backface_culling = false },
        { name = "one_way_tube_top.png^[transformFX", backface_culling = false },
        { name = "one_way_tube_top.png",              backface_culling = false },
    },

    use_texture_alpha = "clip",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    paramtype = "light",
    node_box = {
        type = "fixed",
        fixed = pipeworks.tube_long
    },
    groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, tubedevice = 1, axey = 1, handy = 1, pickaxey = 1 },
    is_ground_content = false,
    tube = {
        connect_sides = { left = 1, right = 1 },
        can_go = function(pos, node, velocity, stack)
            return { velocity }
        end,
        can_insert = function(pos, node, stack, direction)
            local dir = pipeworks.facedir_to_right_dir(node.param2)
            return vector.equals(dir, direction)
        end,
        priority = 75 -- Higher than normal tubes, but lower than receivers
    },
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
    on_rotate = pipeworks.on_rotate,
})


pipeworks.register_tube("pipeworks:crossing_tube", {
    description = "Tube Junction",
    plain = { "crossing_tube_plain.png" },
    noctr = { "crossing_tube_noctr.png" },
    node_def = {
        tube = { can_go = function(pos, node, velocity, stack) return { velocity } end }
    },
})
