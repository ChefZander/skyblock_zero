sbz_api.register_machine("sbz_chem:crusher", {
    description = "Crusher",
    tiles = {
        { name = "crusher_top.png", animation = { type = "vertical_frames", length = 0.5 } },
        "crusher_side.png"
    },
    groups = { matter = 1 },

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 1)
        inv:set_size("output", 16)


        minetest.sound_play("machine_build", {
            to_player = player_name,
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
item_image[0.9,1.9;1,1;sbz_resources:pebble]
list[context;output;3.5,0.5;4,4;]
list[context;input;1,2;1,1;]
list[current_player;main;0.2,5;8,4;]
listring[]
]]
        )

        minetest.sound_play("machine_open", {
            to_player = player_name,
            gain = 1.0,
            pos = pos
        })
    end,

    control_action_raw = true,
    info_power_consume = 5,
    action = function(pos, node, meta, supply, demand)
        local power_needed = 5
        local inv = meta:get_inventory()

        if not inv:contains_item("input", "sbz_resources:pebble") then
            meta:set_string("infotext", "Inactive")
            return 0
        end

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            return power_needed
        else
            meta:set_string("infotext", "Crushing...")

            inv:remove_item("input", "sbz_resources:pebble")

            minetest.sound_play({ name = "050597_ice-crusher-38522", gain = 0.4 }, { pos = pos })

            local output_items = {
                "sbz_chem:gold_powder",
                "sbz_chem:silver_powder",
                "sbz_chem:iron_powder",
                "sbz_chem:copper_powder",
                "sbz_chem:aluminum_powder",
                "sbz_chem:lead_powder",
                "sbz_chem:zinc_powder",
                "sbz_chem:tin_powder",
                "sbz_chem:nickel_powder",
                "sbz_chem:platinum_powder",
                "sbz_chem:mercury_powder",
                "sbz_chem:cobalt_powder",
                "sbz_chem:titanium_powder",
                "sbz_chem:magnesium_powder",
                "sbz_chem:calcium_powder",
                "sbz_chem:sodium_powder",
                "sbz_chem:lithium_powder"
            }

            local random_index = math.random(1, #output_items)
            local selected_item = output_items[random_index]

            if inv:room_for_item("output", selected_item) then
                inv:add_item("output", selected_item)
            else
                meta:set_string("infotext", "Output inventory full")
                return power_needed
            end

            return power_needed
        end
    end,
    input_inv = "input",
    output_inv = "output"
})


minetest.register_craft({
    output = "sbz_chem:crusher",
    recipe = {
        { "sbz_power:simple_charged_field", "sbz_resources:antimatter_dust", "sbz_power:simple_charged_field" },
        { "sbz_resources:matter_blob",      "sbz_resources:stone",           "sbz_resources:matter_blob" },
        { "sbz_power:simple_charged_field", "sbz_resources:matter_blob",     "sbz_power:simple_charged_field" }
    }
})
