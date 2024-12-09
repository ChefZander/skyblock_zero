minetest.register_node("sbz_bio:moss", {
    description = "Moss",
    drawtype = "signlike",
    tiles = { "moss.png" },
    inventory_image = "moss.png",
    selection_box = { type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, -0.375, 0.5 } },
    paramtype = "light",
    sunlight_propagates = true,
    paramtype2 = "wallmounted",
    walkable = false,
    buildable_to = true,
    groups = { matter = 3, oddly_breakable_by_hand = 3, burn = 2, habitat_conducts = 1, transparent = 1, attached_node = 1, explody = 100 },
    spread = function(start_pos) -- janky
        local nearest_water = is_node_within_radius(start_pos, "group:water", 1)
        if nearest_water then
            iterate_around_pos(nearest_water, function(pos)
                local node = minetest.get_node(pos)
                local i = math.random(0, 5)
                local dir = minetest.wallmounted_to_dir(i)
                ---@type function
                local allow_moss_growth = minetest.registered_nodes[node.name].allow_moss_growth
                if allow_moss_growth and not allow_moss_growth(pos, node, -dir) then return end
                if sbz_api.get_node_heat(pos - dir) > 7 then
                    local defs = minetest.registered_nodes[minetest.get_node(pos - dir).name]
                    if defs.liquidtype == "none" and defs.buildable_to then
                        minetest.set_node(pos - dir, { name = "sbz_bio:moss", param2 = i })
                    end
                end
            end)
        else
            return false
        end
    end
})

minetest.register_node("sbz_bio:algae", {
    description = "Algae",
    drawtype = "signlike",
    tiles = { "algae.png" },
    inventory_image = "algae.png",
    selection_box = { type = "fixed", fixed = { -0.5, -0.5, -0.5, 0.5, -0.375, 0.5 } },
    paramtype = "light",
    sunlight_propagates = true,
    paramtype2 = "wallmounted",
    walkable = false,
    buildable_to = true,
    groups = { matter = 3, oddly_breakable_by_hand = 3, burn = 2, habitat_conducts = 1, transparent = 1, explody = 100 },
    spread = function(pos)
        local vec = vector.new(1, 1, 1)
        local water = core.find_nodes_in_area(pos - vec, pos + vec, "sbz_resources:water_source")

        local spread = 0
        for k, v in pairs(water) do
            v.y = v.y + 1
            local node = minetest.get_node(v)
            local def = minetest.registered_nodes[node.name]
            if def.buildable_to and node.name ~= "sbz_bio:algae" and sbz_api.get_node_heat(pos) > 7 then
                spread = spread + 1
                minetest.set_node(v, { name = "sbz_bio:algae", param2 = 1 })
            end
            if spread >= 2 then break end
        end
    end
})

minetest.register_abm({
    interval = 10,
    chance = 20,
    nodenames = { "group:moss_growable" },
    neighbors = { "group:water" },
    action = function(pos, node)
        local i = math.random(0, 5)
        local dir = minetest.wallmounted_to_dir(i)
        local allow_moss_growth = minetest.registered_nodes[node.name].allow_moss_growth
        if allow_moss_growth and not allow_moss_growth(pos, node, -dir) then return end
        if sbz_api.get_node_heat(pos - dir) > 7 then
            local defs = minetest.registered_nodes[minetest.get_node(pos - dir).name]
            if defs.liquidtype == "none" and defs.buildable_to then
                minetest.set_node(pos - dir, { name = "sbz_bio:moss", param2 = i })
            end
        end
    end
})

minetest.register_abm({
    interval = 10,
    chance = 20,
    nodenames = { "sbz_resources:water_source" },
    action = function(pos)
        pos.y = pos.y + 1
        if sbz_api.get_node_heat(pos) > 7 then
            local defs = minetest.registered_nodes[minetest.get_node(pos).name]
            if defs.liquidtype == "none" and defs.buildable_to then
                minetest.set_node(pos, { name = "sbz_bio:algae", param2 = 1 })
            end
        end
    end
})
