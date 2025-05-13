minetest.register_node("sbz_bio:dirt", unifieddyes.def {
    description = "Dirt",
    tiles = { "dirt.png" },
    paramtype2 = "color",
    groups = {
        explody = 100,
        matter = 2,
        crumbly = 1,
        moss_growable = 1,
        soil = 1,
        oddly_breakable_by_hand = 1,
        charged = 1,
    },
    paramtype = "light", -- if you leave this out, fertilizer wont work
    sounds = sbz_api.sounds.dirt(),
})
minetest.register_craft({
    output = "sbz_bio:dirt",
    recipe = {
        { "sbz_bio:moss", "sbz_bio:moss", "sbz_bio:moss" },
        { "sbz_bio:moss", "sbz_bio:moss", "sbz_bio:moss" },
        { "sbz_bio:moss", "sbz_bio:moss", "sbz_bio:moss" }
    }
})

unified_inventory.register_craft {
    type = "centrifugeing",
    output = "sbz_resources:sand",
    items = { "sbz_bio:dirt" }
}

unified_inventory.register_craft {
    type = "centrifugeing",
    output = "sbz_bio:moss 3",
    items = { "sbz_bio:dirt" }
}

unified_inventory.register_craft {
    type = "centrifugeing",
    output = "sbz_resources:pebble 4",
    items = { "sbz_bio:dirt" }
}

minetest.register_node("sbz_bio:fertilized_dirt", unifieddyes.def {
    paramtype2 = "color",
    description = "Fertilized Dirt",
    tiles = { "fertilized_dirt.png" },
    groups = {
        explody = 100,
        matter = 1,
        crumbly = 1,
        soil = 2,
        oddly_breakable_by_hand = 1,
        fertilizer_no_sprout = 1,
    },
    paramtype = "light",
    sounds = sbz_api.sounds.dirt(),
    info_extra = {
        "Plants grow 2x faster than on dirt, on this soil.",
        "Fertilizer can't sprout plants on this soil."
    }
})
minetest.register_craft {
    output = "sbz_bio:fertilized_dirt",
    recipe = {
        { "",                   "sbz_bio:fertilizer", "" },
        { "sbz_bio:fertilizer", "sbz_bio:dirt",       "sbz_bio:fertilizer" },
        { "",                   "sbz_bio:fertilizer", "" },
    }
}


minetest.register_node("sbz_bio:dirt_with_grass", unifieddyes.def {
    paramtype2 = "color",
    description = "Dirt With Pyrograss",
    tiles = {
        "dirt_with_grass_y.png",
        "dirt.png",
        "dirt_with_grass_xz.png",
    },
    groups = {
        explody = 100,
        matter = 2,
        crumbly = 1,
        soil = 1,
        oddly_breakable_by_hand = 1,
        burn = 5,
        charged = 1
    },
    paramtype = "light",
    sounds = sbz_api.sounds.dirt(),
    info_extra = "Spreads, same growth speed as dirt.",
    on_burn = function(pos)
        if is_air(vector.add(pos, vector.new(0, 1, 0))) then
            core.set_node(pos, { name = "sbz_bio:dirt" })
            core.set_node(vector.add(pos, vector.new(0, 1, 0)), { name = "sbz_bio:fire" })
            core.get_meta(vector.add(pos, vector.new(0, 1, 0))):set_int("co2", 5) -- burn=5
            minetest.get_node_timer(vector.add(pos, vector.new(0, 1, 0))):start(math.random(30, 60))
        end
    end,
})

sbz_api.register_stateful_machine("sbz_bio:electric_soil", unifieddyes.def {
    paramtype2 = "colorwallmounted",
    description = "Electric Soil",
    groups = {
        matter = 1,
        soil = 0,
        pipe_connects = 1,
    },
    autostate = true,
    info_power_consume = 40,
    info_extra = "When powered, it's 5 times more powerful than regular dirt.",
    tiles = { "electric_soil_top.png", "electric_soil.png" },
    action = function(p, n, m, supply, demand)
        if supply < demand + 40 then
            m:set_string("infotext", "Off - the plant above might wilt")
            return 40, false
        else
            m:set_string("infotext", "On")
            return 40, true
        end
    end,
    paramtype = "light"
}, {
    light_source = 14,
    groups = {
        matter = 1,
        soil = 5,
        pipe_connects = 1
    }
})
core.register_craft {
    output = "sbz_bio:electric_soil_off",
    recipe = {
        { "sbz_bio:fertilized_dirt", "sbz_bio:fertilized_dirt", "sbz_bio:fertilized_dirt", },
        { "sbz_chem:silver_ingot",   "sbz_chem:silver_ingot",   "sbz_chem:silver_ingot", },
        { "sbz_bio:shockshroom",     "sbz_bio:shockshroom",     "sbz_bio:shockshroom" }
    }
}


-- yes i get it, boo, happens outside of the habitat regulator, oh well, i actually like abms
local get_grass_spread_action = function(require_water)
    return function(start_pos)
        local delayed = {}
        local with_water = false
        iterate_around_radius(start_pos, function(pos)
            local node = core.get_node(pos)
            if core.get_item_group(node.name, "soil") == 1 -- only bad soils
                and node.name ~= "sbz_bio:dirt_with_grass"
                and sbz_api.get_node_heat(pos) >= 8
            then
                delayed[#delayed + 1] = pos
            end

            if core.get_item_group(node.name, "water") > 0 then
                with_water = true
            end
        end)
        if (with_water or (not require_water)) and #delayed ~= 0 then
            core.set_node(delayed[math.random(1, #delayed)], { name = "sbz_bio:dirt_with_grass" })
        end
    end
end

-- water makes it WAY faster
core.register_abm({
    label = "Grass spread - water",
    nodenames = { "sbz_bio:dirt_with_grass" },
    neighbors = { "group:water", "group:soil" },
    interval = 30,
    chance = 5,
    action = get_grass_spread_action(true)
})

core.register_abm({
    label = "Grass spread - without water",
    nodenames = { "sbz_bio:dirt_with_grass" },
    neighbors = { "group:soil" },
    without_neighbors = { "group:water" },
    interval = 100,
    chance = 20,
    action = get_grass_spread_action(false)
})

minetest.register_craft {
    output = "sbz_bio:dirt_with_grass",
    recipe = {
        { "",                  "sbz_bio:pyrograss", "" },
        { "sbz_bio:pyrograss", "sbz_bio:dirt",      "sbz_bio:pyrograss" },
        { "",                  "sbz_bio:pyrograss", "" },
    }
}
