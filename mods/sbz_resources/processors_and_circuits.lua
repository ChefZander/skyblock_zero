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

--- === PROCESSORS ===

core.register_craftitem("sbz_resources:simple_processor", {
    description = "Simple Processor",
    inventory_image = "simple_procesor.png" -- someone correct the typo lmfao
})

unified_inventory.register_craft {
    type = "engraver",
    output = "sbz_resources:simple_processor",
    items = { "sbz_chem:silicon_crystal 8" }
}
