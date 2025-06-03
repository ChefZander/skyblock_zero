-- Melter and cooler
-- Melter: [Block] -> [Block's liquid form]
-- cooler: [Liquid] -> [Block]
--[[
    Conveying recipes:
    They will be unified inventory recipes with the count ending in `kL`, example: 500kL of water
    Yeah
]]

sbz_api.recipe.register_craft_type({
    type = "melting",
    description = "Melting",
    icon = "melter_front_off.png",
    single = true
})


sbz_api.recipe.register_craft_type({
    type = "cooling",
    description = "Cooling",
    icon = "cooler_front_off.png",
    single = true
})


for source, fluid_cell in pairs(sbz_api.sources2fluid_cells) do
    local def = core.registered_items[fluid_cell]
    local item = ItemStack(def.cooled_form)

    local source_stack = ItemStack(def.liquid_form)
    source_stack:get_meta():set_string("count_meta", "1kL")

    sbz_api.recipe.register_craft {
        type = "melting",
        output = source_stack,
        items = { item }
    }

    sbz_api.recipe.register_craft {
        type = "cooling",
        output = item,
        items = { source_stack }
    }
end



sbz_api.register_stateful_machine("sbz_chem:melter", {
    description = "Melter",
    info_extra = "Melts blocks into liquids",
    tiles = {
        "melter_top.png",
        "melter_top.png",
        "melter_top.png",
        "melter_top.png",
        "melter_top.png",
        "melter_front_off.png",
    },
    groups = {
        matter = 1,
        fluid_pipe_connects = 1,
        fluid_pipe_stores = 1,
        ui_fluid = 1
    },
    paramtype2 = "4dir",

    input_inv = "src",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("src", 1)

        meta:set_string("liquid_inv", minetest.serialize({
            max_count_in_each_stack = 10,
            [1] = {
                name = "any",
                count = 0,
                can_change_name = true,
            },
        }))

        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[current_player;main;0.2,5;8,4;]
list[context;src;2.5,2;1,1;]
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
            local out, count, decremented = sbz_api.recipe.resolve_craft(inv:get_stack("src", 1), "melting", false)

            if out == nil then
                meta:set_string("infotext", "Invalid/no recipe")
                return 0
            end

            local lqinv = core.deserialize(meta:get_string("liquid_inv"))
            local slot = lqinv[1]

            if slot.name ~= out:get_name() and slot.name ~= "any" then
                meta:set_string("infotext",
                    "Cannot melt, there is already " .. slot.name .. " in the melter, have one melter for each metal.")
                return 0
            end

            if slot.count >= lqinv.max_count_in_each_stack then
                meta:set_string("infotext", "Full")
                return 0
            end

            local src = inv:get_stack("src", 1)
            src:set_count(src:get_count() - decremented)
            inv:set_stack("src", 1, src)

            slot.count = slot.count + out:get_count()
            slot.name = out:get_name()
            meta:set_string("liquid_inv", core.serialize(lqinv)) -- EWWW: TODO: re-work the entire liquid inventory system to not use this stupid serialize crap
            meta:set_string("infotext", "Melting - Inside: " .. slot.count .. " " .. slot.name)

            sbz_api.play_sfx({ name = "simple_alloy_furnace_running", gain = 0.6 }, { pos = pos })
            return power_needed
        end
    end,
}, {
    tiles = {
        "melter_top.png",
        "melter_top.png",
        "melter_top.png",
        "melter_top.png",
        "melter_top.png",
        { name = "melter_front_on.png", animation = { type = "vertical_frames", length = 1 } },
    },
    light_source = 14,
})

sbz_api.register_stateful_machine("sbz_chem:cooler", {
    description = "Cooler",
    info_extra = "Cools down liquids into blocks",
    tiles = {
        "cooler_top.png",
        "cooler_top.png",
        "cooler_top.png",
        "cooler_top.png",
        "cooler_top.png",
        "cooler_front_off.png",
    },
    groups = {
        matter = 1,
        fluid_pipe_connects = 1,
        fluid_pipe_stores = 1,
        ui_fluid = 1
    },
    paramtype2 = "4dir",

    output_inv = "dst",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("dst", 1)

        meta:set_string("liquid_inv", minetest.serialize({
            max_count_in_each_stack = 10,
            [1] = {
                name = "any",
                count = 0,
                can_change_name = true,
            },
        }))

        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[current_player;main;0.2,5;8,4;]
list[context;dst;4.5,2;1,1;]
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
            local lqinv = core.deserialize(meta:get_string("liquid_inv"))

            local slot = lqinv[1]

            if slot.name == "any" or slot.count <= 0 then
                meta:set_string("infotext", "There is nothing to cool")
                return 0
            end

            local out, count, decremented = sbz_api.recipe.resolve_craft(ItemStack(slot.name), "cooling", false)

            if out == nil then
                meta:set_string("infotext", "Invalid/no recipe")
                return 0
            end

            if not inv:room_for_item("dst", out) then
                meta:set_string("infotext", "Full")
                return 0
            end

            inv:add_item("dst", out)

            slot.count = slot.count - decremented

            meta:set_string("liquid_inv", core.serialize(lqinv)) -- EWWW: TODO: re-work the entire liquid inventory system to not use this stupid serialize crap
            meta:set_string("infotext", "Cooling - Inside: " .. slot.count .. " " .. slot.name)

            sbz_api.play_sfx({ name = "simple_alloy_furnace_running", gain = 0.6 }, { pos = pos })
            return power_needed
        end
    end,
}, {
    tiles = {
        "cooler_top.png",
        "cooler_top.png",
        "cooler_top.png",
        "cooler_top.png",
        "cooler_top.png",
        { name = "cooler_front_on.png", animation = { type = "vertical_frames", length = 1 } },
    },
    light_source = 14,
})
