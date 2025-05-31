-- Melter and cooler
-- Melter: [Block] -> [Block's liquid form]
-- cooler: [Liquid] -> [Block]
--[[
    Conveying recipes:
    They will be unified inventory recipes with the count ending in `kL`, example: 500kL of water
    Yeah
]]

unified_inventory.register_craft_type("melting", {
    description = "Melting",
    icon = "melter.png",
    width = 1,
    height = 1,
    uses_crafting_grid = false,
})

unified_inventory.register_craft_type("cooling", {
    description = "Cooling",
    icon = "cooler.png",
    width = 1,
    height = 1,
    uses_crafting_grid = false,
})

for source, fluid_cell in pairs(sbz_api.sources2fluid_cells) do
    local def = core.registered_items[fluid_cell]
    local item = ItemStack(def.cooled_form)

    local source_stack = ItemStack(def.liquid_form)
    source_stack:get_meta():set_string("count_meta", "1kL")

    unified_inventory.register_craft {
        type = "melting",
        output = source_stack,
        items = { item }
    }

    unified_inventory.register_craft {
        type = "cooling",
        output = item,
        items = { source_stack }
    }
end



sbz_api.register_stateful_machine("sbz_chem:melter", {
    description = "Melter",
    info_extra = "Melts blocks into liquids",
    tiles = {
        "hpef_top.png",
        "hpef_top.png",
        "hpef_top.png",
        "hpef_top.png",
        "hpef_top.png",
        "hpef_front_off.png",
    },
    groups = { matter = 1 },
    paramtype2 = "4dir",

    input_inv = "src",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("src", 1)

        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[current_player;main;0.2,5;8,4;]
list[context;src;2.5,2;1,1;]
box[5,2,.9,.9;black#8]
item_image[5,2;.9,.9;]
listring[]
    ]])
    end,
    after_place_node = pipeworks.after_place,
    autostate = true,
    action = function(pos, node, meta, supply, demand)
        local power_needed = 15
        local inv = meta:get_inventory()

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            return power_needed, false
        else
            meta:set_string("infotext", "Smelting...")

            local src = inv:get_list("src")

            local out, decremented_input, index
            for i = 1, 4 do
                local out_inner, decremented_input_inner = minetest.get_craft_result({
                    method = "cooking",
                    width = 1,
                    items = { src[i] },
                })
                if not out_inner.item:is_empty() then
                    out, decremented_input = out_inner, decremented_input_inner
                    index = i
                    break
                end
            end
            if out == nil then
                meta:set_string("infotext", "Invalid/no recipe")
                return 0
            end

            if not inv:room_for_item("dst", out.item) then
                meta:set_string("infotext", "Full")
                return 0
            end

            inv:set_stack("src", index, decremented_input.items[1])
            inv:add_item("dst", out.item)
            sbz_api.play_sfx({ name = "simple_alloy_furnace_running", gain = 0.6 }, { pos = pos })
            return power_needed
        end
    end,
}, {
    tiles = {
        "hpef_top.png",
        "hpef_top.png",
        "hpef_top.png",
        "hpef_top.png",
        "hpef_top.png",
        { name = "hpef_front.png", animation = { type = "vertical_frames", length = 0.7 } },
    },
    light_source = 10,
})

minetest.register_craft({
    output = "sbz_chem:high_power_electric_furnace",
    recipe = {
        { "sbz_power:simple_charged_field", "sbz_resources:matter_dust",       "sbz_power:simple_charged_field" },
        { "sbz_resources:matter_blob",      "sbz_resources:emittrium_circuit", "sbz_resources:matter_blob" },
        { "sbz_power:simple_charged_field", "sbz_chem:tin_powder",             "sbz_power:simple_charged_field" }
    }
})
