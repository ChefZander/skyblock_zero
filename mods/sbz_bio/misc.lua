minetest.register_node("sbz_bio:burner", sbz_api.add_tube_support({
    description = "Burner",
    tiles = { "burner.png" },
    groups = { matter = 1, co2_source = 1 },
    paramtype = "light",
    sounds = sbz_api.sounds.machine(),
    light_source = 5,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:get_inventory():set_size("main", 1)
        meta:set_string("formspec",
            "formspec_version[7]" ..
            "size[8.2,9]" ..
            "style_type[list;spacing=.2;size=.8]" ..
            "list[context;main;3.5,2;1,1;]" ..
            "list[current_player;main;0.2,5;8,4;]" ..
            "listring[]"
        )
    end,
    co2_action = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local itemstack = inv:get_stack("main", 1)
        if itemstack:is_empty() then return 0 end
        local output = minetest.get_item_group(itemstack:get_name(), "burn")
        if output == 0 then return 0 end
        itemstack:take_item()
        inv:set_stack("main", 1, itemstack)
        return output
    end,
    output_inv = "main",
    input_inv = "main",
})
)

minetest.register_craft({
    output = "sbz_bio:burner",
    recipe = {
        { "sbz_bio:pyrograss",         "sbz_resources:matter_blob",        "sbz_bio:pyrograss" },
        { "sbz_resources:matter_blob", "sbz_resources:matter_annihilator", "sbz_resources:matter_blob" },
        { "sbz_bio:pyrograss",         "sbz_resources:matter_blob",        "sbz_bio:pyrograss" }
    }
})

minetest.register_node("sbz_bio:airlock", {
    description = "Airlock",
    drawtype = "glasslike",
    tiles = { { name = "airlock.png^[opacity:192", animation = { type = "vertical_frames", length = 0.25 } } },
    use_texture_alpha = "blend",
    post_effect_color = "#a0ffff40",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = { matter = 1, transparent = 1 }
})

minetest.register_craft({
    output = "sbz_bio:airlock",
    recipe = {
        { "sbz_resources:emittrium_glass", "sbz_resources:emittrium_glass", "sbz_resources:emittrium_glass" },
        { "sbz_chem:titanium_ingot",       "sbz_chem:titanium_ingot",       "sbz_chem:titanium_ingot" },
        { "sbz_resources:emittrium_glass", "sbz_resources:emittrium_glass", "sbz_resources:emittrium_glass" }
    }
})

sbz_api.register_stateful_machine("sbz_bio:neutron_emitter", {
    description = "Basic Neutron Emitter",
    info_extra = "Emits radiation, forces plants mutate.",
    info_power_consume = 10,
    autostate = true,
    tiles = { "neutron_emitter_off.png" },
    action = function(pos, node, meta, supply, demand)
        if supply < demand + 10 then
            meta:set_string("infotext", "Not enough power")
            return 10, false
        else
            meta:set_string("infotext", "On")
            return 10, true
        end
    end,
    groups = {
        matter = 1,
    },
}, {
    light_source = 14,
    tiles = { { name = "neutron_emitter_on.png", animation = { type = "vertical_frames" } } },
    groups = { matter = 1, radioactive = 3 }
})

core.register_craft {
    output = "sbz_bio:neutron_emitter_off",
    recipe = {
        { "sbz_resources:emittrium_circuit", "sbz_bio:pyrograss",         "sbz_resources:emittrium_circuit" },
        { "sbz_bio:pyrograss",               "sbz_meteorites:neutronium", "sbz_bio:pyrograss" },
        { "sbz_resources:emittrium_circuit", "sbz_bio:pyrograss",         "sbz_resources:emittrium_circuit" },
    }
}
