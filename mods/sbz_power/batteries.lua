function sbz_power.register_battery(name, def)
    for k, v in pairs { sbz_battery = 1, sbz_machine = 1, pipe_connects = 1, pipe_conducts = 1 } do
        def.groups[k] = v
    end

    local max = def.battery_max
    def.action = function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_string("infotext",
            string.format("Battery: %s/%s power", sbz_power.round_power(current_power), sbz_power.round_power(max)))
        meta:set_string("formspec",
            sbz_power.battery_fs(sbz_power.round_power(current_power), sbz_power.round_power(max)))
    end
    minetest.register_node(name, def)
end

sbz_power.register_battery("sbz_power:battery", {
    description = "Battery",
    tiles = { "battery.png" },
    groups = { matter = 1 },
    battery_max = sbz_power.cjh2cj(1),
})

minetest.register_craft({
    output = "sbz_power:battery",
    recipe = {
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob",       "sbz_resources:matter_blob" },
        { "sbz_power:power_pipe",      "sbz_resources:emittrium_circuit", "sbz_resources:matter_blob" },
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob",       "sbz_resources:matter_blob" }
    }
})

sbz_power.register_battery("sbz_power:advanced_battery", {
    description = "Advanced Battery",
    tiles = { "advanced_battery.png" },
    groups = { matter = 1 },
    battery_max = sbz_power.cjh2cj(5),
})


minetest.register_craft({
    output = "sbz_power:advanced_battery",
    recipe = {
        { "sbz_chem:cobalt_ingot",  "sbz_chem:lithium_ingot", "sbz_chem:cobalt_ingot" },
        { "sbz_chem:lithium_ingot", "sbz_chem:lithium_ingot", "sbz_chem:lithium_ingot" },
        { "sbz_chem:cobalt_ingot",  "sbz_chem:lithium_ingot", "sbz_chem:cobalt_ingot" }
    }
})

minetest.register_node("sbz_power:creative_battery", {
    description = "Creative Battery",
    tiles = { "creative_battery.png" },
    groups = { sbz_battery = 1, sbz_machine = 1, matter = 1, pipe_conducts = 1, pipe_connects = 1 },
    battery_max = 10000000, -- 10 mil
    action = function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_int("power", 10000000)
        meta:set_string("infotext", string.format("Creative Battery: Infinite power"))
    end,
    info_extra = "Generates power too....",
})
