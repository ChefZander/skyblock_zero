local hpef_recipes = {
    {recipe = {"sbz_chem:copper_powder"}, output = {"sbz_chem:bronze_powder"}},
}

sbz_api.register_machine("sbz_chem:high_power_electric_furnace",{
    description = "High Power Electric Furnace",
    tiles = {
        {name="simple_alloy_furnace.png", animation={type="vertical_frames", length = 0.7}} -- this needs update TODO
    },
    groups = {matter =1},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 1)
        inv:set_size("output", 1)


        minetest.sound_play("machine_build", {
            to_player = player_name,
            gain = 1.0,
        })
    end,
    on_rightclick = function(pos, node, player, pointed_thing)
        local player_name = player:get_player_name()
        minetest.show_formspec(player_name, "sbz_resources:simple_alloy_furnace_formspec",
            "formspec_version[7]" ..
            "size[8.2,9]" ..
            "style_type[list;spacing=.2;size=.8]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";input;3.5,1;1,1;]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";output;3.5,3;1,1;]" ..
            "list[current_player;main;0.2,5;8,4;]" ..
            "listring[]")

        minetest.sound_play("machine_open", {
            to_player = player_name,
            gain = 1.0,
        })
    end,

    control_action_raw = true,
    action = function(pos, node, meta, supply, demand)
        local power_needed = 15
        local inv = meta:get_inventory()

        local input = inv:get_stack("input", 1):get_name()

        local selected_item = is_valid_recipe(input_1, input_2)
        if selected_item == nil then
            meta:set_string("infotext", "Inactive")
            return 0
        end

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            return power_needed
        else
            meta:set_string("infotext", "Smelting...")
            minetest.sound_play({name="simple_alloy_furnace_running", gain=0.6}, {pos=pos})

            if inv:room_for_item("output", selected_item) then
                inv:add_item("output", selected_item)
                inv:remove_item("input", input_1)
                inv:remove_item("input", input_2)
            else
                meta:set_string("infotext", "Output inventory full")
                return power_needed
            end

            return power_needed
        end
    end,
})

minetest.register_craft({
    output = "sbz_chem:simple_alloy_furnace",
    recipe = {
        { "sbz_power:simple_charged_field", "sbz_resources:antimatter_dust",    "sbz_power:simple_charged_field" },
        { "sbz_resources:matter_blob",          "sbz_resources:emittrium_circuit", "sbz_resources:matter_blob" },
        { "sbz_power:simple_charged_field", "sbz_resources:matter_blob",        "sbz_power:simple_charged_field" }
    }
})
