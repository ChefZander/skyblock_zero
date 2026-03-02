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

do -- Dirt recipe scope
    local Dirt = 'sbz_bio:dirt'
    local Mo = 'sbz_bio:moss'
    core.register_craft({
        output = Dirt,
        recipe = {
            { Mo, Mo, Mo },
            { Mo, Mo, Mo },
            { Mo, Mo, Mo }
        }
    })
end

sbz_api.recipe.register_craft {
    type = "centrifugeing",
    output = "sbz_resources:sand",
    items = { "sbz_bio:dirt" }
}

sbz_api.recipe.register_craft {
    type = "centrifugeing",
    output = "sbz_bio:moss 3",
    items = { "sbz_bio:dirt" }
}

sbz_api.recipe.register_craft {
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

do -- Fertilized Dirt recipe scope
    local Fertilized_Dirt = 'sbz_bio:fertilized_dirt'
    local Fe = 'sbz_bio:fertilizer'
    local Di = 'sbz_bio:dirt'
    core.register_craft({
        output = Fertilized_Dirt,
        recipe = {
            { '', Fe, '' },
            { Fe, Di, Fe },
            { '', Fe, '' },
        }
    })
end

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

do -- Electric Soil recipe scope
    local Electric_Soil = 'sbz_bio:electric_soil_off'
    local FD = 'sbz_bio:fertilized_dirt'
    local SI = 'sbz_chem:silver_ingot'
    local Sh = 'sbz_bio:shockshroom'
    core.register_craft({
        output = Electric_Soil,
        recipe = {
            { FD, FD, FD },
            { SI, SI, SI },
            { Sh, Sh, Sh },
        }
    })
end

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

do -- Dirt with Grass recipe scope
    local Dirt_with_Grass = 'sbz_bio:dirt_with_grass'
    local Py = 'sbz_bio:pyrograss'
    local Di = 'sbz_bio:dirt'
    core.register_craft({
        output = Dirt_with_Grass,
        recipe = {
            { '', Py, '' },
            { Py, Di, Py },
            { '', Py, '' },
        }
    })
end
