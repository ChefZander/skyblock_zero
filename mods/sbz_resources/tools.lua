minetest.register_craftitem('sbz_resources:matter_annihilator', {
    description = 'Matter Annihilator',
    inventory_image = 'matter_annihilator.png',

    groups = { core_drop_multi = 1 },
    tool_capabilities = {
        full_punch_interval = 2.5,
        damage_groups = { matter = 2 },
        max_drop_level = 1,
        groupcaps = {
            matter = { times = { [1] = 3.00, [2] = 1.60, [3] = 0.90 }, uses = 10, maxlevel = 1 },
        },
    },

    sound = {
        punch_use = {
            name = 'block_annihilated',
            gain = 1,
        },
    },
})
minetest.register_craft {
    output = 'sbz_resources:matter_annihilator',
    recipe = {
        { '', 'sbz_resources:antimatter_dust', '' },
        { 'sbz_resources:matter_blob', 'sbz_resources:charged_particle', 'sbz_resources:matter_blob' },
        { '', 'sbz_resources:matter_blob', '' },
    },
}

minetest.register_craftitem('sbz_resources:antimatter_annihilator', {
    description = 'Antimatter Annihilator',
    inventory_image = 'antimatter_annihilator.png',

    groups = { core_drop_multi = 1 },
    tool_capabilities = {
        full_punch_interval = 2.5,
        damage_groups = { antimatter = 2 },
        max_drop_level = 1,
        groupcaps = {
            antimatter = { times = { [1] = 3.00, [2] = 1.60, [3] = 0.90 }, uses = 10, maxlevel = 1 },
        },
    },

    sound = {
        punch_use = {
            name = 'block_annihilated',
            gain = 1,
        },
    },
})
minetest.register_craft {
    output = 'sbz_resources:antimatter_annihilator',
    recipe = {
        { '', 'sbz_resources:matter_dust', '' },
        { 'sbz_resources:antimatter_blob', 'sbz_resources:charged_particle', 'sbz_resources:antimatter_blob' },
        { '', 'sbz_resources:antimatter_blob', '' },
    },
}

minetest.register_craftitem('sbz_resources:robotic_arm', {
    description = 'Robotic Arm',
    inventory_image = 'robotic_arm.png',
    groups = { core_drop_multi = 2 },
    tool_capabilities = {
        full_punch_interval = 0.5,
        damage_groups = { matter = 1, antimatter = 1 },
        max_drop_level = 1,
        groupcaps = {
            matter = { times = { [1] = 1.50, [2] = 0.30, [3] = 0.10 }, uses = 60, leveldiff = 2, maxlevel = 2 },
        },
    },

    sound = {
        punch_use = {
            name = 'block_annihilated',
            gain = 1,
        },
    },
})

minetest.register_craft {
    output = 'sbz_resources:robotic_arm',
    recipe = {
        { 'sbz_resources:matter_annihilator', 'sbz_chem:iron_ingot', 'sbz_resources:matter_annihilator' },
        { 'sbz_resources:reinforced_matter', 'sbz_resources:emittrium_circuit', 'sbz_resources:reinforced_matter' },
        { 'sbz_resources:reinforced_matter', 'sbz_resources:emittrium_circuit', 'sbz_resources:reinforced_matter' },
    },
}

local drill_times = { [1] = 1.50 / 2, [2] = 0.30 / 2, [3] = 0.10 / 2 }
local drill_max_wear = 500
local drill_power_per_1_use = 10

local tool_caps = {
    full_punch_interval = 0.1,
    damage_groups = {
        matter = 3,
        antimatter = 3,
    },
    punch_attack_uses = drill_max_wear,
    max_drop_level = 1,
    groupcaps = {
        matter = {
            times = drill_times,
            --uses = 30,
            maxlevel = 4,
        },
        antimatter = {
            times = drill_times,
            --uses = 30,
            maxlevel = 4,
        },
    },
}

minetest.register_tool('sbz_resources:drill', {
    description = 'Electric Drill',
    inventory_image = 'drill.png',
    info_extra = {
        'Powered by electricity. Wear bar indicates the amount of charge left.',
        ('%s uses'):format(drill_max_wear),
        '"Place" it on a battery to re-charge it.',
    },
    groups = { core_drop_multi = 4, disable_repair = 1, power_tool = 1 },
    tool_capabilities = tool_caps,
    after_use = function(stack, user, node, digparams)
        if stack:get_wear() >= 65500 then
            stack:get_meta():set_tool_capabilities {}
            stack:set_wear(65500)
        else
            stack:add_wear_by_uses(drill_max_wear + digparams.wear)
        end
        return stack
    end,
    on_place = sbz_api.on_place_recharge(
        (drill_max_wear / 65535) * drill_power_per_1_use,
        function(stack, user, pointed)
            if stack:get_wear() < 65530 then stack:get_meta():set_tool_capabilities(nil) end
        end
    ),
    powertool_charge = sbz_api.powertool_charge((drill_max_wear / 65535) * drill_power_per_1_use),
    charge_per_use = drill_power_per_1_use,
    wear_represents = 'power',

    wear_color = { color_stops = { [0] = 'lime' } },
    sound = { punch_use = { name = 'drill_dig' } },
})

minetest.register_craft {
    recipe = {
        { 'sbz_chem:titanium_ingot', 'sbz_resources:robotic_arm', 'sbz_chem:titanium_ingot' },
        { 'sbz_chem:titanium_ingot', 'sbz_power:battery', 'sbz_chem:titanium_ingot' },
        { 'sbz_resources:reinforced_matter', 'sbz_resources:emittrium_circuit', 'sbz_resources:reinforced_matter' },
    },
    output = 'sbz_resources:drill',
}
