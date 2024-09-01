local BATTERY_MAX_POWER = 300

minetest.register_node("sbz_power:battery", {
    description = "Battery",
    tiles = { "battery.png" },
    groups = { sbz_battery = 1, sbz_machine = 1, matter = 1, pipe_connects = 1, pipe_conducts = 0 },
    battery_max = BATTERY_MAX_POWER,
    action = function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_string("infotext", string.format("Battery: %s/%s power", current_power, BATTERY_MAX_POWER))
    end
})

minetest.register_craft({
    output = "sbz_power:battery",
    recipe = {
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob",       "sbz_resources:matter_blob" },
        { "sbz_power:power_pipe",      "sbz_resources:emittrium_circuit", "sbz_resources:matter_blob" },
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob",       "sbz_resources:matter_blob" }
    }
})

minetest.register_node("sbz_power:advanced_battery", {
    description = "Advanced Battery",
    tiles = { "advanced_battery.png" },
    groups = { sbz_battery = 1, sbz_machine = 1, matter = 1, pipe_connects = 1, pipe_conducts = 0 },
    battery_max = BATTERY_MAX_POWER * 3,
    action = function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_string("infotext", string.format("Advanced Battery: %s/%s power", current_power, BATTERY_MAX_POWER * 3))
    end
})

minetest.register_craft({
    output = "sbz_power:advanced_battery",
    recipe = {
        { "sbz_resources:matter_blob", "sbz_chem:lithium_ingot", "sbz_resources:matter_blob" },
        { "sbz_chem:lithium_ingot",    "sbz_power:battery",      "sbz_chem:lithium_ingot" },
        { "sbz_resources:matter_blob", "sbz_chem:lithium_ingot", "sbz_resources:matter_blob" }
    }
})

minetest.register_node("sbz_power:creative_battery", {
    description = "Creative Battery",
    tiles = { "creative_battery.png" },
    groups = { sbz_battery = 1, sbz_machine = 1, matter = 1, pipe_conducts = 1, pipe_connects = 0 },
    battery_max = 10000000, -- 10 mil
    action = function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_int("power", 10000000)
        meta:set_string("infotext", string.format("Creative Battery: Infinite power"))
    end,
    info_extra = "Generates power too....",
})
