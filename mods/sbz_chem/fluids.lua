-- Empty
minetest.register_craftitem("sbz_chem:empty_fluid_cell", {
    description = "Empty Fluid Cell (Empty)",
    inventory_image = "fluid_cell.png",
    liquids_pointable = true,
    on_place = function(itemstack, user, pointed)
        if pointed.type ~= "node" then return end
        local node = minetest.get_node(pointed.under)
        if node.name == "sbz_resources:water_source" then
            minetest.remove_node(pointed.under)
            itemstack:take_item()
            if itemstack:is_empty() then return ItemStack("sbz_chem:water_fluid_cell") end
            local inv = user:get_inventory()
            if inv:room_for_item("main", "sbz_chem:water_fluid_cell") then
                inv:add_item("main", "sbz_chem:water_fluid_cell")
            else
                minetest.add_item(user:get_pos(), "sbz_chem:water_fluid_cell")
            end
            return itemstack
        end
        minetest.item_place(ItemStack("sbz_resources:matter_dust"), user, pointed)
    end
})

minetest.register_craft({
    output = "sbz_chem:empty_fluid_cell",
    recipe = {
        { "",                     "sbz_resources:pebble", "" },
        { "sbz_resources:pebble", "",                     "sbz_resources:pebble" },
        { "",                     "sbz_resources:pebble", "" }
    }
})

-- Water (H₂O)
minetest.register_craftitem("sbz_chem:water_fluid_cell", {
    description = "Water Fluid Cell (H₂O)",
    inventory_image = "fluid_cell.png^[fill:1x4:6,5:#87CEEB",
    on_place = function(itemstack, user, pointed)
        local _, pos = minetest.item_place_node(ItemStack("sbz_resources:water_source"), user, pointed)
        if pos then
            itemstack:take_item()
            if itemstack:is_empty() then return ItemStack("sbz_chem:empty_fluid_cell") end
            local inv = user:get_inventory()
            if inv:room_for_item("main", "sbz_chem:empty_fluid_cell") then
                inv:add_item("main", "sbz_chem:empty_fluid_cell")
            else
                minetest.add_item(user:get_pos(), "sbz_chem:empty_fluid_cell")
            end
            return itemstack
        end
        minetest.item_place(ItemStack("sbz_resources:matter_dust"), user, pointed)
    end
})
