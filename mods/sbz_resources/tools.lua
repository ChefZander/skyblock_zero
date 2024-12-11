-- Define a new pickaxe
minetest.register_tool("sbz_resources:matter_annihilator", {
    description = "Matter Annihilator",
    inventory_image = "matter_annihilator.png", -- Replace with your own image file

    groups = { core_drop_multi = 1 },
    -- Tool properties
    tool_capabilities = {
        full_punch_interval = 2.5,
        max_drop_level = 1,
        groupcaps = {
            matter = { times = { [1] = 3.00, [2] = 1.60, [3] = 0.90 }, uses = 10, maxlevel = 1 },
        },
    },

    sound = {
        punch_use = {
            name = "block_annihilated",
            gain = 1,
        }
    },
})
minetest.register_craft({
    output = "sbz_resources:matter_annihilator",
    recipe = {
        { "",                          "sbz_resources:antimatter_dust",  "" },
        { "sbz_resources:matter_blob", "sbz_resources:charged_particle", "sbz_resources:matter_blob" },
        { "",                          "sbz_resources:matter_blob",      "" }
    }
})

minetest.register_tool("sbz_resources:antimatter_annihilator", {
    description = "Antimatter Annihilator",
    inventory_image = "antimatter_annihilator.png", -- Replace with your own image file

    groups = { core_drop_multi = 1 },
    tool_capabilities = {
        full_punch_interval = 2.5,
        max_drop_level = 1,
        groupcaps = {
            antimatter = { times = { [1] = 3.00, [2] = 1.60, [3] = 0.90 }, uses = 10, maxlevel = 1 },
        },
    },

    sound = {
        punch_use = {
            name = "block_annihilated",
            gain = 1,
        }
    },
})
minetest.register_craft({
    output = "sbz_resources:antimatter_annihilator",
    recipe = {
        { "",                              "sbz_resources:matter_dust",      "" },
        { "sbz_resources:antimatter_blob", "sbz_resources:charged_particle", "sbz_resources:antimatter_blob" },
        { "",                              "sbz_resources:antimatter_blob",  "" }
    }
})

minetest.register_tool("sbz_resources:robotic_arm", {
    description = "Robotic Arm",
    inventory_image = "robotic_arm.png",
    groups = { core_drop_multi = 2 },
    -- Tool properties
    tool_capabilities = {
        full_punch_interval = 0.5,
        max_drop_level = 1,
        groupcaps = {
            matter = { times = { [1] = 1.50, [2] = 0.30, [3] = 0.10 }, uses = 60, leveldiff = 2, maxlevel = 2 },
        },
    },

    sound = {
        punch_use = {
            name = "block_annihilated",
            gain = 1,
        }
    },
})

minetest.register_craft {
    output = "sbz_resources:robotic_arm",
    recipe = {
        { "sbz_resources:matter_annihilator", "sbz_chem:iron_ingot",             "sbz_resources:matter_annihilator" },
        { "sbz_resources:reinforced_matter",  "sbz_resources:emittrium_circuit", "sbz_resources:reinforced_matter" },
        { "sbz_resources:reinforced_matter",  "sbz_resources:emittrium_circuit", "sbz_resources:reinforced_matter" }
    }
}


local drill_times = { [1] = 1.50 / 2, [2] = 0.30 / 2, [3] = 0.10 / 2 }
local drill_max_wear = 500
local drill_power_per_1_use = 1

local tool_caps = {
    full_punch_interval = 0.1,
    max_drop_level = 1,
    groupcaps = {
        matter = {
            times = drill_times,
            --uses = 30,
            maxlevel = 4
        },
        antimatter = {
            times = drill_times,
            --uses = 30,
            maxlevel = 4
        },
    },
}

minetest.register_tool("sbz_resources:drill", {
    description = "Electric Drill",
    inventory_image = "drill.png",
    info_extra = {
        "Powered by electricity. Wear bar indicates the amount of charge left.",
        ("%s uses"):format(drill_max_wear),
        "Shift+\"Place\" it on a battery to re-charge it."
    },
    groups = { core_drop_multi = 3, disable_repair = 1 },
    -- Tool properties
    tool_capabilities = tool_caps,
    after_use = function(stack, user, node, digparams)
        stack:add_wear_by_uses(drill_max_wear + digparams.wear)
        if stack:get_wear() >= 65535 then
            stack:get_meta():set_tool_capabilities({})
        end
        return stack
    end,
    on_place = function(stack, user, pointed)
        if pointed.type ~= "node" then return end
        local target = pointed.under
        if core.is_protected(target, user:get_player_name()) then
            return core.record_protection_violation(target, user:get_player_name())
        end
        local target_node = minetest.get_node(target)
        if minetest.get_item_group(target_node.name, "sbz_battery") == 0 then return end
        local meta = minetest.get_meta(target)
        local power = meta:get_int("power")
        local current_wear = math.floor((stack:get_wear() / 65535) * drill_max_wear)
        local wear_repaired = math.min(current_wear, math.floor(power / drill_power_per_1_use))
        local power_charged = wear_repaired * drill_power_per_1_use
        local new_power = power - power_charged

        meta:set_int("power", new_power)
        minetest.registered_nodes[target_node.name].action(target, target_node.name, meta, 0, power_charged)

        stack:set_wear(((current_wear - wear_repaired) / drill_max_wear) * 65535)
        if stack:get_wear() < 65535 then
            stack:get_meta():set_tool_capabilities(tool_caps)
        end
        return stack
    end,

    wear_color = { color_stops = { [0] = "lime" } },
    sound = { punch_use = { name = "drill_dig", } },
})

minetest.register_craft {
    recipe = {
        { "sbz_chem:titanium_ingot",         "sbz_resources:robotic_arm",       "sbz_chem:titanium_ingot" },
        { "sbz_chem:titanium_ingot",         "sbz_power:battery",               "sbz_chem:titanium_ingot" },
        { "sbz_resources:reinforced_matter", "sbz_resources:emittrium_circuit", "sbz_resources:reinforced_matter" }
    },
    output = "sbz_resources:drill"
}
