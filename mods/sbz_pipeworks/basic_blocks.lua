--[[ includes:
    Item Sorter - sorting tube code
    Item Void - pipeworks traschan code
--]]

local fs_helpers = pipeworks.fs_helpers

local function item_sorter_formspec(pos)
    local meta = minetest.get_meta(pos)
    local buttons_formspec = ""
    for i = 0, 5 do
        buttons_formspec = buttons_formspec .. fs_helpers.cycling_button(meta,
            "image_button[9," .. (i + (i * 0.25) + 0.5) .. ";1,0.6", "l" .. (i + 1) .. "s",
            {
                pipeworks.button_off,
                pipeworks.button_on
            }
        )
    end
    meta:set_string("formspec",
        "formspec_version[2]" ..
        "size[10.2,13]" ..
        "list[context;line1;1.5,0.25;6,1;]" ..
        "list[context;line2;1.5,1.50;6,1;]" ..
        "list[context;line3;1.5,2.75;6,1;]" ..
        "list[context;line4;1.5,4.00;6,1;]" ..
        "list[context;line5;1.5,5.25;6,1;]" ..
        "list[context;line6;1.5,6.50;6,1;]" ..
        "box[0.22,0.25;1,1;white]" ..
        "box[0.22,1.50;1,1;black]" ..
        "box[0.22,2.75;1,1;green]" ..
        "box[0.22,4.00;1,1;yellow]" ..
        "box[0.22,5.25;1,1;blue]" ..
        "box[0.22,6.50;1,1;red]" ..
        buttons_formspec ..
        --"list[current_player;main;0,8;8,4;]" ..
        pipeworks.fs_helpers.get_inv(8) ..
        "listring[current_player;main]" ..
        "listring[current_player;main]" ..
        "listring[context;line1]" ..
        "listring[current_player;main]" ..
        "listring[context;line2]" ..
        "listring[current_player;main]" ..
        "listring[context;line3]" ..
        "listring[current_player;main]" ..
        "listring[context;line4]" ..
        "listring[current_player;main]" ..
        "listring[context;line5]" ..
        "listring[current_player;main]" ..
        "listring[context;line6]"
    )
end

minetest.register_node("pipeworks:item_sorter", {
    description = "Item sorter",
    tiles = {
        { name = "itemsorter.png", color = "green" },
        { name = "itemsorter.png", color = "yellow" },

        { name = "itemsorter.png", color = "blue" },
        { name = "itemsorter.png", color = "red" },

        { name = "itemsorter.png", color = "white" },
        { name = "itemsorter.png", color = "#222222" },
    },
    groups = {
        tube = 1,
        tubedevice = 1,
        matter = 3,
    },
    tube = {
        can_go = function(pos, node, velocity, stack)
            local tbl, tbln = {}, 0
            local found, foundn = {}, 0
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local name = stack:get_name()
            for i, vect in ipairs(pipeworks.meseadjlist) do
                local npos = vector.add(pos, vect)
                local node = minetest.get_node(npos)
                local reg_node = minetest.registered_nodes[node.name]
                if meta:get_int("l" .. i .. "s") == 1 and reg_node then
                    local tube_def = reg_node.tube
                    if not tube_def or not tube_def.can_insert or
                        tube_def.can_insert(npos, node, stack, vect) then
                        local invname = "line" .. i
                        local is_empty = true
                        for _, st in ipairs(inv:get_list(invname)) do
                            if not st:is_empty() then
                                is_empty = false
                                if st:get_name() == name then
                                    foundn = foundn + 1
                                    found[foundn] = vect
                                end
                            end
                        end
                        if is_empty then
                            tbln = tbln + 1
                            tbl[tbln] = vect
                        end
                    end
                end
            end
            return (foundn > 0) and found or tbl
        end,
        connect_sides = { front = 1, back = 1, left = 1, right = 1, top = 1, bottom = 1 },
        priority = 120
    },
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        for i = 1, 6 do
            meta:set_int("l" .. tostring(i) .. "s", 1)
            inv:set_size("line" .. tostring(i), 6 * 1)
        end
        item_sorter_formspec(pos)
        meta:set_string("infotext", "Item Sorter")
    end,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        if placer and placer:is_player() and placer:get_player_control().aux1 then
            local meta = minetest.get_meta(pos)
            for i = 1, 6 do
                meta:set_int("l" .. tostring(i) .. "s", 0)
            end
            item_sorter_formspec(pos)
        end
        return pipeworks.after_place(pos, placer, itemstack, pointed_thing)
    end,
    on_punch = item_sorter_formspec,
    on_receive_fields = function(pos, formname, fields, sender)
        if (fields.quit and not fields.key_enter_field)
            or not pipeworks.may_configure(pos, sender) then
            return
        end
        fs_helpers.on_receive_fields(pos, fields)
        item_sorter_formspec(pos)
    end,
    can_dig = function(pos, player)
        item_sorter_formspec(pos) -- so non-virtual items would be dropped for old tubes
        return true
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        item_sorter_formspec(pos) -- For old tubes
        local inv = minetest.get_meta(pos):get_inventory()
        local stack_copy = ItemStack(stack)
        stack_copy:set_count(1)
        inv:set_stack(listname, index, stack_copy)
        return 0
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        item_sorter_formspec(pos) -- For old tubes
        local inv = minetest.get_meta(pos):get_inventory()
        inv:set_stack(listname, index, ItemStack(""))
        return 0
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        item_sorter_formspec(pos) -- For old tubes
        local inv = minetest.get_meta(pos):get_inventory()

        if from_list:match("line%d") and to_list:match("line%d") then
            return count
        else
            inv:set_stack(from_list, from_index, ItemStack(""))
            return 0
        end
    end,
    after_dig_node = pipeworks.after_dig,

})

minetest.register_craft({
    output = "pipeworks:item_sorter",
    recipe = {
        { "sbz_chem:invar_ingot", "pipeworks:tube_1",             "sbz_chem:invar_ingot" },
        { "pipeworks:tube_1",     "sbz_resources:simple_circuit", "pipeworks:tube_1" },
        { "sbz_chem:invar_ingot", "pipeworks:tube_1",             "sbz_chem:invar_ingot" }
    },
})

minetest.register_node("pipeworks:item_void", {
    description = "Item void",
    tiles = { { name = "trashcan.png" } },
    groups = { cracky = 3, matter = 3, tubedevice = 1, tubedevice_receiver = 1 },
    tube = {
        insert_object = function(pos, node, stack, direction)
            local meta = core.get_meta(pos)
            local meta_stack_count = meta:get_int("items_voided")
            local stack_count = stack:get_count()
            meta_stack_count = meta_stack_count + stack_count
            meta:set_int("items_voided", meta_stack_count)
            meta:set_string("infotext", "Items destroyed: " .. meta_stack_count)
            return ItemStack("")
        end,
        connect_sides = { left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1 },
        priority = 1
    },
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
})

minetest.register_craft({
    output = "pipeworks:item_void 1",
    recipe = {
        { "sbz_resources:matter_blob", "pipeworks:tube_1",                 "sbz_resources:matter_blob" },
        { "pipeworks:tube_1",          "sbz_resources:matter_annihilator", "pipeworks:tube_1" },
        { "sbz_resources:matter_blob", "pipeworks:tube_1",                 "sbz_resources:matter_blob" }
    },
})
