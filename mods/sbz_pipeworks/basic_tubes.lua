pipeworks.register_tube("pipeworks:tube", {
    description = "Basic Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = pipeworks.tube_backface_culling } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = pipeworks.tube_backface_culling } },
})

minetest.register_craft({
    output = "pipeworks:tube_1 8",
    recipe = {
        { "sbz_chem:aluminum_ingot", "", "sbz_chem:aluminum_ingot" },
        { "",                        "", "" },
        { "sbz_chem:aluminum_ingot", "", "sbz_chem:aluminum_ingot" },
    }
})

pipeworks.register_tube("pipeworks:accelerator_tube", {
    description = "Accelerating Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = pipeworks.tube_backface_culling, color = "springgreen" } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = pipeworks.tube_backface_culling, color = "springgreen" } },

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

pipeworks.register_tube("pipeworks:one_direction_tube", {
    description = "One Direction Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = pipeworks.tube_backface_culling, color = "#45283c" } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = pipeworks.tube_backface_culling, color = "#45283c" } },
    node_def = {
        on_construct = function(pos)
            local likely_dir = nil
            iterate_around_pos(pos, function(ipos)
                if core.get_node(ipos).name:find("pipeworks:one_direction_tube") then
                    local dir = core.get_meta(ipos):get_int("dir")
                    likely_dir = dir
                end
            end)

            if likely_dir == nil then likely_dir = core.dir_to_wallmounted(vector.new(0, -1, 0)) end

            local meta = core.get_meta(pos)
            meta:set_int("dir", likely_dir)
        end,
        -- gets repeated every half second
        sbz_on_hover = function(pointed_thing, player)
            local pos = pointed_thing.under
            local meta = core.get_meta(pos)
            local dir = core.wallmounted_to_dir(meta:get_int("dir"))

            core.add_particle({
                pos = vector.add(
                    pointed_thing.under,
                    vector.divide(dir, 2)),
                expirationtime = 1,
                size = 4,
                texture = "star.png",
                playername = player:get_player_name(),
                glow = 2,
                velocity = vector.divide(dir, 5)
            })
        end,
        on_punch = function(pos, node, puncher, pointed_thing)
            if puncher and not puncher.is_fake_player and puncher:is_player() and not core.is_protected(pos, puncher:get_player_name()) then
                local controls = puncher:get_player_control()
                if controls.sneak then
                    local face = vector.subtract(pointed_thing.above, pointed_thing.under)
                    local dir = core.dir_to_wallmounted(face)
                    core.get_meta(pos):set_int("dir", dir)
                end
            end
        end,
        tube = {
            can_go = function(pos, node, velocity, stack)
                local dir = core.wallmounted_to_dir(core.get_meta(pos):get_int("dir"))
                return { dir }
            end,
            --[[
            can_insert = function(pos, node, stack, direction)
                local dir = core.wallmounted_to_dir(core.get_meta(pos):get_int("dir"))
                return vector.equals(dir, direction)
            end,
            ]]
        }
    },
})

minetest.register_craft({
    output = "pipeworks:one_direction_tube_1",
    type = "shapeless",
    recipe = { "pipeworks:one_way_tube", "pipeworks:tube_1" }
})

pipeworks.register_tube("pipeworks:high_priority_tube", {
    description = "High Priority Tube",
    plain = { { name = "basic_tube_plain.png", backface_culling = pipeworks.tube_backface_culling, color = "tomato" } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = pipeworks.tube_backface_culling, color = "tomato" } },
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
    plain = { { name = "basic_tube_plain.png", backface_culling = pipeworks.tube_backface_culling, color = "lightgreen" } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = pipeworks.tube_backface_culling, color = "lightgreen" } },
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
        { name = "one_way_tube_top.png",              backface_culling = pipeworks.tube_backface_culling },
        { name = "one_way_tube_top.png",              backface_culling = pipeworks.tube_backface_culling },
        { name = "basic_tube_plain.png",              backface_culling = pipeworks.tube_backface_culling },
        { name = "basic_tube_plain.png",              backface_culling = pipeworks.tube_backface_culling },
        { name = "one_way_tube_top.png^[transformFX", backface_culling = pipeworks.tube_backface_culling },
        { name = "one_way_tube_top.png",              backface_culling = pipeworks.tube_backface_culling },
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
    plain = { { name = "pipeworks_broken_tube_plain.png", backface_culling = pipeworks.tube_backface_culling, color = "red" } },
    noctr = { { name = "pipeworks_broken_tube_plain.png", backface_culling = pipeworks.tube_backface_culling, color = "red" } },
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
                    minetest.chat_send_player(playername,
                        ("Broken tubes may be a bit sharp. Maybe try hitting it with a robotic arm?"))
                    if minetest.settings:get_bool("enable_damage") then
                        puncher:set_hp(puncher:get_hp() - 1)
                    end
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
                if meta:get_string("infotext") == "Broken Tube" then
                    meta:set_string("infotext", "")
                end
                meta:set_string("the_tube_was", "")
            else
                pipeworks.logger(log_msg .. " but original node " .. was_node.name .. " is not registered anymore.")
                minetest.chat_send_player(playername, ("This tube cannot be repaired."))
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
