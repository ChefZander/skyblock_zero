minetest.register_node("sbz_bio:dirt", {
    description = "Dirt",
    tiles = { "dirt.png" },
    groups = {
        explody = 10,
        matter = 2,
        crumbly = 1,
        moss_growable = 1,
        soil = 1,
        oddly_breakable_by_hand = 1,
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

minetest.register_node("sbz_bio:fertilized_dirt", {
    description = "Fertilized Dirt",
    tiles = { "fertilized_dirt.png" },
    groups = {
        explody = 10,
        matter = 2,
        crumbly = 1,
        soil = 3,
        oddly_breakable_by_hand = 1,
    },
    paramtype = "light",
    sounds = sbz_api.sounds.dirt(),
    info_extra = "Like dirt, but 3x faster. (And also you can't sprout plants from it.)"
})
minetest.register_craft {
    output = "sbz_bio:fertilized_dirt",
    recipe = {
        { "",                   "sbz_bio:fertilizer", "" },
        { "sbz_bio:fertilizer", "sbz_bio:dirt",       "sbz_bio:fertilizer" },
        { "",                   "sbz_bio:fertilizer", "" },
    }
}


minetest.register_node("sbz_bio:dirt_with_grass", {
    description = "Dirt With Pyrograss",
    tiles = {
        "dirt_with_grass_y.png",
        "dirt.png",
        "dirt_with_grass_xz.png",

    },
    groups = {
        explody = 10,
        matter = 2,
        crumbly = 1,
        soil = 2,
        oddly_breakable_by_hand = 1,
        burn = 5,
    },
    paramtype = "light",
    sounds = sbz_api.sounds.dirt(),
    info_extra = "Spreads",
    on_burn = function(pos)
        if is_air(vector.add(pos, vector.new(0, 1, 0))) then
            core.set_node(pos, { name = "sbz_bio:dirt" })
            core.set_node(vector.add(pos, vector.new(0, 1, 0)), { name = "sbz_bio:fire" })
            core.get_meta(vector.add(pos, vector.new(0, 1, 0))):set_int("co2", 5) -- burn=5
            minetest.get_node_timer(vector.add(pos, vector.new(0, 1, 0))):start(math.random(30, 60))
        end
    end,
})



-- yes i get it, boo, happens outside of the habitat regulator, oh well, i actually like abms
local get_grass_spread_action = function(require_water)
    return function(start_pos)
        local delayed = {}
        local with_water = false
        iterate_around_radius(start_pos, function(pos)
            local node = core.get_node(pos)
            if core.get_item_group(node.name, "soil") > 0
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
    interval = 10 / 3,
    chance = 3,
    action = get_grass_spread_action(true)
})

core.register_abm({
    label = "Grass spread - without water",
    nodenames = { "sbz_bio:dirt_with_grass" },
    neighbors = { "group:soil" },
    without_neighbors = { "group:water" },
    interval = 30,
    chance = 50,
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
