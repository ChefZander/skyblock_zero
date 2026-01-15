minetest.register_craftitem('sbz_resources:simple_circuit', {
    description = 'Simple Circuit',
    inventory_image = 'simple_circuit.png',
    stack_max = 256,
})

minetest.register_craft {
    type = 'shapeless',
    output = 'sbz_resources:simple_circuit 2',
    recipe = { 'sbz_resources:core_dust', 'sbz_resources:matter_blob' },
}

minetest.register_craftitem('sbz_resources:retaining_circuit', {
    description = 'Retaining Circuit',
    inventory_image = 'retaining_circuit.png',
    stack_max = 256,
})
minetest.register_craft {
    type = 'shapeless',
    output = 'sbz_resources:retaining_circuit',
    recipe = { 'sbz_resources:charged_particle', 'sbz_resources:antimatter_dust', 'sbz_resources:simple_circuit' },
}

minetest.register_craftitem('sbz_resources:emittrium_circuit', {
    description = 'Emittrium Circuit',
    inventory_image = 'emittrium_circuit.png',
    stack_max = 256,
})
minetest.register_craft {
    type = 'shapeless',
    output = 'sbz_resources:emittrium_circuit',
    recipe = {
        'sbz_resources:charged_particle',
        'sbz_resources:retaining_circuit',
        'sbz_resources:raw_emittrium',
        'sbz_resources:matter_plate',
    },
}

core.register_craftitem('sbz_resources:phlogiston_circuit', {
    description = 'Phlogiston Circuit',
    inventory_image = 'phlogiston_circuit.png',
})

core.register_craft {
    type = 'shapeless',
    output = 'sbz_resources:phlogiston_circuit 4',
    recipe = {
        'sbz_resources:emittrium_circuit',
        'sbz_resources:emittrium_circuit',
        'sbz_resources:phlogiston',
        'sbz_resources:emittrium_circuit',
        'sbz_resources:emittrium_circuit',
        'sbz_resources:phlogiston',
        'sbz_power:simple_charged_field',
        'sbz_resources:antimatter_blob',
        'sbz_resources:compressed_core_dust',
    },
}

-- used in meteorite radars and weapons
core.register_craftitem('sbz_resources:prediction_circuit', {
    description = 'Prediction Circuit',
    inventory_image = 'prediction_circuit.png',
})

core.register_craft {
    type = 'shapeless',
    output = 'sbz_resources:prediction_circuit',
    recipe = {
        'sbz_resources:emittrium_circuit',
        'sbz_resources:emittrium_circuit',
        'sbz_chem:titanium_alloy_ingot',
        'sbz_resources:raw_emittrium',
        'sbz_resources:raw_emittrium',
        'sbz_resources:raw_emittrium',
    },
}

minetest.register_craftitem('sbz_resources:simple_logic_circuit', {
    description = 'Simple Logic Circuit',
    inventory_image = 'simple_logic_circuit.png',
    stack_max = 256,
})

minetest.register_craft {
    type = 'shapeless',
    output = 'sbz_resources:simple_logic_circuit 12',
    recipe = {
        'sbz_bio:cleargrass',
        'sbz_bio:cleargrass',
        'sbz_bio:cleargrass',
        'sbz_resources:emittrium_circuit',
        'sbz_resources:emittrium_circuit',
        'sbz_resources:emittrium_circuit',
        'sbz_bio:razorgrass',
        'sbz_bio:razorgrass',
        'sbz_bio:razorgrass',
    },
}

minetest.register_craftitem('sbz_resources:simple_inverted_logic_circuit', {
    description = 'Simple Inverted Logic Circuit',
    inventory_image = 'simple_inverting_circuit.png',
    stack_max = 256,
})

minetest.register_craft {
    type = 'shapeless',
    output = 'sbz_resources:simple_inverted_logic_circuit',
    recipe = {
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:simple_logic_circuit',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
    },
}

minetest.register_craft {
    type = 'shapeless',
    output = 'sbz_resources:simple_logic_circuit',
    recipe = {
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:simple_inverted_logic_circuit',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
        'sbz_resources:compressed_core_dust',
    },
}

--- === PROCESSORS ===

core.register_craftitem('sbz_resources:simple_processor', {
    description = 'Simple Processor',
    inventory_image = 'simple_procesor.png', -- someone correct the typo lmfao
})

sbz_api.recipe.register_craft {
    type = 'engraver',
    output = 'sbz_resources:simple_processor',
    items = { 'sbz_chem:silicon_crystal 8' },
}

-- crafting processors

--[[
DESIGN: 
1st tier: don't even have metal automation
2nd tier: explored into shockshrooms
3rd tier: actively automating shock shrooms, silicon and have nuclear stuff
4th tier: bored
5th tier: and should be doing something else
]]
sbz_api.crafting_processor_stats = {
    ['sbz_resources:simple_crafting_processor'] = { crafts = 1, power = 5 },
    ['sbz_resources:quick_crafting_processor'] = { crafts = 8, power = 20 },
    ['sbz_resources:fast_crafting_processor'] = { crafts = 32, power = 140 },

    ['sbz_resources:needlessly_expensive_crafting_processor'] = { crafts = 128, power = 640 },
    ['sbz_resources:omega_quantum_black_hole_whatever_crafting_processor'] = { crafts = 100000, power = 800 },
}

core.register_craftitem('sbz_resources:simple_crafting_processor', {
    description = 'Simple Crafting Processor',
    info_extra = 'Crafts 1 item/s for 5Cj',
    inventory_image = 'simple_crafting_processor.png',
    stack_max = 1,
})
core.register_craft {
    output = 'sbz_resources:simple_crafting_processor',
    recipe = {
        { 'sbz_resources:matter_blob', 'sbz_resources:emittrium_circuit', 'sbz_resources:matter_blob' },
        { 'sbz_resources:emittrium_circuit', 'sbz_chem:cobalt_ingot', 'sbz_resources:emittrium_circuit' },
        { 'sbz_resources:matter_blob', 'sbz_resources:emittrium_circuit', 'sbz_resources:matter_blob' },
    },
}

core.register_craftitem('sbz_resources:fast_crafting_processor', {
    description = 'Fast Crafting Processor',
    info_extra = 'Crafts 8 items/s for 20Cj',
    inventory_image = 'quick_crafting_processor.png',
    stack_max = 1,
})

-- stylua: ignore start
minetest.register_craft {
    output = 'sbz_resources:fast_crafting_processor',
    recipe = {
        {"sbz_resources:simple_crafting_processor","sbz_resources:reinforced_matter","sbz_resources:simple_crafting_processor",},
        {"sbz_resources:reinforced_matter","sbz_resources:shock_crystal","sbz_resources:reinforced_matter",},
        {"sbz_resources:simple_crafting_processor","sbz_resources:reinforced_matter","sbz_resources:simple_crafting_processor",},
    },
}
core.register_alias('sbz_resources:quick_crafting_processor', 'sbz_resources:fast_crafting_processor')

core.register_craftitem('sbz_resources:very_fast_crafting_processor', {
    description = 'Very Fast Crafting Processor\nCrafts 32 items per second for 140 power.',
    inventory_image = 'accelerated_silicon_crafting_processor.png',
    stack_max = 1,
})

minetest.register_craft {
    output = 'sbz_resources:very_fast_crafting_processor',
    recipe = {
        { 'sbz_resources:fast_crafting_processor', 'sbz_chem:silicon_crystal', 'sbz_resources:fast_crafting_processor' },
        { 'sbz_chem:silicon_crystal', 'sbz_chem:thorium_crystal', 'sbz_chem:silicon_crystal' },
        { 'sbz_resources:fast_crafting_processor', 'sbz_chem:silicon_crystal', 'sbz_resources:fast_crafting_processor' },
    },
}

core.register_craftitem('sbz_resources:needlessly_expensive_crafting_processor', {
    description = 'Needlessly Expensive Crafting Processor',
    inventory_image = 'needlessly_expensive_crafting_processor.png',
    stack_max = 1,
    info_extra = "Crafts 128 items/s and uses 640Cj. You shouldn't need this, this item was made as a joke.",
})

minetest.register_craft {
    type = 'shaped',
    output = 'sbz_resources:needlessly_expensive_crafting_processor',
    recipe = {
        { 'sbz_resources:very_fast_crafting_processor', 'drawers:warpshroom_upgrade', 'sbz_resources:very_fast_crafting_processor' },
        { 'sbz_bio:giant_colorium_sapling', 'sbz_chem:thorium_crystal', 'sbz_bio:giant_colorium_sapling' },
        { 'sbz_resources:very_fast_crafting_processor', 'sbz_chem:xray_off', 'sbz_resources:very_fast_crafting_processor' },
    },
}

core.register_craftitem('sbz_resources:omega_quantum_black_hole_whatever_crafting_processor', {
    description = 'Omega Quantum Black Hole Whatever Crafting Processor',
    inventory_image = 'omega_quantum_black_hole_whatever_crafting_processor.png',
    info_extra = 'Crafts 100000 items/s, consumes 800Cj.\nThe magic of non-commercial volunteer-run free (as in freedom) games is that you can put in whatever you want.\nThis item is a joke. You should not try to get it.',
    stack_max = 1,
})

minetest.register_craft {
    output = 'sbz_resources:omega_quantum_black_hole_whatever_crafting_processor',
    recipe = {
        { 'sbz_resources:needlessly_expensive_crafting_processor', 'sbz_resources:needlessly_expensive_crafting_processor', 'sbz_resources:needlessly_expensive_crafting_processor', },
        { 'sbz_resources:needlessly_expensive_crafting_processor', 'sbz_resources:needlessly_expensive_crafting_processor', 'sbz_resources:needlessly_expensive_crafting_processor', },
        { 'sbz_resources:needlessly_expensive_crafting_processor', 'sbz_resources:needlessly_expensive_crafting_processor', 'sbz_resources:needlessly_expensive_crafting_processor', },
    },
}
-- stylua: ignore end

-- deprecated stuff
core.register_craftitem('sbz_resources:mosfet', {
    description = 'Metal-Oxide-Semiconductor Field-Effect Transistor (MOSFET)',
    info_extra = 'Deprecated. Throw it away.',
    inventory_image = 'mosfet.png',
    groups = { not_in_creative_inventory = 1 },
    stack_max = 1,
})
