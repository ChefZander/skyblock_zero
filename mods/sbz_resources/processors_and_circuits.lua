minetest.register_craftitem("sbz_resources:simple_circuit", {
    description = "Simple Circuit",
    inventory_image = "simple_circuit.png",
    stack_max = 256,
})

minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:simple_circuit 2",
    recipe = { "sbz_resources:core_dust", "sbz_resources:matter_blob" }
})

minetest.register_craftitem("sbz_resources:mosfet", {
    description = "Metal-Oxide-Semiconductor Field-Effect Transistor (MOSFET)",
    inventory_image = "mosfet.png", -- REPLACE THIS
    stack_max = 256,
})

minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:mosfet",
    recipe = { "sbz_chem:iron_ingot", "sbz_power:power_pipe" }
})

minetest.register_craftitem("sbz_resources:retaining_circuit", {
    description = "Retaining Circuit",
    inventory_image = "retaining_circuit.png",
    stack_max = 256,
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:retaining_circuit",
    recipe = { "sbz_resources:charged_particle", "sbz_resources:antimatter_dust", "sbz_resources:simple_circuit" }
})

minetest.register_craftitem("sbz_resources:emittrium_circuit", {
    description = "Emittrium Circuit",
    inventory_image = "emittrium_circuit.png",
    stack_max = 256,
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:emittrium_circuit",
    recipe = { "sbz_resources:charged_particle", "sbz_resources:retaining_circuit", "sbz_resources:raw_emittrium", "sbz_resources:matter_plate" }
})

core.register_craftitem("sbz_resources:phlogiston_circuit", {
    description = "Phlogiston Circuit",
    inventory_image = "phlogiston_circuit.png"
})

core.register_craft {
    type = "shapeless",
    output = "sbz_resources:phlogiston_circuit 4",
    recipe = {
        "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit", "sbz_resources:phlogiston",
        "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit", "sbz_resources:phlogiston",
        "sbz_power:simple_charged_field", "sbz_resources:antimatter_blob", "sbz_resources:compressed_core_dust",
    }
}

-- used in meteorite radars and weapons
core.register_craftitem("sbz_resources:prediction_circuit", {
    description = "Prediction Circuit",
    inventory_image = "prediction_circuit.png",
})

core.register_craft {
    type = "shapeless",
    output = "sbz_resources:prediction_circuit",
    recipe = {
        "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit", "sbz_chem:titanium_alloy_ingot",
        "sbz_resources:raw_emittrium", "sbz_resources:raw_emittrium", "sbz_resources:raw_emittrium"
    }
}


minetest.register_craftitem("sbz_resources:simple_logic_circuit", {
    description = "Simple Logic Circuit",
    inventory_image = "simple_logic_circuit.png",
    stack_max = 256,
})

minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:simple_logic_circuit 12",
    recipe = {
        "sbz_bio:cleargrass", "sbz_bio:cleargrass", "sbz_bio:cleargrass",
        "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit",
        "sbz_bio:razorgrass", "sbz_bio:razorgrass", "sbz_bio:razorgrass",
    }
})

minetest.register_craftitem("sbz_resources:simple_inverted_logic_circuit", {
    description = "Simple Inverted Logic Circuit",
    inventory_image = "simple_inverting_circuit.png",
    stack_max = 256,
})

minetest.register_craft {
    type = "shapeless",
    output = "sbz_resources:simple_inverted_logic_circuit",
    recipe = {
        "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust",
        "sbz_resources:compressed_core_dust", "sbz_resources:simple_logic_circuit", "sbz_resources:compressed_core_dust",
        "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust",
    }
}

minetest.register_craft {
    type = "shapeless",
    output = "sbz_resources:simple_logic_circuit",
    recipe = {
        "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust",
        "sbz_resources:compressed_core_dust", "sbz_resources:simple_inverted_logic_circuit", "sbz_resources:compressed_core_dust",
        "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust",
    }
}

--- === PROCESSORS ===

core.register_craftitem("sbz_resources:simple_processor", {
    description = "Simple Processor",
    inventory_image = "simple_procesor.png" -- someone correct the typo lmfao
})

sbz_api.recipe.register_craft {
    type = "engraver",
    output = "sbz_resources:simple_processor",
    items = { "sbz_chem:silicon_crystal 8" }
}

-- crafting processors

core.register_craftitem("sbz_resources:simple_crafting_processor", {
    description = "Simple Crafting Processor\nCrafts 1 item per second for 10 power.",
    inventory_image = "simple_crafting_processor.png",
    stack_max = 1
})

minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:simple_crafting_processor",
    recipe = { "sbz_resources:mosfet 10", "sbz_resources:simple_circuit 10" }
})


core.register_craftitem("sbz_resources:quick_crafting_processor", {
    description = "Quick Crafting Processor\nCrafts 2 items per second for 25 power.",
    inventory_image = "quick_crafting_processor.png",
    stack_max = 1
})

minetest.register_craft({
    type = "shaped",
    output = "sbz_resources:quick_crafting_processor",
    recipe = {
        {"sbz_resources:simple_crafting_processor", "sbz_resources:prediction_circuit 10", "sbz_resources:simple_crafting_processor"},
        {"", "sbz_resources:mosfet 10", ""},
        {"sbz_resources:simple_crafting_processor", "", "sbz_resources:simple_crafting_processor"},
    }
})


core.register_craftitem("sbz_resources:fast_crafting_processor", {
    description = "Fast Crafting Processor\nCrafts 4 items per second for 50 power.",
    inventory_image = "fast_crafting_processor.png",
    stack_max = 1
})

minetest.register_craft({
    type = "shaped",
    output = "sbz_resources:fast_crafting_processor",
    recipe = {
        {"sbz_resources:quick_crafting_processor", "sbz_resources:emittrium_circuit 25", "sbz_resources:quick_crafting_processor"},
        {"sbz_resources:mosfet 10",                "sbz_resources:emittrium_circuit 25", "sbz_resources:mosfet 10"},
        {"sbz_resources:quick_crafting_processor", "sbz_resources:emittrium_circuit 25", "sbz_resources:quick_crafting_processor"},
    }
})


core.register_craftitem("sbz_resources:accelerated_silicon_crafting_processor", {
    description = "Accelerated Silicon Crafting Processor\nCrafts 8 items per second for 100 power.",
    inventory_image = "accelerated_silicon_crafting_processor.png",
    stack_max = 1
})

minetest.register_craft({
    type = "shaped",
    output = "sbz_resources:accelerated_silicon_crafting_processor",
    recipe = {
        {"sbz_resources:fast_crafting_processor", "sbz_chem:silicon_crystal 25",   "sbz_resources:fast_crafting_processor"},
        {"sbz_resources:mosfet 25",               "sbz_resources:mosfet 25",       "sbz_resources:mosfet 25"},
        {"sbz_resources:fast_crafting_processor", "",   "sbz_resources:fast_crafting_processor"},
    }
})


core.register_craftitem("sbz_resources:nuclear_crafting_processor", {
    description = "Nuclear Crafting Processor\nCrafts 16 items per second for 175 power.",
    inventory_image = "nuclear_crafting_processor.png",
    stack_max = 1
})

minetest.register_craft({
    type = "shaped",
    output = "sbz_resources:nuclear_crafting_processor",
    recipe = {
        {"sbz_resources:accelerated_silicon_crafting_processor", "sbz_resources:phlogiston_circuit 10", "sbz_resources:accelerated_silicon_crafting_processor"},
        {"sbz_resources:mosfet 64",                              "sbz_resources:mosfet 64",               "sbz_resources:mosfet 64"},
        {"sbz_resources:accelerated_silicon_crafting_processor", "sbz_meteorites:neutronium 10",          "sbz_resources:accelerated_silicon_crafting_processor"},
    }
})