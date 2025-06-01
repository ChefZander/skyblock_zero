sbz_api.sources2fluid_cells = {}
sbz_api.fluid_cells2sources = {}
local empty_cell = "sbz_chem:empty_fluid_cell"

function sbz_api.register_fluid_cell(name, def, source_name, cellcolor)
    sbz_api.sources2fluid_cells[source_name] = name
    sbz_api.fluid_cells2sources[name] = source_name
    def.liquids_pointable = true
    def.groups = def.groups or {}
    def.groups.chem_element = 1
    def.groups.no_chem_ui = 1
    if cellcolor then
        def.inventory_image = "fluid_cell.png^[fill:1x4:6,5:" .. cellcolor
    end
    def.on_place = function(itemstack, user, pointed)
        if pointed.type ~= "node" then return end
        local _, pos = minetest.item_place_node(ItemStack(source_name), user, pointed)
        if pos then
            itemstack:take_item()
            if itemstack:is_empty() then return ItemStack(empty_cell) end
            local inv = user:get_inventory()
            if inv:room_for_item("main", empty_cell) then
                inv:add_item("main", empty_cell)
            else
                minetest.add_item(user:get_pos(), empty_cell)
            end
            return itemstack
        end
        minetest.item_place(ItemStack("sbz_resources:matter_dust"), user, pointed) -- this is to handle callbacks - idealist
    end
    minetest.register_craftitem(name, def)
end

-- Empty
minetest.register_craftitem(empty_cell, {
    description = "Empty Fluid Cell (Empty)",
    inventory_image = "fluid_cell.png",
    liquids_pointable = true,
    groups = { chem_element = 1 },
    on_place = function(itemstack, user, pointed)
        if pointed.type ~= "node" then return end
        local node = minetest.get_node(pointed.under)
        local fluid_cell = sbz_api.sources2fluid_cells[node.name]
        if fluid_cell then
            minetest.remove_node(pointed.under)
            itemstack:take_item()
            if itemstack:is_empty() then return ItemStack(fluid_cell) end
            local inv = user:get_inventory()
            if inv:room_for_item("main", fluid_cell) then
                inv:add_item("main", fluid_cell)
            else
                minetest.add_item(user:get_pos(), fluid_cell)
            end
            return itemstack
        end
        minetest.item_place(ItemStack("sbz_resources:matter_dust"), user, pointed)
    end
})

minetest.register_craft({
    output = empty_cell,
    recipe = {
        { "",                     "sbz_resources:pebble", "" },
        { "sbz_resources:pebble", "",                     "sbz_resources:pebble" },
        { "",                     "sbz_resources:pebble", "" }
    }
})

sbz_api.register_fluid_cell("sbz_chem:water_fluid_cell", {
    description = "Water Fluid Cell (H₂O)",
    cooled_form = "sbz_planets:ice",
    liquid_form = "sbz_resources:water_source"
}, "sbz_resources:water_source", "#87CEEB")
