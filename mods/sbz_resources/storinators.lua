local function update_node_texture(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local count = 0

    for i = 1, inv:get_size("main") do
        if not inv:get_stack("main", i):is_empty() then
            count = count + 1
        end
    end

    local new_texture
    if count < 5 then
        new_texture = "storinator"
    elseif count < 15 then
        new_texture = "storinator_full_1"
    elseif count < 25 then
        new_texture = "storinator_full_2"
    else
        new_texture = "storinator_full_3"
    end
    local node = minetest.get_node(pos)
    node.name = "sbz_resources:" .. new_texture

    minetest.swap_node(pos, node)
end



minetest.register_node("sbz_resources:storinator", {
    description = "Storinator\n\nInventory Slots: 30.",
    tiles = {
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_empty.png",
    },
    groups = { matter = 1 },
    paramtype2 = "facedir",
    sunlight_propagates = true,
    walkable = true,
    on_rightclick = function(pos, node, player, pointed_thing)
        local player_name = player:get_player_name()
        minetest.show_formspec(player_name, "sbz_resources:simple_charge_generator_formspec",
            "formspec_version[7]" ..
            "size[8.2,9]" ..
            "style_type[list;spacing=.2;size=.8]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;0,0;8,4;]" ..
            "list[current_player;main;0.2,5;8,4;]" ..
            "listring[]")

        minetest.sound_play("machine_open", {
            to_player = player_name,
            gain = 1.0,
        })
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 30)


        minetest.sound_play("machine_build", {
            to_player = player_name,
            gain = 1.0,
        })
    end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        update_node_texture(pos)
    end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        update_node_texture(pos)
    end,
    on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        update_node_texture(pos)
    end,
})

minetest.register_node("sbz_resources:storinator_full_1", {
    description = "Storinator\n\nInventory Slots: 30.",
    tiles = {
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_full_1.png",
    },
    groups = { matter = 1 },
    paramtype2 = "facedir",
    sunlight_propagates = true,
    walkable = true,
    on_rightclick = function(pos, node, player, pointed_thing)
        local player_name = player:get_player_name()
        minetest.show_formspec(player_name, "sbz_resources:simple_charge_generator_formspec",
            "formspec_version[7]" ..
            "size[8.2,9]" ..
            "style_type[list;spacing=.2;size=.8]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;0,0;8,4;]" ..
            "list[current_player;main;0.2,5;8,4;]" ..
            "listring[]")

        minetest.sound_play("machine_open", {
            to_player = player_name,
            gain = 1.0,
        })
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 30)


        minetest.sound_play("machine_build", {
            to_player = player_name,
            gain = 1.0,
        })
    end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        update_node_texture(pos)
    end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        update_node_texture(pos)
    end,
    on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        update_node_texture(pos)
    end,
})

minetest.register_node("sbz_resources:storinator_full_2", {
    description = "Storinator\n\nInventory Slots: 30.",
    tiles = {
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_full_2.png",
    },
    groups = { matter = 1 },
    paramtype2 = "facedir",
    sunlight_propagates = true,
    walkable = true,
    on_rightclick = function(pos, node, player, pointed_thing)
        local player_name = player:get_player_name()
        minetest.show_formspec(player_name, "sbz_resources:simple_charge_generator_formspec",
            "formspec_version[7]" ..
            "size[8.2,9]" ..
            "style_type[list;spacing=.2;size=.8]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;0,0;8,4;]" ..
            "list[current_player;main;0.2,5;8,4;]" ..
            "listring[]")

        minetest.sound_play("machine_open", {
            to_player = player_name,
            gain = 1.0,
        })
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 30)


        minetest.sound_play("machine_build", {
            to_player = player_name,
            gain = 1.0,
        })
    end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        update_node_texture(pos)
    end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        update_node_texture(pos)
    end,
    on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        update_node_texture(pos)
    end,
})

minetest.register_node("sbz_resources:storinator_full_3", {
    description = "Storinator\n\nInventory Slots: 30.",
    tiles = {
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_full_3.png",
    },
    groups = { matter = 1 },
    paramtype2 = "facedir",
    sunlight_propagates = true,
    walkable = true,
    on_rightclick = function(pos, node, player, pointed_thing)
        local player_name = player:get_player_name()
        minetest.show_formspec(player_name, "sbz_resources:simple_charge_generator_formspec",
            "formspec_version[7]" ..
            "size[8.2,9]" ..
            "style_type[list;spacing=.2;size=.8]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;0,0;8,4;]" ..
            "list[current_player;main;0.2,5;8,4;]" ..
            "listring[]")

        minetest.sound_play("machine_open", {
            to_player = player_name,
            gain = 1.0,
        })
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 30)


        minetest.sound_play("machine_build", {
            to_player = player_name,
            gain = 1.0,
        })
    end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        update_node_texture(pos)
    end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        update_node_texture(pos)
    end,
    on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        update_node_texture(pos)
    end,
})

minetest.register_craft({
    output = "sbz_resources:storinator",
    recipe = {
        { "sbz_resources:simple_charged_field", "sbz_resources:matter_plate",   "sbz_resources:retaining_circuit" },
        { "sbz_resources:matter_plate",         "sbz_resources:simple_circuit", "sbz_resources:matter_plate" },
        { "sbz_resources:retaining_circuit",    "sbz_resources:matter_plate",   "sbz_resources:retaining_circuit" }
    }
})
