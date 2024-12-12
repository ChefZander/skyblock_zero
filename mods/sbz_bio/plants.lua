local sprouts = {
    "sbz_bio:pyrograss_1",
    "sbz_bio:stemfruit_plant_1"
}

local up = vector.new(0, 1, 0)


local fert_use = function(itemstack, user, pointed)
    if pointed.type ~= "node" then return end

    local pos = pointed.under
    local node = minetest.get_node(pos)
    local name = node.name
    local def = minetest.registered_nodes[node.name] or {}


    if minetest.get_item_group(name, "soil") > 0
        and minetest.registered_nodes[minetest.get_node(pos + up).name].buildable_to
        and name ~= "sbz_bio:fertilized_dirt"
    then
        if not (sbz_api.get_node_heat(pos) > 7 and sbz_api.is_sky_exposed(pos) and sbz_api.is_hydrated(pos)) then return end
        minetest.set_node(pos + up, { name = sprouts[math.random(#sprouts)] })
        --   elseif minetest.get_item_group(name, "plant") > 0 and def.grow then
        --        def.grow(pos, node)
    elseif minetest.get_item_group(name, "sapling") > 0 then
        def.grow(pos)
    elseif def.spread then
        if def.spread(pos) == false then return end
    else
        return
    end
    itemstack:take_item()
    return itemstack
end
minetest.register_craftitem("sbz_bio:fertilizer", {
    description = "Fertilizer",
    inventory_image = "fertilizer.png",
    on_place = fert_use,
    on_use = fert_use,
    groups = { ui_bio = 1 },
})

minetest.register_craft({
    type = "shapeless",
    output = "sbz_bio:fertilizer",
    recipe = { "sbz_bio:algae", "sbz_bio:algae", "sbz_bio:algae" }
})

function sbz_api.plant_grow(next_stage)
    return function(pos, node)
        if node.param2 > 0 then
            node.param2 = node.param2 - 1
        else
            node.name = next_stage
        end
        minetest.swap_node(pos, node)
    end
end

function sbz_api.plant_growth_tick(num_ticks)
    return function(pos, node)
        if sbz_api.get_node_heat(pos) > 7 and sbz_api.is_sky_exposed(pos) and sbz_api.is_hydrated(pos) then
            local meta = minetest.get_meta(pos)
            local count = meta:get_int("count") + 1

            local under = vector.copy(pos)
            under.y = under.y - 1

            local soil = core.get_item_group((sbz_api.get_node_force(under) or { name = "lol" }).name, "soil")

            if count >= (num_ticks / soil) then
                count = 0
                minetest.registered_nodes[node.name].grow(pos, node)
            end
            meta:set_int("count", count)
            return true
        end
    end
end

function sbz_api.plant_wilt(stages)
    return function(pos, node)
        node.param2 = node.param2 + 1
        minetest.swap_node(pos, node.param2 >= stages and { name = "air" } or node)
    end
end

function sbz_api.plant_plant(plant, nodes)
    return function(itemstack, user, pointed)
        for _, node in ipairs(nodes) do
            if string.sub(node, 1, 6) == "group:" and minetest.get_item_group(minetest.get_node(pointed.above - up).name, string.sub(node, 7)) > 0
                or minetest.get_node(pointed.above - up).name == node then
                local _, pos = minetest.item_place_node(ItemStack(plant), user, pointed)
                if pos then
                    itemstack:take_item()
                    return itemstack
                end
                return
            end
        end
    end
end

function sbz_api.register_plant(name, defs)
    defs.description = defs.description or ""
    defs.drop = defs.drop
    defs.growth_rate = defs.growth_rate or 1
    defs.co2_demand = defs.co2_demand or 0
    defs.width = defs.width or 0.5
    defs.height_min = defs.height_min or 0.5
    defs.height_max = defs.height_max or 0.5
    defs.stages = defs.stages or 4

    for i = 1, defs.stages - 1 do
        local interpolant = (i - 1) / (defs.stages - 1)
        local height = defs.height_min * (1 - interpolant) + defs.height_max * interpolant
        minetest.register_node("sbz_bio:" .. name .. "_" .. i, {
            description = defs.description,
            drawtype = "plantlike",
            tiles = { name .. "_" .. i .. ".png" },
            inventory_image = name .. "_" .. i .. ".png",
            selection_box = { type = "fixed", fixed = { -defs.width, -0.5, -defs.width, defs.width, height, defs.width } },
            paramtype = "light",
            sunlight_propagates = true,
            paramtype2 = "color",
            palette = "wilting_palette.png",
            walkable = false,
            groups = { dig_immediate = 2, attached_node = 1, plant = 1, needs_co2 = defs.co2_demand, habitat_conducts = 1, transparent = 1, not_in_creative_inventory = 1, burn = 1, nb_nodig = 1 },
            drop = {},
            growth_tick = sbz_api.plant_growth_tick(defs.growth_rate),
            grow = sbz_api.plant_grow("sbz_bio:" .. name .. "_" .. (i + 1)),
            wilt = sbz_api.plant_wilt(2)
        })
    end
    minetest.register_node("sbz_bio:" .. name .. "_" .. defs.stages, {
        description = defs.description,
        drawtype = "plantlike",
        tiles = { name .. "_" .. defs.stages .. ".png" },
        inventory_image = name .. "_" .. defs.stages .. ".png",
        selection_box = { type = "fixed", fixed = { -defs.width, -0.5, -defs.width, defs.width, defs.height_max, defs.width } },
        paramtype = "light",
        sunlight_propagates = true,
        paramtype2 = "color",
        palette = "wilting_palette.png",
        walkable = false,
        groups = { matter = 3, oddly_breakable_by_hand = 3, attached_node = 1, habitat_conducts = 1, transparent = 1, not_in_creative_inventory = 1, burn = 1 },
        drop = defs.drop
    })
end

--Pyrograss, hardy and quick to grow, highly flammable due to its carbon content
--To be used in rockets and explosives and stuff
sbz_api.register_plant("pyrograss", {
    description = "Pyrograss Plant",
    drop = "sbz_bio:pyrograss 2",
    growth_rate = 4,
    width = 0.25,
    height_min = -0.375,
    height_max = 0
})

minetest.register_craftitem("sbz_bio:pyrograss", {
    description = "Pyrograss",
    inventory_image = "pyrograss_4.png",
    groups = { burn = 30 },
    on_place = sbz_api.plant_plant("sbz_bio:pyrograss_1", { "group:soil" })
})

--Stemfruit, generic plant, quite versatile
--To be used to craft other plants
sbz_api.register_plant("stemfruit_plant", {
    description = "Stemfruit Plant",
    drop = "sbz_bio:stemfruit 3",
    growth_rate = 8,
    co2_demand = 1,
    width = 0.125,
    height_min = -0.25,
    height_max = 0.5
})

minetest.register_craftitem("sbz_bio:stemfruit", {
    description = "Stemfruit",
    inventory_image = "stemfruit.png",
    groups = { burn = 12 },
    on_place = sbz_api.plant_plant("sbz_bio:stemfruit_plant_1", { "group:soil" })
})

--Warpshroom, grows slowly, has teleportation powers
--To be used later in teleporters
sbz_api.register_plant("warpshroom", {
    description = "Warpshroom Plant",
    drop = "sbz_bio:warpshroom 2",
    growth_rate = 16,
    co2_demand = 1,
    width = 0.25,
    height_min = -0.3125,
    height_max = 0.25,

})

local function teleport_randomly(user)
    local user_pos = vector.round(user:get_pos())
    for _ = 1, 1000 do
        local pos = user_pos + vector.new(math.random(-16, 16), math.random(-16, 16), math.random(-16, 16))
        if not minetest.registered_nodes[minetest.get_node(pos).name].walkable
            and not minetest.registered_nodes[minetest.get_node(pos + up).name].walkable
            and minetest.registered_nodes[minetest.get_node(pos - up).name].walkable then
            user:set_pos(pos - up * 0.5)
        end
    end
end

minetest.register_craftitem("sbz_bio:warpshroom", {
    description = "Warpshroom",
    inventory_image = "warpshroom_4.png",
    on_place = sbz_api.plant_plant("sbz_bio:warpshroom_1", { "group:matter" }),
    on_use = function(itemstack, user)
        teleport_randomly(user)
        unlock_achievement(user:get_player_name(), "Not Chorus Fruit")
        itemstack:take_item()
        return itemstack
    end,
    groups = { ui_bio = 1 }
})

minetest.register_craft({
    type = "shapeless",
    output = "sbz_bio:warpshroom",
    recipe = { "sbz_bio:stemfruit", "sbz_meteorites:neutronium" }
})

--Fiberweed, multi-node seaweed which grows vertically, requires water along its entire stem
--To be used in making string and fabric for various uses
local function is_all_water(pos, leveled)
    for i = 1, math.ceil(leveled / 16) do
        local nodename = minetest.get_node(pos + up * i).name
        if nodename ~= "sbz_resources:water_source" and nodename ~= "sbz_resources:water_flowing" then return false end
    end
    return true
end

minetest.register_node("sbz_bio:fiberweed", {
    description = "Fiberweed",
    drawtype = "plantlike_rooted",
    tiles = { "dirt.png^fiberweed_overlay.png", "dirt.png" },
    special_tiles = { { name = "fiberweed_plant.png", tileable_vertical = true } },
    inventory_image = "fiberweed_plant.png",
    selection_box = { type = "fixed", fixed = { { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }, { -0.25, 0.5, -0.25, 0.25, 1.25, 0.25 } } },
    paramtype2 = "leveled",
    place_param2 = 8,
    groups = { matter = 1, plant = 1, needs_co2 = 1, transparent = 1, burn = 2 },
    drop = {},
    node_dig_prediction = "sbz_bio:dirt",
    node_placement_prediction = "",
    on_place = function(itemstack, user, pointed)
        if pointed.type ~= "node" or minetest.get_node(pointed.under).name ~= "sbz_bio:dirt" then return end
        minetest.set_node(pointed.under, { name = "sbz_bio:fiberweed", param2 = 8 })
        itemstack:take_item()
        return itemstack
    end,
    after_dig_node = function(pos, node, meta, user)
        minetest.set_node(pos, { name = "sbz_bio:dirt" })
        unlock_achievement(user:get_player_name(), "Fiberweed")
        local inv = user:get_inventory()
        local drop = inv:add_item("main", "sbz_bio:fiberweed " .. math.floor(node.param2 / 8))
        if drop then minetest.add_item(pos + up, drop) end
    end,
    growth_tick = function(pos, node)
        if sbz_api.get_node_heat(pos + up) > 7 and sbz_api.is_sky_exposed(pos + up * math.ceil(node.param2 / 16)) and is_all_water(pos, node.param2) then
            local meta = minetest.get_meta(pos)
            local count = meta:get_int("count") + 1
            if count >= 4 then
                count = 0
                minetest.registered_nodes[node.name].grow(pos, node)
            end
            meta:set_int("count", count)
            return true
        end
    end,
    grow = function(pos, node)
        if is_all_water(pos, node.param2 + 8) then
            node.param2 = node.param2 + 8
            minetest.swap_node(pos, node)
        end
    end,
    wilt = function(pos, node)
        node.param2 = node.param2 - 8
        minetest.swap_node(pos, node.param2 <= 0 and { name = "sbz_bio:dirt" } or node)
    end
})

minetest.register_craft({
    output = "sbz_bio:fiberweed",
    recipe = {
        { "sbz_bio:algae", "sbz_bio:algae",     "sbz_bio:algae" },
        { "sbz_bio:algae", "sbz_bio:stemfruit", "sbz_bio:algae" },
        { "sbz_bio:algae", "sbz_bio:algae",     "sbz_bio:algae" }
    }
})
