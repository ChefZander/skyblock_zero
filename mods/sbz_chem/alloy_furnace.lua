local simple_alloy_furnace_recipes = {
    {recipe = {"sbz_chem:copper_powder", "sbz_chem:tin_powder"}, output = {"sbz_chem:bronze_powder"}},
    {recipe = {"sbz_chem:copper_powder", "sbz_chem:zinc_powder"}, output = {"sbz_chem:brass_powder"}},
    {recipe = {"sbz_chem:iron_powder", "sbz_chem:nickel_powder"}, output = {"sbz_chem:invar_powder"}},
    {recipe = {"sbz_chem:titanium_powder", "sbz_chem:aluminum_powder"}, output = {"sbz_chem:titanium_alloy_powder"}},
    {recipe = {"sbz_chem:gold_powder", "sbz_chem:nickel_powder"}, output = {"sbz_chem:white_gold_powder"}},
}

sbz_api.register_machine("sbz_chem:simple_alloy_furnace",{
    description = "Simple Alloy Furnace",
    tiles = {
        {name="simple_alloy_furnace.png", animation={type="vertical_frames", length = 0.7}}
    },
    groups = {matter =1},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 2)
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
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";input;3,1;2,1;]" ..
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
        local power_needed = 10
        local inv = meta:get_inventory()

        local input_1 = inv:get_stack("input", 1):get_name()
        local input_2 = inv:get_stack("input", 2):get_name()

        local function is_valid_recipe(input1, input2)
            for _, recipe in ipairs(simple_alloy_furnace_recipes) do
                local r = recipe.recipe
                if (input1 == r[1] and input2 == r[2]) or (input1 == r[2] and input2 == r[1]) then
                    return recipe.output[1]
                end
            end
            return nil
        end

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
