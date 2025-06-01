sbz_api.recipe.register_craft_type({
    type = "crushing",
    description = "Crushing",
    icon = "crusher_top.png^[verticalframe:4:1",
    single = true,
})

for k, v in pairs(sbz_api.crusher_drops) do
    sbz_api.recipe.register_craft {
        output = v,
        type = "crushing",
        items = {
            "sbz_resources:pebble"
        }
    }
end

core.register_craftitem("sbz_chem:enhanced_pebble", {
    description = "Enhanced Pebble",
    inventory_image = "enhanced_pebble.png",
})

for k, v in pairs(sbz_api.crusher_drops_enhanced) do
    sbz_api.recipe.register_craft {
        output = v,
        type = "crushing",
        items = {
            "sbz_chem:enhanced_pebble"
        }
    }
end

-- stone -> 2 gravel
-- gravel -> 2 sand
-- centrifuging sand: 90% chance of 4 Silicon, 10% chance of 1 gold
sbz_api.recipe.register_craft {
    output = "sbz_resources:gravel 2",
    type = "crushing",
    items = {
        "sbz_resources:stone"
    }
}

sbz_api.recipe.register_craft {
    output = "sbz_resources:sand 2",
    type = "crushing",
    items = {
        "sbz_resources:gravel"
    }
}

sbz_api.recipe.register_craft {
    output = "sbz_resources:dust 2",
    type = "crushing",
    items = {
        "sbz_resources:sand"
    }
}


local crusher_power_consume = 5
sbz_api.register_stateful_machine("sbz_chem:crusher", {
    description = "Crusher",
    tiles = {
        "crusher_top.png^[verticalframe:4:1",
        "crusher_side.png"
    },
    groups = { matter = 1 },

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 1)
        inv:set_size("output", 16)

        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;output;3.5,0.5;4,4;]
list[context;input;1,2;1,1;]
list[current_player;main;0.2,5;8,4;]
listring[current_player;main]listring[context;input]listring[current_player;main]listring[context;output]listring[current_player;main]
]])
    end,
    info_power_consume = crusher_power_consume,
    autostate = true,
    action = function(pos, node, meta, supply, demand)
        local inv = meta:get_inventory()
        local itemname = inv:get_stack("input", 1):get_name()

        local out, count, decremented = sbz_api.recipe.resolve_craft(inv:get_stack("input", 1), "crushing", false)

        if out == nil then
            meta:set_string("infotext", "Inactive")
            return 0
        end

        if demand + crusher_power_consume > supply then
            meta:set_string("infotext", "Not enough power")
            return crusher_power_consume, false
        end

        meta:set_string("infotext", "Crushing...")
        sbz_api.play_sfx({ name = "050597_ice-crusher-38522" }, { pos = pos, max_hear_distance = 8, gain = 0.8 })

        -- if itemname == "sbz_resources:sand" and inv:contains_item("output", "sbz_chem:water_fluid_cell") then
        --     inv:remove_item("input", itemname)
        --     inv:remove_item("output", "sbz_chem:water_fluid_cell")
        --     inv:add_item("output", "sbz_resources:clay")

        --     if inv:room_for_item("output", "sbz_chem:empty_fluid_cell") then
        --         inv:add_item("output", "sbz_chem:empty_fluid_cell")
        --     else
        --         minetest.add_item(pos, "sbz_chem:empty_fluid_cell")
        --     end

        --     return crusher_power_consume
        -- end

        if inv:room_for_item("output", out) then
            local input = inv:get_stack("input", 1)
            input:set_count(input:get_count() - decremented)
            inv:set_stack("input", 1, input)
            inv:add_item("output", out)
        else
            meta:set_string("infotext", "Output inventory full")
            return 0
        end
        if itemname == "sbz_resources:pebble" then -- HACK: FIXME: TODO: WHATEVER: THIS IS HORRIBLE
            if inv:contains_item("output", "sbz_chem:empty_fluid_cell") then
                inv:remove_item("output", "sbz_chem:empty_fluid_cell")
                if inv:room_for_item("output", "sbz_chem:water_fluid_cell") then
                    inv:add_item("output", "sbz_chem:water_fluid_cell")
                else
                    minetest.add_item(pos, "sbz_chem:water_fluid_cell")
                end
            end
        end

        return crusher_power_consume
    end,
    input_inv = "input",
    output_inv = "output",
    --[[
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "output" then
            if stack:get_name() == "sbz_chem:empty_fluid_cell" then
                return stack:get_count()
            else
                return 0
            end
        end
        return stack:get_count()
    end
    --]]
}, {
    tiles = {
        { name = "crusher_top.png", animation = { type = "vertical_frames", length = 0.5 } },
        "crusher_side.png"
    },
    light_source = 3,
})


minetest.register_craft({
    output = "sbz_chem:crusher",
    recipe = {
        { "sbz_power:simple_charged_field", "sbz_resources:antimatter_dust", "sbz_power:simple_charged_field" },
        { "sbz_resources:matter_blob",      "sbz_resources:stone",           "sbz_resources:matter_blob" },
        { "sbz_power:simple_charged_field", "sbz_resources:matter_blob",     "sbz_power:simple_charged_field" }
    }
})
