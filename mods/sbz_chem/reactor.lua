-- Fuel rods

core.register_craftitem("sbz_chem:thorium_fuel_rod", {
    groups = { chem_element = 1, fuel_rod = 1, radioactive = 1 },
    description = "Thorium Fuel Rod",
    inventory_image = "fuel_rod.png^[multiply:#d633af"
})

unified_inventory.register_craft {
    type = "compressing",
    output = "sbz_chem:thorium_fuel_rod",
    items = { "sbz_chem:thorium_block 8" }
}

core.register_craftitem("sbz_chem:uranium_fuel_rod", {
    groups = { chem_element = 1, fuel_rod = 2, radioactive = 3 },
    description = "Uranium Fuel Rod",
    inventory_image = "fuel_rod.png^[multiply:#47681e"
})

unified_inventory.register_craft {
    type = "compressing",
    output = "sbz_chem:uranium_fuel_rod",
    items = { "sbz_chem:uranium_block 8" }
}

core.register_craftitem("sbz_chem:plutonium_fuel_rod", {
    groups = { chem_element = 1, fuel_rod = 3, radioactive = 5 },
    description = "Plutonium Fuel Rod",
    info_extra = "Not for noobs...",
    inventory_image = "fuel_rod.png^[multiply:#1d2aba"
})
unified_inventory.register_craft {
    type = "compressing",
    output = "sbz_chem:plutonium_fuel_rod",
    items = { "sbz_chem:plutonium_block 8" }
}


local tier2power = {
    [1] = 800,
    [2] = 2200,
    [3] = 4800,
}

local explosion_particle_def = {
    time = 1,
    amount = 9000,
    radius = 1,
    drag = 0.2,
    glow = 14,
    exptime = { min = 2, max = 10 },
    size = { min = 3, max = 6 },
    texture = "reactor_explosion_particle.png^[multiply:lime",
    attract = {
        kind = "point",
        strength = { min = -20, max = 0 }
    },
    acc = { x = 0, y = -3, z = 0 }, -- "gravity"
    collisiondetection = true,
}

local rod_duration = 3 * 60 * 60
local random = PcgRandom(0)

sbz_api.register_stateful_generator("sbz_chem:nuclear_reactor", {
    description = "Nuclear Reactor",
    tiles = {
        "reactor_top_off.png",
        "reactor_bottom.png",
        "reactor_side.png",
        "reactor_side.png",
        "reactor_side.png",
        "reactor_side.png",
    },
    groups = { matter = 1, fluid_pipe_connects = 1, fluid_pipe_stores = 1, ui_fluid = 1, explody = 2 },

    input_inv = "rods",
    output_inv = "rods",
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("rods", 6)
        meta:set_int("rod_timer", 0)
        meta:set_int("rod_tier", 0)
        meta:set_string("liquid_inv", minetest.serialize({
            max_count_in_each_stack = 100,           -- 100 buckets
            [1] = {
                name = "sbz_resources:water_source", -- forced to be water
                count = 0,
                can_change_name = false,
            },
        }))
        meta:set_string("formspec", "formspec_version[7]size[10.2,10.8]" ..
            sbz_api.bar(0, 0, 0.2, 0.2, " Water Sources",
                "Reactor Water Storage", "Don't let it get too low.") .. [[
list[context;rods;6.2,0.2;2,3;]
list[current_player;main;0.2,5.4;8,4;]
listring[]
    ]])
    end,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        minetest.get_meta(pos):set_string("owner", placer:get_player_name())
        return pipeworks.after_place(pos)
    end,
    on_liquid_inv_update = function(pos, lqinv)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", "formspec_version[7]size[10.2,10.8]" ..
            sbz_api.bar(lqinv[1].count, lqinv.max_count_in_each_stack, 0.2, 0.2, " Water Sources",
                "Reactor Water Storage", "Don't let it get too low.") .. [[
list[context;rods;6.2,0.2;2,3;]
list[current_player;main;0.2,5.4;8,4;]
listring[]
    ]])
    end,
    autostate = true,
    action = function(pos, _, meta, supply, demand)
        local inv = meta:get_inventory()
        local lqinv = core.deserialize(meta:get_string("liquid_inv"))
        if not lqinv then -- the reactor already exploded, it seems like?
            return 0
        end

        local rodtimer = meta:get_int("rod_timer")

        if rodtimer <= 0 then -- no rods, attempt to get some from inventory
            if lqinv[1].count == 0 then
                meta:set_string("infotext", "No water and no fuel rods")
                return 0
            end
            local rodstack = ItemStack("")
            if inv:contains_item("rods", "sbz_chem:thorium_fuel_rod 6") then
                rodstack = inv:remove_item("rods", "sbz_chem:thorium_fuel_rod 6")
            elseif inv:contains_item("rods", "sbz_chem:uranium_fuel_rod 6") then
                rodstack = inv:remove_item("rods", "sbz_chem:uranium_fuel_rod 6")
            elseif inv:contains_item("rods", "sbz_chem:plutonium_fuel_rod 6") then
                rodstack = inv:remove_item("rods", "sbz_chem:plutonium_fuel_rod 6")
            end

            if rodstack:is_empty() then
                meta:set_string("infotext", "Need fuel rods.")
                return 0
            end
            local tier = core.get_item_group(rodstack:get_name(), "fuel_rod")
            -- mercy on noobs
            if tier == 3 and count_nodes_within_radius(pos, "sbz_resources:water_source", 5) < ((9 * 9 * 9) - 1) / 2 then
                inv:add_item("rods", rodstack)
                meta:set_string("infotext",
                    "Not enough water near the reactor, either put more water near your reactor (needs a lot around the reactor) or don't use plutonium fuel rods.")
                return 0
            end
            meta:set_int("rod_tier", tier)
            meta:set_int("rod_timer", rod_duration) -- 6 fuel rods will last 3 hours
        end
        -- alright, from that if statement, while it doesn't look obvious at first, we are sure we have a rod active in some way
        rodtimer = meta:get_int("rod_timer")
        local tier = meta:get_int("rod_tier")

        -- 1 water every tick i guess... for all fuel rods... sure
        -- so check water
        if lqinv[1].count <= 0 then
            -- attempt to explode
            if tier == 1 then -- but thorium ones don't explode so just don't make them do anything.. so it just pauses
                meta:set_string("infotext", "Out of water, but you have thorium fuel rods so the reactor didn't explode.")
                return 0
            end
            -- explode
            local owner = minetest.get_meta(pos):get_string("owner")
            minetest.sound_play({ name = "distant-explosion-47562", gain = 0.4 }, { pos = pos }) -- we gotta get better sfx
            local strength = 1
            if tier == 3 then strength = 2 end
            sbz_api.explode(pos, 20 * strength, 0.9 * strength, false, owner)
            core.remove_node(pos)
            explosion_particle_def.pos = pos
            explosion_particle_def.attract.origin = pos
            minetest.add_particlespawner(explosion_particle_def)
            return 10000 -- yeah sure why not
        end

        if tier == 3 then
            -- must be somewhat submerged in water..
            -- 50% of nodes in a r=2 area around the reactor must be water sources, around the reactor, the check gets performed in a r=5 area
            -- basically just put it in a pond you should be good and don't let radiated water kill your reactor

            -- edit, the information above is outdated:
            -- 31 water nodes in 11x11x11 space, just have some water pls, i changed div by 2 to div by 4
            -- edit: ok so.. yeah this needs to be optimized... so it will only get called once per 15s
            local count = meta:get_int("liquid_check")
            if (count + (pos.x + pos.y + pos.z)) % 15 == 0 then
                if count_nodes_within_radius(pos, "sbz_resources:water_source", 5) < ((5 * 5 * 5) - 1) / 4 then
                    -- i know... duplicating explosion code... cringe bad yeah yeah
                    local owner = minetest.get_meta(pos):get_string("owner")
                    minetest.sound_play({ name = "distant-explosion-47562", gain = 0.4 }, { pos = pos }) -- we gotta get better sfx
                    sbz_api.explode(pos, 20 * 2, 0.9 * 2, false, owner)
                    core.remove_node(pos)
                    explosion_particle_def.pos = pos
                    explosion_particle_def.attract.origin = pos
                    minetest.add_particlespawner(explosion_particle_def)
                    return 10000
                end
            end
            meta:set_int("liquid_check", meta:get_int("liquid_check") + 1)
        end

        -- great... now
        -- render formspec BEFORE consuming water cuz then it will never show that its 100% full
        meta:set_string("formspec", "formspec_version[7]size[10.2,10.8]" ..
            sbz_api.bar(lqinv[1].count, lqinv.max_count_in_each_stack, 0.2, 0.2, " Water Sources",
                "Reactor Water Storage", "Don't let it get too low.") .. [[
list[context;rods;6.2,0.2;2,3;]
list[current_player;main;0.2,5.4;8,4;]
listring[]
    ]])
        -- consume water
        lqinv[1].count = lqinv[1].count - 1
        meta:set_string("liquid_inv", core.serialize(lqinv))



        meta:set_int("rod_timer", rodtimer - 1)
        meta:set_string("infotext",
            string.format("Working, used: %.3f %%", (100 - (rodtimer / rod_duration) * 100)))
        return tier2power[tier]
    end,
}, {
    tiles = {
        "reactor_top_on.png",
        "reactor_bottom.png",
        "reactor_side.png",
        "reactor_side.png",
        "reactor_side.png",
        "reactor_side.png",
    },
    -- can do some evil chain explosion logic but wont :>
    groups = { matter = 1, radioactive = 10 },
    diggable = false,
    light_source = 14,
})

-- the scary
local xray_demand = 1800
sbz_api.register_stateful_machine("sbz_chem:xray", {
    description = "X-ray emitter",
    tiles = {
        "xray_top.png",
        "xray_top.png",
        "xray_side.png",
    },
    groups = { matter = 1, },
    autostate = true,
    action = function(pos, _, meta, supply, demand)
        if supply < demand + xray_demand then
            meta:set_string("infotext",
                "Needs 1800 power. Maybe because of that this might be a little... dangerous... hmm.... no i'm sure it's nothing...")
            return 0, false
        end
        meta:set_string("infotext", "On")
        return xray_demand, true
    end,
}, {
    groups = { matter = 1, radioactive = 30 },
    tiles = {
        "blank.png^[invert:rgba^[colorize:cyan:255",
        "blank.png^[invert:rgba^[colorize:cyan:255",
        "blank.png^[invert:rgba^[colorize:cyan:255",
    },
    light_source = 14,
})

core.register_craft {
    output = "sbz_chem:xray_off",
    recipe = {
        { "sbz_chem:plutonium_block", "sbz_chem:plutonium_block",         "sbz_chem:plutonium_block", },
        { "sbz_chem:plutonium_block", "sbz_resources:phlogiston_circuit", "sbz_chem:plutonium_block", },
        { "sbz_chem:plutonium_block", "sbz_chem:plutonium_block",         "sbz_chem:plutonium_block", },
    }
}

core.register_craft {
    output = "sbz_chem:nuclear_reactor_off",
    recipe = {
        { "sbz_power:solid_charged_field",    "sbz_resources:phlogiston_circuit",    "sbz_power:solid_charged_field" },
        { "sbz_resources:phlogiston_circuit", "sbz_resources:storinator_neutronium", "sbz_resources:phlogiston_circuit" },
        { "sbz_power:solid_charged_field",    "sbz_resources:phlogiston_circuit",    "sbz_power:solid_charged_field" }
    }
}
