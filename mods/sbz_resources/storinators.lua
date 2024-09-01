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

    if string.sub(node.name, - #"_public") == "_public" then
        new_texture = new_texture .. "_public"
    end

    node.name = "sbz_resources:" .. new_texture


    minetest.swap_node(pos, node)
end


for k, v in ipairs({
    "sbz_resources:storinator",
    "sbz_resources:storinator_full_1",
    "sbz_resources:storinator_full_2",
    "sbz_resources:storinator_full_3",
}) do
    local tex = "storinator_empty.png"

    if v ~= "sbz_resources:storinator" then
        tex = string.sub(v, 15) .. ".png"
    end
    local def = {
        description = "Storinator",
        info_extra = "32 slots",
        tiles = {
            "storinator_side.png",
            "storinator_side.png",
            "storinator_side.png",
            "storinator_side.png",
            "storinator_side.png",
            tex
        },
        groups = { matter = 1, tubedevice = 1, tubedevice_receiver = 1, not_in_creative_inventory = not (v == "sbz_resources:storinator") and 1 or 0 },
        paramtype2 = "facedir",
        sunlight_propagates = true,
        use_texture_alpha = "clip",
        on_rightclick = function(pos)
            -- compat for old worlds, remove after a release or something
            minetest.get_meta(pos):set_string("formspec", "formspec_version[7]" ..
                "size[8.2,9]" ..
                "style_type[list;spacing=.2;size=.8]" ..
                "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;0.2,0.2;8,4;]" ..
                "list[current_player;main;0.2,5;8,4;]" ..
                "listring[]")
        end,
        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            inv:set_size("main", 32)

            meta:set_string("formspec", "formspec_version[7]" ..
                "size[8.2,9]" ..
                "style_type[list;spacing=.2;size=.8]" ..
                "list[context;main;0.2,0.2;8,4;]" ..
                "list[current_player;main;0.2,5;8,4;]" ..
                "listring[]")
        end,
        on_metadata_inventory_put = update_node_texture,
        on_metadata_inventory_take = update_node_texture,
        on_metadata_inventory_move = update_node_texture,
        drop = "sbz_resources:storinator",
        tube = {
            input_inventory = "main",
            insert_object = function(pos, node, stack, direction)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()
                return inv:add_item("main", stack)
            end,
            can_insert = function(pos, node, stack, direction)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()
                if meta:get_int("splitstacks") == 1 then
                    stack = stack:peek_item(1)
                end
                return inv:room_for_item("main", stack)
            end,
            connect_sides = { left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1 }
        },
        after_dig_node = pipeworks.after_dig,
        after_place_node = pipeworks.after_place,
    }
    local public_def = table.copy(def)

    minetest.register_node(v, def)
    public_def.description = "Public Storinator (anyone is allowed to access it)"

    for kk, vv in ipairs(public_def.tiles) do
        public_def.tiles[kk] = vv .. "^[colorize:cyan:50"
    end
    public_def.groups.public = 1
    minetest.register_node(v .. "_public", public_def)
end

minetest.register_craft {
    output = "sbz_resources:storinator_public",
    type = "shapeless",
    recipe = {
        "sbz_resources:storinator"
    }
}

minetest.register_craft {
    output = "sbz_resources:storinator",
    type = "shapeless",
    recipe = {
        "sbz_resources:storinator_public"
    }
}

minetest.register_craft({
    output = "sbz_resources:storinator",
    recipe = {
        { "sbz_power:simple_charged_field",  "sbz_resources:matter_plate",   "sbz_resources:retaining_circuit" },
        { "sbz_resources:matter_plate",      "sbz_resources:simple_circuit", "sbz_resources:matter_plate" },
        { "sbz_resources:retaining_circuit", "sbz_resources:matter_plate",   "sbz_resources:retaining_circuit" }
    }
})
