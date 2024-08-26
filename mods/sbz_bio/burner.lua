minetest.register_node("sbz_bio:burner", {
    description = "Burner",
    tiles = {"burner.png"},
    groups = {matter=1, co2_source=1},
    paramtype = "light",
    light_source = 5,
    on_construct = function (pos)
        local meta = minetest.get_meta(pos)
        meta:get_inventory():set_size("main", 1)
        meta:set_string("formspec",
            "formspec_version[7]" ..
            "size[8.2,9]" ..
            "style_type[list;spacing=.2;size=.8]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;3.5,2;1,1;]" ..
            "list[current_player;main;0.2,5;8,4;]" ..
            "listring[]"
        )
    end,
    co2_action = function (pos)
        local inv = minetest.get_meta(pos):get_inventory()
        local itemstack = inv:get_stack("main", 1)
        if itemstack:is_empty() then return 0 end
        local output = minetest.get_item_group(itemstack:get_name(), "burn")
        if output == 0 then return 0 end
        itemstack:take_item()
        inv:set_stack("main", 1, itemstack)
        return output
    end
})