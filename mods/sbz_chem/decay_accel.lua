sbz_api.register_stateful_machine("sbz_chem:decay_accel", {
    description = "Decay Accelerator",
    tiles = {
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel_front.png",
    },
    groups = { matter = 1 },
    info_extra = "It doesn't just accelerate decay, it may throw in some neutrons.",
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
    info_power_consume = 64,
    autostate = true,
    action = function(pos, node, meta, supply, demand)
        local power_needed = 64
        local inv = meta:get_inventory()

        local out, count, decremented = sbz_api.recipe.resolve_craft(inv:get_stack("input", 1), "decay_accelerating",
            false)

        if out == 0 then
            meta:set_string("infotext", "Inactive")
            return 0
        end

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            return power_needed, false
        end

        meta:set_string("infotext", "Active")

        if inv:room_for_item("output", out) then
            local input = inv:get_stack("input", 1)
            input:set_count(input:get_count() - decremented)
            inv:set_stack("input", 1, input)
            inv:add_item("output", out)
            return power_needed
        else
            meta:set_string("infotext", "Output inventory full")
            return 0
        end
    end,
    input_inv = "input",
    output_inv = "output",
}, {
    tiles = {
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        { name = "decay_accel_front_on.png", animation = { type = "vertical_frames", length = 1 } },
    },
    light_source = 14,
})


minetest.register_craft({
    output = "sbz_chem:decay_accel_off",
    recipe = {
        { "sbz_chem:uranium_crystal",         "sbz_resources:matter_blob", "sbz_chem:thorium_crystal" },
        { "sbz_resources:reinforced_matter",  "",                          "sbz_resources:reinforced_matter" },
        { "sbz_resources:phlogiston_circuit", "sbz_meteorites:neutronium", "sbz_resources:phlogiston_circuit" }
    }
})
