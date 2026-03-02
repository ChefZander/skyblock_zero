minetest.register_craftitem('sbz_resources:simple_circuit', {
    description = 'Simple Circuit',
    inventory_image = 'simple_circuit.png',
    stack_max = 256,
})

do -- Simple Circuit recipe scope
    local Simple_Circuit = 'sbz_resources:simple_circuit'
    local amount = 2
    local CD = 'sbz_resources:core_dust'
    local MB = 'sbz_resources:matter_blob'
    core.register_craft({
        type = 'shapeless',
        output = Simple_Circuit .. ' ' .. tostring(amount),
        recipe = { CD, MB },
    })
end

minetest.register_craftitem('sbz_resources:retaining_circuit', {
    description = 'Retaining Circuit',
    inventory_image = 'retaining_circuit.png',
    stack_max = 256,
})

do -- Retaining Circuit recipe scope
    local Retaining_Circuit = 'sbz_resources:retaining_circuit'
    local CP = 'sbz_resources:charged_particle'
    local AD = 'sbz_resources:antimatter_dust'
    local SC = 'sbz_resources:simple_circuit'
    core.register_craft({
        type = 'shapeless',
        output = Retaining_Circuit,
        recipe = { CP, AD, SC },
    })
end

minetest.register_craftitem('sbz_resources:emittrium_circuit', {
    description = 'Emittrium Circuit',
    inventory_image = 'emittrium_circuit.png',
    stack_max = 256,
})

do -- Emittrium Circuit recipe scope
    local Emittrium_Circuit = 'sbz_resources:emittrium_circuit'
    local CP = 'sbz_resources:charged_particle'
    local RC = 'sbz_resources:retaining_circuit'
    local RE = 'sbz_resources:raw_emittrium'
    local MP = 'sbz_resources:matter_plate'
    core.register_craft({
        type = 'shapeless',
        output = Emittrium_Circuit,
        recipe = { CP, RC, RE, MP },
    })
end

core.register_craftitem('sbz_resources:phlogiston_circuit', {
    description = 'Phlogiston Circuit',
    inventory_image = 'phlogiston_circuit.png',
})

do -- Phlogiston Circuit recipe scope
    local Phlogiston_Circuit = 'sbz_resources:phlogiston_circuit'
    local amount = 4
    local EC = 'sbz_resources:emittrium_circuit'
    local Ph = 'sbz_resources:phlogiston'
    local CF = 'sbz_power:simple_charged_field'
    local AB = 'sbz_resources:antimatter_blob'
    local CC = 'sbz_resources:compressed_core_dust'
    core.register_craft({
        type = 'shapeless',
        output = Phlogiston_Circuit .. ' ' .. tostring(amount),
        recipe = {
            EC, EC, Ph,
            EC, EC, Ph,
            CF, AB, CC,
        }
    })
end

-- used in meteorite radars and weapons
core.register_craftitem('sbz_resources:prediction_circuit', {
    description = 'Prediction Circuit',
    inventory_image = 'prediction_circuit.png',
})

do -- Prediction Circuit recipe scope
    local Prediction_Circuit = 'sbz_resources:prediction_circuit'
    local EC = 'sbz_resources:emittrium_circuit'
    local TA = 'sbz_chem:titanium_alloy_ingot'
    local RE = 'sbz_resources:raw_emittrium'
    core.register_craft({
        type = 'shapeless',
        output = Prediction_Circuit,
        recipe = {
            EC, EC, TA,
            RE, RE, RE,
        }
    })
end

minetest.register_craftitem('sbz_resources:simple_logic_circuit', {
    description = 'Simple Logic Circuit',
    inventory_image = 'simple_logic_circuit.png',
    stack_max = 256,
})

do -- Simple Logic Circuit recipe scope
    local Simple_Logic_Circuit = 'sbz_resources:simple_logic_circuit'
    local amount = 12
    local Cl = 'sbz_bio:cleargrass'
    local EC = 'sbz_resources:emittrium_circuit'
    local Ra = 'sbz_bio:razorgrass'
    core.register_craft({
        type = 'shapeless',
        output = Simple_Logic_Circuit .. ' ' .. tostring(amount),
        recipe = {
            Cl, Cl, Cl,
            EC, EC, EC,
            Ra, Ra, Ra,
        },
    })
end

minetest.register_craftitem('sbz_resources:simple_inverted_logic_circuit', {
    description = 'Simple Inverted Logic Circuit',
    inventory_image = 'simple_inverting_circuit.png',
    stack_max = 256,
})

do -- Simple Inverted Logic Circuit recipe scope
    local Simple_Inverted_Logic_Circuit = 'sbz_resources:simple_inverted_logic_circuit'
    local CC = 'sbz_resources:compressed_core_dust'
    local SL = 'sbz_resources:simple_logic_circuit'
    core.register_craft({
        type = 'shapeless',
        output = Simple_Inverted_Logic_Circuit,
        recipe = {
            CC, CC, CC,
            CC, SL, CC,
            CC, CC, CC,
        }
    })
end

do -- Simple Logic Circuit recipe scope
    local Simple_Logic_Circuit = 'sbz_resources:simple_logic_circuit'
    local CC = 'sbz_resources:compressed_core_dust'
    local SI = 'sbz_resources:simple_inverted_logic_circuit'
    core.register_craft({
        type = 'shapeless',
        output = Simple_Logic_Circuit,
        recipe = {
            CC, CC, CC,
            CC, SI, CC,
            CC, CC, CC,
        }
    })
end

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
    ['sbz_resources:fast_crafting_processor'] = { crafts = 8, power = 20 },
    ['sbz_resources:very_fast_crafting_processor'] = { crafts = 32, power = 140 },

    ['sbz_resources:extremely_fast_crafting_processor'] = { crafts = 128, power = 640 },
    ['sbz_resources:instant_crafting_processor'] = { crafts = 100000, power = 800 },
}

core.register_craftitem('sbz_resources:simple_crafting_processor', {
    description = 'Simple Crafting Processor',
    info_extra = 'Crafts 1 item/s for 5Cj',
    inventory_image = 'simple_crafting_processor.png',
})

do -- Simple Crafting Processor recipe scope
    local Simple_Crafting_Processor = 'sbz_resources:simple_crafting_processor'
    local MB = 'sbz_resources:matter_blob'
    local EC = 'sbz_resources:emittrium_circuit'
    local CI = 'sbz_chem:cobalt_ingot'
    core.register_craft({
        output = Simple_Crafting_Processor,
        recipe = {
            { MB, EC, MB },
            { EC, CI, EC },
            { MB, EC, MB },
        },
    })
end

core.register_craftitem('sbz_resources:fast_crafting_processor', {
    description = 'Fast Crafting Processor',
    info_extra = 'Crafts 8 items/s for 20Cj',
    inventory_image = 'quick_crafting_processor.png',
})

-- stylua: ignore start
do -- Fast Crafting Processor recipe scope
    local Fast_Crafting_Processor = 'sbz_resources:fast_crafting_processor'
    local SC = 'sbz_resources:simple_crafting_processor'
    local RM = 'sbz_resources:reinforced_matter'
    local SR = 'sbz_resources:shock_crystal'
    core.register_craft({
        output = Fast_Crafting_Processor,
        recipe = {
            { SC, RM, SC },
            { RM, SR, RM },
            { SC, RM, SC },
        },
    })
end

core.register_alias('sbz_resources:quick_crafting_processor', 'sbz_resources:fast_crafting_processor')

core.register_craftitem('sbz_resources:very_fast_crafting_processor', {
    description = 'Very Fast Crafting Processor',
    inventory_image = 'accelerated_silicon_crafting_processor.png',
    info_extra = "Crafts 32 items per second for 140 power."
})

do -- Very Fast Crafting Processor recipe scope
    local Very_Fast_Crafting_Processor = 'sbz_resources:very_fast_crafting_processor'
    local FC = 'sbz_resources:fast_crafting_processor'
    local SC = 'sbz_chem:silicon_crystal'
    local TC = 'sbz_chem:thorium_crystal'
    core.register_craft({
        output = Very_Fast_Crafting_Processor,
        recipe = {
            { FC, SC, FC },
            { SC, TC, SC },
            { FC, SC, FC },
        }
    })
end

core.register_craftitem('sbz_resources:extremely_fast_crafting_processor', {
    description = 'Extremely Fast Crafting Processor',
    inventory_image = 'quantum_crafting_processor.png',
    info_extra = "Crafts 128 items/s and uses 640Cj. You shouldn't need this.",
})
core.register_alias('sbz_resources:needlessly_expensive_crafting_processor','sbz_resources:extremely_fast_crafting_processor')

do -- Extremely Fast Crafting Processor recipe scope
    local Extremely_Fast_Crafting_Processor = 'sbz_resources:extremely_fast_crafting_processor'
    local VF = 'sbz_resources:very_fast_crafting_processor'
    local WU = 'drawers:warpshroom_upgrade'
    local GC = 'sbz_bio:giant_colorium_sapling'
    local TC = 'sbz_chem:thorium_crystal'
    local XE = 'sbz_chem:xray_off' -- ("X-ray Emitter" in-game)
    core.register_craft({
        type = 'shaped',
        output = Extremely_Fast_Crafting_Processor,
        recipe = {
            { VF, WU, VF },
            { GC, TC, GC },
            { VF, XE, VF },
        }
    })
end

do -- Instant Crafting Processor recipe scope
    local Instant_Crafting_Processor = 'sbz_resources:instant_crafting_processor'
    local EF = 'sbz_resources:extremely_fast_crafting_processor'
    core.register_craft({
        output = Instant_Crafting_Processor,
        recipe = {
            { EF, EF, EF },
            { EF, EF, EF },
            { EF, EF, EF },
        }
    })
end

-- stylua: ignore end

core.register_craftitem('sbz_resources:instant_crafting_processor', {
    description = 'Instant Crafting Processor',
    inventory_image = 'creative_crafting_processor.png',
    info_extra = 'Crafts 100000 items/s, consumes 800Cj.\nThe crafting recipe is a joke. You should not try to get it... but if you want to',
})
core.register_alias(
    'sbz_resources:omega_quantum_black_hole_whatever_crafting_processor',
    'sbz_resources:instant_crafting_processor'
)

-- deprecated stuff
core.register_craftitem('sbz_resources:mosfet', {
    description = 'Metal-Oxide-Semiconductor Field-Effect Transistor (MOSFET)',
    info_extra = 'Deprecated. Throw it away.',
    inventory_image = 'mosfet.png',
    groups = { not_in_creative_inventory = 1 },
    stack_max = 1,
})
