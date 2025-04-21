sbz_api.register_stateful_machine("sbz_chem:pebble_enhancer", {
    description = "Pebble Enhancer",
    info_extra = "Makes shiny, potentially radioactive pebbles.",
    tiles = {
        "pebble_enhancer_top.png",
        "pebble_enhancer_side.png"
    },
    groups = { matter = 1, weak_radioactive = 80 },

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
    info_power_consume = 128,
    autostate = true,
    action = function(pos, node, meta, supply, demand)
        local power_needed = 128
        local inv = meta:get_inventory()

        local itemname = inv:get_stack("input", 1):get_name()

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            return power_needed, false
        end

        if itemname == "sbz_resources:pebble" and inv:room_for_item("output", "sbz_chem:enhanced_pebble") then
            inv:remove_item("input", itemname)
            inv:add_item("output", "sbz_chem:enhanced_pebble")
            meta:set_string("infotext", "Enhancing...")
            return power_needed
        end
        meta:set_string("infotext", "Inactive")
        return 0
    end,
    input_inv = "input",
    output_inv = "output",
}, {
    tiles = {
        { name = "pebble_enhancer_top_on.png", animation = { type = "vertical_frames", length = 0.5 } },
        "pebble_enhancer_side.png"
    },
    light_source = 14,
})



minetest.register_craft({
    output = "sbz_chem:pebble_enhancer",
    recipe = {
        { "sbz_chem:uranium_crystal",  "sbz_chem:uranium_crystal",         "sbz_chem:uranium_crystal", },
        { "sbz_resources:matter_blob", "sbz_resources:phlogiston_circuit", "sbz_resources:matter_blob" },
        { "sbz_chem:thorium_crystal",  "sbz_chem:thorium_crystal",         "sbz_chem:thorium_crystal", }
    }
})
