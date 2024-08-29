pipeworks.register_tube("pipeworks:tube", {
    description = "Basic Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = false } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = false } },
})

minetest.register_craft({
    output = "pipeworks:tube_1 8",
    recipe = {
        { "sbz_chem:platinum_powder", "", "sbz_chem:platinum_powder" },
        { "",                         "", "" },
        { "sbz_chem:platinum_powder", "", "sbz_chem:platinum_powder" },
    }
})

pipeworks.register_tube("pipeworks:accelerator_tube", {
    description = "Accelerating Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = false, color = "springgreen" } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = false, color = "springgreen" } },

    node_def = {
        tube = {
            can_go = function(pos, node, velocity, stack)
                velocity.speed = velocity.speed + 1
                return pipeworks.notvel(pipeworks.meseadjlist, velocity)
            end
        }
    },
})

local ch_pa = "sbz_resources:charged_particle"
minetest.register_craft({
    output = "pipeworks:accelerator_tube_1 1",
    recipe = {
        { ch_pa, ch_pa,              ch_pa },
        { ch_pa, "pipeworks:tube_1", ch_pa },
        { ch_pa, ch_pa,              ch_pa },
    }
})

pipeworks.register_tube("pipeworks:high_priority_tube", {
    description = "High Priority Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = false, color = "tomato" } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = false, color = "tomato" } },
    node_def = {
        tube = {
            priority = 150,
        }
    }
})

minetest.register_craft({
    output = "pipeworks:high_priority_tube_1 1",
    type = "shapeless",
    recipe = { "pipeworks:tube_1", "sbz_resources:matter_dust" }
})

pipeworks.register_tube("pipeworks:low_priority_tube", {
    description = "Low Priority Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = false, color = "lightgreen" } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = false, color = "lightgreen" } },
    node_def = {
        tube = {
            priority = 1,
        }
    }
})

minetest.register_craft({
    output = "pipeworks:low_priority_tube_1 1",
    type = "shapeless",
    recipe = { "pipeworks:tube_1", "sbz_resources:antimatter_dust" }
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
    groups = { matter = 2, snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, tubedevice = 1, axey = 1, handy = 1, pickaxey = 1 },
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

minetest.register_craft({
    output = "pipeworks:one_way_tube",
    recipe = {
        { "", "sbz_resources:matter_dust", "" },
        { "", "pipeworks:tube_1",          "" },
        { "", "sbz_resources:matter_dust", "" }
    }
})

pipeworks.register_tube("pipeworks:crossing_tube", {
    description = "Crossing tube",
    plain = { "crossing_tube_plain.png" },
    noctr = { "crossing_tube_noctr.png" },
    node_def = {
        tube = { can_go = function(pos, node, velocity, stack) return { velocity } end }
    },
})

minetest.register_craft({
    output = "pipeworks:crossing_tube_1 5",
    recipe = {
        { "",                 "pipeworks:tube_1", "" },
        { "pipeworks:tube_1", "pipeworks:tube_1", "pipeworks:tube_1" },
        { "",                 "pipeworks:tube_1", "" }
    }
})

pipeworks.register_tube("pipeworks:broken_tube", {
    description = "Broken Tube",
    plain = { { name = "pipeworks_broken_tube_plain.png", backface_culling = true, color = "red" } },
    noctr = { { name = "pipeworks_broken_tube_plain.png", backface_culling = true, color = "red" } },
    node_def = {
        drop = "pipeworks:tube_1",
        groups = { not_in_creative_inventory = 1, tubedevice_receiver = 1 },
        is_ground_content = false,
        tube = {
            insert_object = function(pos, node, stack, direction)
                minetest.item_drop(stack, nil, pos)
                return ItemStack("")
            end,
            can_insert = function(pos, node, stack, direction)
                return true
            end,
            priority = 50,
        },
        on_punch = function(pos, node, puncher, pointed_thing)
            local itemstack = puncher:get_wielded_item()
            local wieldname = itemstack:get_name()
            local playername = puncher:get_player_name()
            local log_msg = playername .. " struck a broken tube at " .. minetest.pos_to_string(pos) .. "\n            "
            local meta = minetest.get_meta(pos)
            local was_node = minetest.deserialize(meta:get_string("the_tube_was"))
            if not was_node then
                pipeworks.logger(log_msg .. "but it can't be repaired.")
                return
            end
            if not pipeworks.check_and_wear_hammer(puncher) then
                if wieldname == "" then
                    pipeworks.logger(log_msg .. "by hand. It's not very effective.")
                    if minetest.settings:get_bool("enable_damage") then
                        minetest.chat_send_player(playername,
                            S("Broken tubes may be a bit sharp. Perhaps try with a hammer?"))
                        puncher:set_hp(puncher:get_hp() - 1)
                    end
                else
                    pipeworks.logger(log_msg .. "with " .. wieldname .. " but that tool is too weak.")
                end
                return
            end
            log_msg = log_msg .. "with " .. wieldname .. " to repair it"
            local nodedef = minetest.registered_nodes[was_node.name]
            if nodedef then
                pipeworks.logger(log_msg .. ".")
                if nodedef.tube and nodedef.tube.on_repair then
                    nodedef.tube.on_repair(pos, was_node)
                else
                    minetest.swap_node(pos, { name = was_node.name, param2 = was_node.param2 })
                    pipeworks.scan_for_tube_objects(pos)
                end
                meta:set_string("the_tube_was", "")
            else
                pipeworks.logger(log_msg .. " but original node " .. was_node.name .. " is not registered anymore.")
                minetest.chat_send_player(playername, S("This tube cannot be repaired."))
            end
        end,
        allow_metadata_inventory_put = function()
            return 0
        end,
        allow_metadata_inventory_move = function()
            return 0
        end,
        allow_metadata_inventory_take = function()
            return 0
        end,
    }
})
