local output_items = sbz_api.crusher_drops

for k, v in pairs(output_items) do
    unified_inventory.register_craft {
        output = v,
        type = "crushing",
        items = {
            "sbz_resources:pebble"
        }
    }
end

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


        minetest.sound_play("machine_build", {
            gain = 1.0,
            pos = pos,
        })
    end,
    on_rightclick = function(pos, node, player, pointed_thing)
        local player_name = player:get_player_name()
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;output;3.5,0.5;4,4;]
list[context;input;1,2;1,1;]
list[current_player;main;0.2,5;8,4;]
listring[current_player;main]listring[context;input]listring[current_player;main]listring[context;output]listring[current_player;main]
]])

        minetest.sound_play("machine_open", {
            to_player = player_name,
            gain = 1.0,
            pos = pos
        })
    end,

    info_power_consume = 5,
    autostate = true,
    action = function(pos, node, meta, supply, demand)
        local power_needed = 5
        local inv = meta:get_inventory()

        local itemname = inv:get_stack("input", 1):get_name()

        local recipe_outputs = unified_inventory.get_usage_list(itemname)


        local possible_outputs = {}

        for k, v in pairs(recipe_outputs or {}) do
            if v.type == "crushing" then
                possible_outputs[#possible_outputs + 1] = v.output
            end
        end

        if #possible_outputs == 0 then
            meta:set_string("infotext", "Inactive")
            return 0
        end

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            return power_needed, false
        end

        meta:set_string("infotext", "Crushing...")
        inv:remove_item("input", itemname)
        minetest.sound_play({ name = "050597_ice-crusher-38522", gain = 0.4 }, { pos = pos })

        local selected_item = possible_outputs[math.random(1, #possible_outputs)]


        if inv:room_for_item("output", selected_item) then
            inv:add_item("output", selected_item)
        else
            meta:set_string("infotext", "Output inventory full")
            return 0
        end
        if itemname == "sbz_resources:pebble" then
            if inv:contains_item("output", "sbz_chem:empty_fluid_cell") then
                inv:remove_item("output", "sbz_chem:empty_fluid_cell")
                if inv:room_for_item("output", "sbz_chem:water_fluid_cell") then
                    inv:add_item("output", "sbz_chem:water_fluid_cell")
                else
                    minetest.add_item(pos, "sbz_chem:water_fluid_cell")
                end
            end
        end

        return power_needed
    end,
    input_inv = "input",
    output_inv = "output",
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
