local index_adjustment = 1

minetest.register_craftitem('sbz_resources:matter_annihilator', {
    description = 'Matter Annihilator',
    inventory_image = 'matter_annihilator.png',
                
    groups = { core_drop_multi = 1 },
    tool_capabilities = {
        full_punch_interval = 2.5,
        damage_groups = { matter = 2 },
        max_drop_level = 1,
        groupcaps = {
            matter = (function()
                local fastest_time = 1
                local slowest_time = 3
                local times = {}
                for block_type = 1, 3 do
                    times[block_type] = fastest_time * -(block_type - index_adjustment) + slowest_time
                end
                return { times = times, uses = 10, maxlevel = 1 }
            end)(),
        },
    },

    sound = {
        punch_use = {
            name = 'block_annihilated',
            gain = 1,
        },
    },
})

do -- Matter Annihilator Recipe
    local _ = ''
    local a = 'sbz_resources:antimatter_dust'
    local M = 'sbz_resources:matter_blob'
    local c = 'sbz_resources:charged_particle'
    
    minetest.register_craft {
        output = 'sbz_resources:matter_annihilator',
        recipe = {
            { _, a, _ },
            { M, c, M },
            { _, M, _ },
        },
    }
end

minetest.register_craftitem('sbz_resources:antimatter_annihilator', {
    description = 'Antimatter Annihilator',
    inventory_image = 'antimatter_annihilator.png',

    groups = { core_drop_multi = 1 },
    tool_capabilities = {
        full_punch_interval = 2.5,
        damage_groups = { antimatter = 2 },
        max_drop_level = 1,
        groupcaps = {
            antimatter = (function()
                local fastest_time = 1
                local slowest_time = 3
                local times = {}
                for block_type = 1, 3 do
                    times[block_type] = fastest_time * -(block_type - index_adjustment) + slowest_time
                end
                return { times = times, uses = 10, maxlevel = 1 }
            end)(),
        },
    },

    sound = {
        punch_use = {
            name = 'block_annihilated',
            gain = 1,
        },
    },
})

do -- Antimatter Annihilator Recipe
    local _ = ''
    local m = 'sbz_resources:matter_dust'
    local A = 'sbz_resources:antimatter_blob'
    local c = 'sbz_resources:charged_particle'
    
    minetest.register_craft {
        output = 'sbz_resources:antimatter_annihilator',
        recipe = {
            { _, m, _ },
            { A, c, A },
            { _, A, _ },
        },
    }
end

minetest.register_craftitem('sbz_resources:robotic_arm', {
    description = 'Robotic Arm',
    inventory_image = 'robotic_arm.png',
    groups = { core_drop_multi = 2 },
    tool_capabilities = {
        full_punch_interval = 0.5,
        damage_groups = { matter = 1, antimatter = 1 },
        max_drop_level = 1,
        groupcaps = {
            matter = (function()
                local fastest_time = 0.5
                local slowest_time = 1.5
                local times = {}
                for block_type = 1, 3 do
                    times[block_type] = fastest_time * -(block_type - index_adjustment) + slowest_time
                end
                return { times = times, uses = 60, leveldiff = 2, maxlevel = 2 }
            end)(),
        },
    },

    sound = {
        punch_use = {
            name = 'block_annihilated',
            gain = 1,
        },
    },
})

do -- Robotic Arm Recipe
    local M = 'sbz_resources:matter_annihilator'
    local I = 'sbz_chem:iron_ingot'
    local R = 'sbz_resources:reinforced_matter'
    local E = 'sbz_resources:emittrium_circuit'
    
    minetest.register_craft {
        output = 'sbz_resources:robotic_arm',
        recipe = {
            { M, I, M },
            { R, E, R },
            { R, E, R },
        },
    }
end

local drill_max_wear = 500
local drill_power_per_1_use = 10

local fastest_time = 0.25
local slowest_time = 0.75

local drill_times = {}
for block_type = 1, 3 do
    drill_times[block_type] = fastest_time * -(block_type - index_adjustment) + slowest_time
end

local tool_caps = {
    full_punch_interval = 0.25,
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
        stack:add_wear_by_uses(drill_max_wear + digparams.wear)
        if stack:get_wear() >= 65535 then stack:get_meta():set_tool_capabilities {} end
        return stack
    end,
    on_place = sbz_api.on_place_recharge(
        (drill_max_wear / 65535) * drill_power_per_1_use,
        function(stack, user, pointed)
            if stack:get_wear() < 65530 then stack:get_meta():set_tool_capabilities(tool_caps) end
        end
    ),
    powertool_charge = sbz_api.powertool_charge((drill_max_wear / 65535) * drill_power_per_1_use),
    charge_per_use = drill_power_per_1_use,
    wear_represents = 'power',

    wear_color = { color_stops = { [0] = 'lime' } },
    sound = { punch_use = { name = 'drill_dig' } },
})

do -- Drill Recipe
    local T = 'sbz_chem:titanium_ingot'
    local A = 'sbz_resources:robotic_arm'
    local B = 'sbz_power:battery'
    local R = 'sbz_resources:reinforced_matter'
    local E = 'sbz_resources:emittrium_circuit'
    
    minetest.register_craft {
        recipe = {
            { T, A, T },
            { T, B, T },
            { R, E, R },
        },
        output = 'sbz_resources:drill',
    }
end