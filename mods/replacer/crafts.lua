local r = replacer

-- really overpowered tool... so... complicated recipe :D
core.register_craft {
    output = "replacer:replacer",
    recipe = {
        { "sbz_resources:movable_emitter", "sbz_logic_devices:builder",       "sbz_bio:colorium_emitter" },
        { "",                              "sbz_power:very_advanced_battery", "" },
        { "",                              "sbz_power:very_advanced_battery", "" }
    }
}
