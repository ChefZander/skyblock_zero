local up = vector.new(0, 1, 0)
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

local warpshroom_family = {
    "sbz_bio:warpshroom",
    "sbz_bio:shockshroom",
    "sbz_bio:stemfruit_plant"
}
local pyrograss_family = {
    "sbz_bio:pyrograss",
    "sbz_bio:razorgrass",
    "sbz_bio:cleargrass",
    "sbz_bio:stemfruit_plant",
}
local fiberweed_family = {
    "sbz_bio:fiberweed",
}
local can_turn_into = {
    ["sbz_bio:stemfruit_plant"] = {
        "sbz_bio:pyrograss",
        "sbz_bio:razorgrass",
        "sbz_bio:cleargrass",
        "sbz_bio:warpshroom",
        "sbz_bio:shockshroom",
        --        "sbz_bio:fiberweed",
    },
    ["sbz_bio:warpshroom"] = warpshroom_family,
    ["sbz_bio:shockshroom"] = warpshroom_family,
    ["sbz_bio:pyrograss"] = pyrograss_family,
    ["sbz_bio:razorgrass"] = pyrograss_family,
    ["sbz_bio:cleargrass"] = pyrograss_family,
    ["sbz_bio:fiberweed"] = fiberweed_family,
}

local special_cases = { ["sbz_bio:fiberweed"] = true }
core.after(0, function()
    -- dev script for checking if the stuff i write is actually valid
    for initial_node, node_list in pairs(can_turn_into) do
        if not core.registered_nodes[initial_node .. "_1"] and not special_cases[initial_node] then
            error("Uh oh: " ..
                initial_node)
        end
        for k, v in pairs(node_list) do
            if not core.registered_nodes[v .. "_1"] and not special_cases[v] then error("Uh oh:" .. v) end
        end
    end
end)

local radiation_check = function(pos)
    local nodes = core.find_nodes_in_area(pos - vector.new(5, 5, 5), pos + vector.new(5, 5, 5),
        { "group:radioactive" }, true)
    local rad = 0
    for nodename, poslist in pairs(nodes) do
        local val = core.get_item_group(nodename, "radioactive")
        for _, radpos in ipairs(poslist) do
            local dist = vector.distance(pos, radpos)
            rad = rad + ((val ^ 2) / math.max(0.75, dist ^ 2))
        end
    end
    return rad -- so rad
end



function sbz_api.plant_growth_tick(num_ticks, mutation_chance)
    return function(pos, node)
        local rad = radiation_check(pos)
        -- MUTATIONS
        -- mutation_chance% chance to mutate every second, when a basic neutron emitter is less than 1 node nearby (rad value of 9 i think?)
        local chance = ((rad / 9) * mutation_chance) / 100
        if math.random() < chance then
            local nn = node.name
            local basename = string.sub(nn, 1, -3)
            local stage = string.sub(nn, -2)
            local possibilities = can_turn_into[basename]
            local should_turn_into = possibilities[math.random(1, #possibilities)]
            local newnode = table.copy(node)
            local nodepos = vector.copy(pos)
            if special_cases[should_turn_into] then
                if should_turn_into == "sbz_bio:fiberweed" then
                    if core.get_node(vector.subtract(nodepos, vector.new(0, 1, 0))).name == "sbz_bio:dirt" then
                        nodepos = vector.subtract(nodepos, vector.new(0, 1, 0))
                        should_turn_into = "sbz_bio:fiberweed"
                    else
                        return true -- can't mutate
                    end
                end
                newnode.name = should_turn_into
            else
                newnode.name = should_turn_into .. stage
            end
            core.swap_node(nodepos, newnode)
            return true -- false =>  too much and it will wilt?
        end
        if sbz_api.get_node_heat(pos) > 7 and sbz_api.is_hydrated(pos) then
            local meta = minetest.get_meta(pos)
            local count = meta:get_int("count") + 1

            local under = vector.copy(pos)
            under.y = under.y - 1

            local growth_multiplier = 1
            local soil = core.get_item_group((sbz_api.get_node_force(under) or { name = "" }).name, "soil")
            growth_multiplier = math.max(0, growth_multiplier + (soil - 1))

            iterate_around_pos(pos, function(ipos)
                local n = sbz_api.get_node_force(ipos)
                if n and core.get_item_group(n.name, "growth_boost") > 0 then
                    growth_multiplier = growth_multiplier +
                        (growth_multiplier * (core.get_item_group(n.name, "growth_boost") / 100))
                end
            end)

            meta:set_float("growth_multiplier", growth_multiplier)
            if count >= (num_ticks / growth_multiplier) then
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
        if core.get_item_group(node.name, "no_wilt") == 0 then
            node.param2 = node.param2 + 1
            minetest.swap_node(pos, node.param2 >= stages and { name = "air" } or node)
        end
    end
end

function sbz_api.plant_plant(plant, nodes)
    return function(itemstack, user, pointed)
        for _, node in ipairs(nodes) do
            local use_pointed = "above"
            if pointed.switched then
                use_pointed = "under"
            end
            local soil_node = core.get_node(pointed[use_pointed] - up)
            if string.sub(node, 1, 6) == "group:" and minetest.get_item_group(soil_node.name, string.sub(node, 7)) > 0
                or soil_node.name == node then
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

    local growth_boost_base = (defs.growth_boost or 0) / defs.stages
    local power_per_co2_base = (defs.power_per_co2 or 0) / defs.stages

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
            groups = {
                dig_immediate = 2,
                attached_node = 1,
                plant = 1,
                needs_co2 = defs.co2_demand,
                habitat_conducts = 1,
                transparent = 1,
                not_in_creative_inventory = 1,
                burn = 1,
                nb_nodig = 1,
                no_wilt = defs.no_wilt and 1 or 0,
                growth_boost = growth_boost_base * i
            },
            drop = {},
            growth_tick = sbz_api.plant_growth_tick(defs.growth_rate, defs.mutation_chance or 10),
            grow = sbz_api.plant_grow("sbz_bio:" .. name .. "_" .. (i + 1)),
            wilt = sbz_api.plant_wilt(2),
            sbz_player_inside = defs.sbz_player_inside,
            power_per_co2 = power_per_co2_base * i
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
        groups = {
            oddly_breakable_by_hand = 3,
            matter = 3,
            attached_node = 1,
            plant = defs.use_co2_in_final_stage and 1 or 0,
            habitat_conducts = 1,
            transparent = 1,
            not_in_creative_inventory = 1,
            burn = 1,
            needs_co2 = defs.use_co2_in_final_stage and defs.co2_demand or 0,
            growth_boost = defs.growth_boost
        },
        drop = defs.drop,
        sbz_player_inside = defs.sbz_player_inside,
        power_per_co2 = defs.power_per_co2,
        growth_tick = defs.use_co2_in_final_stage and function() return true end,
        grow = defs.use_co2_in_final_stage and function() return true end,
        wilt = defs.use_co2_in_final_stage and sbz_api.plant_wilt(2)
    })
end

-- PYROGRASS FAMILY
--Pyrograss, hardy and quick to grow, highly flammable due to its carbon content
--To be used in rockets and explosives and stuff
sbz_api.register_plant("pyrograss", {
    description = "Pyrograss Plant",
    drop = "sbz_bio:pyrograss 2",
    growth_rate = 4,
    family = "sbz_bio:pyrograss",
    width = 0.25,
    height_min = -0.375,
    height_max = 0,
    no_wilt = true,
})
minetest.register_craftitem("sbz_bio:pyrograss", {
    description = "Pyrograss",
    inventory_image = "pyrograss_4.png",
    groups = { burn = 30, eat = 1 },
    on_place = sbz_api.plant_plant("sbz_bio:pyrograss_1", { "group:soil" })
})

-- uses:
-- ingredient in powered dirt
-- 3 razorgrass = 10 fertilizer
-- poison bullets for later
-- compressed razorgrass could maybe look nice
-- grows slightly slower than pyro
-- no co2 demand


playereffects.register_effect_type("poison", "Poisoned", "fx_poison.png",
    { "clearable", "negative", "speed", "health", "negative_health" },
    function(player)
        unlock_achievement(player:get_player_name(), "Poisoned")
        player:set_hp(math.max(0, player:get_hp() - 1))
        player_monoids.speed:add_change(player, 0.5, "sbz_bio:poison")
    end, function(fx, player)
        player_monoids.speed:del_change(player, "sbz_bio:poison")
    end, false, true, 2)

sbz_api.register_plant("razorgrass", {
    description = "Razorgrass Plant",
    drop = "sbz_bio:razorgrass 2",
    growth_rate = 8,
    family = "pyrograss",
    width = 0.25,
    height_min = -0.375,
    height_max = 0,
    sbz_player_inside = function(pos, player)
        playereffects.apply_effect_type("poison", 2, player)
    end
})

core.register_craft {
    type = "shapeless",
    output = "sbz_bio:fertilizer 20",
    recipe = {
        "sbz_bio:razorgrass", "sbz_bio:razorgrass", "sbz_bio:razorgrass"
    }
}
minetest.register_craftitem("sbz_bio:razorgrass", {
    description = "Razorgrass",
    inventory_image = "razorgrass_4.png",
    groups = { burn = 2, eat = -8 },
    eat_fx = { "Poisoned", "Slowed" },
    on_place = sbz_api.plant_plant("sbz_bio:razorgrass_1", { "group:soil" }),
    on_use = function(stack, user, pointed)
        if user.is_fake_player then return end
        playereffects.apply_effect_type("poison", 10, user)
        return core.item_eat(-8)(stack, user, pointed)
    end
})

-- cleargass, uses:
-- clearing effect
-- blinding bullets for later
-- could be used to "polish" decoblocks
-- boosts plants near it by 15% when in full growth stage, consumes co2, makes plants consume more co2
-- grows slowly

playereffects.register_effect_type("immune", "Immune", "fx_immunity.png", { "immunity" },
    function(player)
        unlock_achievement(player:get_player_name(), "Immune")
        playereffects.cancel_effect_group("clearable", player:get_player_name())
    end, function(fx, player) end, false, true, 0.1)

sbz_api.register_plant("cleargrass", {
    description = "Cleargrass Plant",
    drop = "sbz_bio:cleargrass 2",
    growth_rate = 4,
    co2_demand = 5,
    family = "pyrograss",
    width = 0.25,
    height_min = -0.375,
    height_max = 0,
    sbz_player_inside = function(pos, player)
        playereffects.apply_effect_type("immune", 10, player)
    end,
    use_co2_in_final_stage = true,
    growth_boost = 25,

})

minetest.register_craftitem("sbz_bio:cleargrass", {
    description = "Cleargrass",
    inventory_image = "cleargrass_4.png",
    groups = { burn = 0, eat = 0 },
    eat_fx = { "Cleared" },
    on_place = sbz_api.plant_plant("sbz_bio:cleargrass_1", { "group:soil" }),
    on_use = function(stack, user, pointed)
        playereffects.apply_effect_type("immune", 30 / 0.1, user)
        return core.item_eat(0)(stack, user, pointed)
    end
})


-- STEMFRUIT: base of all plants
--Stemfruit, generic plant, quite versatile
--To be used to craft other plants
sbz_api.register_plant("stemfruit_plant", {
    description = "Stemfruit Plant",
    drop = "sbz_bio:stemfruit 3",
    family = "stemfruit",
    growth_rate = 8,
    co2_demand = 1,
    width = 0.125,
    height_min = -0.25,
    height_max = 0.5,
    mutation_chance = 80,
})

minetest.register_craftitem("sbz_bio:stemfruit", {
    description = "Stemfruit",
    inventory_image = "stemfruit.png",
    groups = { burn = 12, eat = 5 },
    on_place = function(itemstack, user, pointed)
        local use_pointed = "above"
        if pointed.switched then
            use_pointed = "under"
        end
        local soil_node = core.get_node(pointed[use_pointed] - up)
        local water_node = core.get_node(pointed[use_pointed] + up)
        if minetest.get_item_group(soil_node.name, "soil") > 0 then
            if core.get_item_group(water_node.name, "water") > 0 then
                return core.registered_items["sbz_bio:fiberweed"].on_place(itemstack, user, pointed)
            end
            local _, pos = minetest.item_place_node(ItemStack("sbz_bio:stemfruit_plant_1"), user, pointed)
            if pos then
                itemstack:take_item()
                return itemstack
            end
            return
        end
    end --sbz_api.plant_plant("sbz_bio:stemfruit_plant_1", { "group:soil" })
})


-- SHROOM FAMILY

--Warpshroom, grows slowly, has teleportation powers
--To be used later in teleporters
sbz_api.register_plant("warpshroom", {
    description = "Warpshroom Plant",
    drop = "sbz_bio:warpshroom 2",
    family = "warpshroom",
    growth_rate = 16,
    co2_demand = 1,
    width = 0.25,
    height_min = -0.3125,
    height_max = 0.25,
})

local warpshroom_teleport_radius = 16
local function teleport_randomly(user)
    local user_pos = vector.round(user:get_pos())
    for _ = 1, 1000 do
        local pos = user_pos +
            vector.new(math.random(-warpshroom_teleport_radius, warpshroom_teleport_radius),
                math.random(-warpshroom_teleport_radius, warpshroom_teleport_radius),
                math.random(-warpshroom_teleport_radius, warpshroom_teleport_radius))
        if not minetest.registered_nodes[minetest.get_node(pos).name].walkable
            and not minetest.registered_nodes[minetest.get_node(pos + up).name].walkable
            and minetest.registered_nodes[minetest.get_node(pos - up).name].walkable then
            return user:set_pos(pos - up * 0.5) -- this was missing a "return"... yeah... bad bad
        end
    end
end

local eat = core.item_eat(6)

minetest.register_craftitem("sbz_bio:warpshroom", {
    description = "Warpshroom",
    inventory_image = "warpshroom_4.png",
    on_place = sbz_api.plant_plant("sbz_bio:warpshroom_1", { "group:matter" }),
    on_use = function(itemstack, user, pointed)
        teleport_randomly(user)
        unlock_achievement(user:get_player_name(), "Not Chorus Fruit")
        return eat(itemstack, user, pointed)
    end,
    groups = { ui_bio = 1, eat = 6 }
})
--[[
minetest.register_craft({
    type = "shapeless",
    output = "sbz_bio:warpshroom",
    recipe = { "sbz_bio:stemfruit", "sbz_meteorites:neutronium" }
})
]]
-- Shockshroom, 1/2 chance to make 50cj, needs 2 co2
-- ingredient in powered dirt
playereffects.register_effect_type("shocked", "Shocked", "fx_shocked.png", { "clearable", "speed" }, function(player)
    ---modifies the vector, returns it
    local abs_y = function(vec)
        vec.y = math.abs(vec.y)
        return vec
    end

    -- mild loss of control and bad combo with wet
    unlock_achievement(player:get_player_name(), "Shocked")
    player:add_velocity(vector.multiply(vector.random_direction(), 2))
    player_monoids.speed:add_change(player, 1.2, "sbz_bio:shocked")
    if playereffects.has_effect_type(player:get_player_name(), "wet") then
        player:set_hp(math.max(0, player:get_hp() - 8))
        local pos = player:get_pos()
        minetest.add_particlespawner({
            amount = 50,
            time = 0.1,
            radius = { min = 0.1, max = 0.5 },
            pos = pos,
            vel = { min = { x = -5, y = -5, z = -5 }, max = { x = 5, y = 5, z = 5 } },
            exptime = { min = 15, max = 25 },
            size = { min = 0.5, max = 1 },
            collisiondetection = false,
            vertical = false,
            texture = "star.png^[colorize:yellow:255",
            glow = 14
        })
        player:add_velocity(abs_y(vector.multiply(vector.random_direction(), 8)))
        playereffects.cancel_effect_type("shocked", false, player:get_player_name())
    end
end, function(fx, player)
    player_monoids.speed:del_change(player, "sbz_bio:shocked")
end, false, true, 0.5)

sbz_api.register_plant("shockshroom", {
    description = "Shockshroom Plant",
    drop = "sbz_bio:shockshroom 2",
    family = "warpshroom",
    growth_rate = 6,
    co2_demand = 2,
    width = 0.25,
    height_min = -0.3125,
    height_max = 0.25,
    sbz_player_inside = function(pos, player)
        playereffects.apply_effect_type("shocked", 2 / 0.5, player)
    end,
    power_per_co2 = 10,
    use_co2_in_final_stage = true,
})

minetest.register_craftitem("sbz_bio:shockshroom", {
    description = "Shockshroom",
    inventory_image = "shockshroom_4.png",
    on_place = sbz_api.plant_plant("sbz_bio:shockshroom_1", { "group:soil" }),
    groups = { ui_bio = 1, eat = -1 },
    on_use = function(stack, user, pointed)
        if user.is_fake_player then return end
        playereffects.apply_effect_type("shocked", 180 / 0.5, user, 0.5)
        return core.item_eat(-1)(stack, user, pointed)
    end
})

-- STARFRUIT FAMILY (unlike the others, there is no base "starfruit" plant)
-- todo


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
        if sbz_api.get_node_heat(pos + up) > 7 and is_all_water(pos, node.param2) then
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
--[[
minetest.register_craft({
    output = "sbz_bio:fiberweed",
    recipe = {
        { "sbz_bio:algae", "sbz_bio:algae",     "sbz_bio:algae" },
        { "sbz_bio:algae", "sbz_bio:stemfruit", "sbz_bio:algae" },
        { "sbz_bio:algae", "sbz_bio:algae",     "sbz_bio:algae" }
    }
})

]]
