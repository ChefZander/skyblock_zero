function sbz_power.register_battery(name, def)
    for k, v in pairs { sbz_battery = 1, sbz_machine = 1, pipe_connects = 1, pipe_conducts = 1 } do
        def.groups[k] = v
    end

    local max = def.battery_max
    def.action = def.action or function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_string("infotext",
            string.format("Battery: %s power", sbz_api.format_power(current_power, max)))
        meta:set_string("formspec",
            sbz_power.battery_fs(sbz_power.round_power(current_power), sbz_power.round_power(max)))
    end
    minetest.register_node(name, def)
end

sbz_power.register_battery("sbz_power:battery", {
    description = "Battery",
    tiles = { "battery.png" },
    groups = { matter = 1 },
    battery_max = 5000,
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
    battery_max = 20000,
})
minetest.register_craft({
    output = "sbz_power:advanced_battery",
    recipe = {
        { "sbz_chem:cobalt_ingot",  "sbz_chem:lithium_ingot", "sbz_chem:cobalt_ingot" },
        { "sbz_chem:lithium_ingot", "sbz_chem:lithium_ingot", "sbz_chem:lithium_ingot" },
        { "sbz_chem:cobalt_ingot",  "sbz_chem:lithium_ingot", "sbz_chem:cobalt_ingot" }
    }
})

sbz_power.register_battery("sbz_power:very_advanced_battery", {
    description = "Very Advanced Battery",
    info_extra = "Description is so original, i am aware.",
    tiles = { "very_advanced_battery.png" },
    groups = { matter = 1, level = 2 },
    battery_max = 200000,
})

minetest.register_craft({
    output = "sbz_power:very_advanced_battery",
    recipe = {
        { "sbz_chem:cobalt_block",  "sbz_chem:lithium_block", "sbz_chem:cobalt_block" },
        { "sbz_chem:lithium_block", "sbz_chem:lithium_block", "sbz_chem:lithium_block" },
        { "sbz_chem:cobalt_block",  "sbz_chem:lithium_block", "sbz_chem:cobalt_block" }
    }
})

core.register_node("sbz_power:creative_battery", {
    description = "Creative Power Generating Battery",
    info_extra =
    "It never runs out of power... useful for when you need to not have noise in your \"Supply\" statistic in the switching station.",
    tiles = { { name = "creative_battery_power_gen.png", animation = { type = "vertical_frames", length = 0.5 }, } },
    groups = { creative = 1, sbz_battery = 1, sbz_machine = 1, pipe_conducts = 1, pipe_connects = 1 },
    battery_max = 10 ^ 9, -- G
    action = function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_int("power", 10 ^ 9)
        meta:set_string("infotext", "Creative Power Generating Battery")
    end,
})

core.register_node("sbz_power:real_creative_battery", {
    description = "Creative Battery",
    tiles = { "creative_battery.png" },
    groups = { creative = 1, sbz_battery = 1, sbz_machine = 1, pipe_conducts = 1, pipe_connects = 1 },
    battery_max = 10 ^ 9, -- G
    action = function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_string("infotext", string.format("Creative Battery: %s / 1 GCj", sbz_api.format_power(current_power)))
    end,
})
