unified_inventory.register_craft_type("centrifugeing", {
    description = "Seperating",
    icon = "centrifuge.png^[verticalframe:12:1",
    width = 1,
    height = 1,
    uses_crafting_grid = false,
})

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if listname == "dst" then
        return 0
    end
    return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
    if to_list == "dst" then return 0 end
    return count
end


sbz_api.register_stateful_machine("sbz_chem:centrifuge", {
    description = "Centrifuge",
    tiles = {
        "centrifuge.png^[verticalframe:12:1",
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
    },
    groups = { matter = 1, level = 2 },
    --    paramtype2 = "4dir",
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_put = allow_metadata_inventory_put,

    input_inv = "src",
    output_inv = "dst",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("src", 1)
        inv:set_size("dst", 4)

        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[current_player;main;0.2,5;8,4;]
list[context;src;1.5,1;1,1;]
listring[]
list[context;dst;4.5,1;2,2;]
listring[current_player;main]
listring[context;dst]
    ]])
    end,
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
    autostate = true,
    action = function(pos, _, meta, supply, demand)
        local power_needed = 80
        local inv = meta:get_inventory()

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            return power_needed, false
        else
            meta:set_string("infotext", "Working...")

            local src = inv:get_list("src")

            local decremented_input = ItemStack(src[1])
            local recipe_outputs = unified_inventory.get_usage_list(src[1]:get_name())
            local outputs = {}

            for _, v in pairs(recipe_outputs or {}) do
                if v.type == "centrifugeing" then
                    outputs[#outputs + 1] = ItemStack(v.output)
                end
            end

            if #outputs == 0 then
                meta:set_string("infotext", "Invalid/no recipe")
                return 0
            end


            for k, v in ipairs(outputs) do
                if not inv:room_for_item("dst", v) then
                    meta:set_string("infotext", "Full")
                    -- undo
                    for kk, vv in ipairs(outputs) do
                        if kk >= k then break end
                        inv:remove_item("dst", vv)
                    end
                    return 0
                else
                    inv:add_item("dst", v)
                end
            end

            decremented_input:take_item(1)


            inv:set_stack("src", 1, decremented_input)
            minetest.sound_play({ name = "simple_alloy_furnace_running", gain = 0.6, pos = pos })
            return power_needed
        end
    end,
}, {
    tiles = {
        { name = "centrifuge.png", animation = { type = "vertical_frames", length = 0.6 } },
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
    },
    light_source = 14,
})
