-- Define a new pickaxe
minetest.register_tool("sbz_resources:matter_annihilator", {
    description = "Matter Annihilator",
    inventory_image = "matter_annihilator.png", -- Replace with your own image file

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
            gain = 1.0,
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

minetest.register_tool("sbz_resources:robotic_arm", {
    description = "Robotic Arm",
    inventory_image = "robotic_arm.png",
    -- Tool properties
    tool_capabilities = {
        full_punch_interval = 0.5,
        max_drop_level = 1,
        groupcaps = {
            matter = { times = { [1] = 1.50, [2] = 0.30, [3] = 0.10 }, uses = 30, maxlevel = 1 },
        },
    },

    sound = {
        punch_use = {
            name = "block_annihilated",
            gain = 1.0,
        }
    },

})

minetest.register_craft {
    output = "sbz_resources:robotic_arm",
    recipe = {
        { "sbz_resources:matter_annihilator", "sbz_chem:iron_powder",            "sbz_resources:matter_annihilator" },
        { "sbz_resources:reinforced_matter",  "sbz_resources:emittrium_circuit", "sbz_resources:reinforced_matter" },
        { "sbz_resources:reinforced_matter",  "sbz_resources:emittrium_circuit", "sbz_resources:reinforced_matter" }
    }
}
