local hash = minetest.hash_node_position
local touched_nodes = {}

local habitat_max_size = 4096

local stack = {}

local wallmounted_to_dir = {
    [0] = { 0, 1, 0 },
    [1] = { 0, -1, 0 },
    [2] = { 1, 0, 0 },
    [3] = { -1, 0, 0 },
    [4] = { 0, 0, 1 },
    [5] = { 0, 0, -1 },
}

-- this function is cancer
-- used to be*
-- maybe kinda is?
function sbz_api.assemble_habitat(start_pos, seen)
    seen = seen or {}

    local index = 0

    index = index + 1
    stack[index] = start_pos

    seen[hash(start_pos)] = true

    local size = 0
    local storage = 0
    local demand = 0
    local power_generated = 0
    local plants = {}
    local co2_sources = {}
    local pos, node, name, def, to_add, cpos, hcpos
    sbz_api.vm_begin()

    local IG = core.get_item_group
    local get_node = sbz_api.get_or_load_node


    while index > 0 and size < habitat_max_size do
        pos = stack[index]
        index = index - 1

        node = get_node(pos)
        name = node.name

        if IG(name, "plant") > 0 then
            local d = IG(name, "needs_co2")
            local under = vector.subtract(pos, vector.new(0, 1, 0))
            local soil = IG(get_node(under).name, "soil")
            d = math.ceil(d * math.max(1, soil))
            table.insert(plants, { pos, node, d })
            demand = demand + d
            local def = core.registered_nodes[name]
            if def.power_per_co2 then
                power_generated = power_generated + math.floor(def.power_per_co2 * d)
            end
        elseif IG(name, "co2_source") > 0 then
            table.insert(co2_sources, { pos, node })
        end

        def = core.registered_nodes[name]
        if def then
            if (name == "air" or IG(name, "habitat_conducts") > 0 or pos == start_pos or def.walkable == false or def.collision_box ~= nil or def.node_box ~= nil) and name ~= "sbz_bio:airlock" then
                for i = 0, 5 do
                    to_add = wallmounted_to_dir[i]
                    cpos = {
                        x = pos.x + to_add[1],
                        y = pos.y + to_add[2],
                        z = pos.z + to_add[3]
                    }
                    hcpos = hash(cpos)
                    if not seen[hcpos] then
                        seen[hcpos] = true
                        index = index + 1
                        stack[index] = cpos
                    end
                end
                size = size + 1
                storage = storage + 1
            end
            if def.store_co2 then
                storage = storage + def.store_co2
            end
        end
        if name == "sbz_bio:habitat_regulator" and pos ~= start_pos then
            return
        end
    end


    if index > 0 then
        core.add_particlespawner {
            amount = 20,
            time = 1,
            collisiondetection = true,
            texture = "star.png^[colorize:red",
            glow = 14,
            pos = start_pos,
            attract = {
                kind = "point",
                origin = start_pos,
                strength = -2,
            },
            radius = (math.sqrt(2) + 0.1) / 2
        }
        return
    end
    if (size - 1) == 0 then return end

    return {
        plants = plants,
        co2_sources = co2_sources,
        size = size - 1,
        demand = demand,
        storage = storage,
        power_generated = power_generated
    }
end

function sbz_api.habitat_tick(start_pos, meta, stage)
    local time = os.time()
    local lag_timer = sbz_api.clock_ms()
    local habitat = sbz_api.assemble_habitat(start_pos)
    if not habitat then
        meta:set_string("infotext",
            ([[
Habitat unenclosed or too large (max size is %s nodes) or there are multiple habitat regulators in the same habitat.
Make sure the habitat is fully sealed. And make sure things like slabs or non-airtight power wires aren't in the walls.
]])
            :format(
                habitat_max_size))
        return
    end
    if sbz_api.accelerated_habitats then stage = 0 end

    local co2 = 0
    local co2_supply_temp = 0
    local co2_supply = 0
    local atm_co2 = meta:get_int("atmospheric_co2")
    if atm_co2 < habitat.storage then
        for _, v in ipairs(habitat.co2_sources) do
            local pos, node = unpack(v)
            if stage == PcgRandom(hash(pos)):next(0, 9) or sbz_api.accelerated_habitats then
                co2 = co2 +
                    minetest.registered_nodes[node.name].co2_action(pos, node, atm_co2 + co2, habitat.storage)
            end
            touched_nodes[hash(pos)] = time
        end
        co2_supply_temp = meta:get_int("co2_supply_temp") + co2
        co2_supply = meta:get_int("co2_supply")
    end
    if stage == 0 then
        co2_supply = co2_supply_temp
        meta:set_int("co2_supply", co2_supply)
        meta:set_int("co2_supply_temp", 0)
    else
        meta:set_int("co2_supply_temp", co2_supply_temp)
    end

    co2 = co2 + meta:get_int("atmospheric_co2")
    for _, v in ipairs(habitat.plants) do
        local pos, node, demand = unpack(v)
        local under = vector.subtract(pos, vector.new(0, 1, 0))
        local soil = minetest.get_item_group((sbz_api.get_or_load_node(under) or { name = "" }).name, "soil")

        if (stage == PcgRandom(hash(pos)):next(0, 9)) or sbz_api.accelerated_habitats then
            if co2 - demand >= 0 then
                co2 = co2 - demand
                local growth_tick = minetest.registered_nodes[node.name].growth_tick or function(...) end
                if growth_tick(pos, node) then touched_nodes[hash(pos)] = time end
            else
                co2 = 0
                break
            end
        end
    end
    co2 = math.min(co2, habitat.storage)
    meta:set_int("atmospheric_co2", co2)

    meta:set_string("infotext", table.concat({
        "CO2 supply: ", math.max(co2_supply, co2_supply_temp),
        "\nCO2 demand: ", habitat.demand,
        "\nHabitat CO2: ", co2 .. "/" .. habitat.storage,
        "\nHabitat size: ", habitat.size,
        habitat.power_generated > 0 and
        ("\nPower Generated: " .. sbz_api.format_power(habitat.power_generated)) or "",
        "\nHabitat lag: " .. math.floor((sbz_api.clock_ms() - lag_timer)) .. "ms"
    }))
    return habitat.power_generated
end

sbz_api.register_machine("sbz_bio:habitat_regulator", {
    description = "Habitat Regulator",
    tiles = { "habitat_regulator.png" },
    groups = { matter = 1, ui_bio = 1 },
    control_action_raw = true,
    after_place_node = function(pos, user)
        unlock_achievement(user:get_player_name(), "Growing Plants")
    end,
    action = function(pos, node, meta, supply, demand)
        if demand + 20 > supply then
            meta:set_string("infotext", "Not enough power, needs: 20")
        else
            local count = meta:get_int("count") + 1
            local power_generated = sbz_api.habitat_tick(pos, meta, count % 10) or 0
            if count >= 10 then
                meta:set_int("count", 0)
            else
                meta:set_int("count", count)
            end
            return 20 - power_generated
        end
        return 20
    end
})

core.register_node("sbz_bio:co2_compactor", {
    description = "CO2 Compactor",
    info_extra = "Stores 30 co2. Habitat regulator doesn't consider it a wall, similar to how airlock works",
    groups = { matter = 2, explody = 8 },
    walkable = false,
    drawtype = "glasslike", -- this is so that when you are inside the node, it looks OK
    store_co2 = 30,
    tiles = { "co2_compactor.png" },
    paramtype = "light"
})

core.register_craft {
    output = "sbz_bio:co2_compactor",
    recipe = {
        { "sbz_bio:cleargrass",        "sbz_resources:matter_blob", "sbz_bio:razorgrass" },
        { "sbz_resources:matter_blob", "sbz_bio:airlock",           "sbz_resources:matter_blob" },
        { "sbz_bio:cleargrass",        "sbz_resources:matter_blob", "sbz_bio:razorgrass" }
    }
}

minetest.register_craft({
    type = "shapeless",
    output = "sbz_bio:habitat_regulator",
    recipe = { "sbz_power:switching_station", "sbz_bio:moss" }
})

minetest.register_abm({
    interval = 10,
    chance = 20,
    nodenames = { "group:plant" },
    action = function(pos, node)
        local touched = touched_nodes[hash(pos)]
        local time = os.time()
        if not touched or time - touched >= 60 then
            local wilt = minetest.registered_nodes[node.name].wilt or function(...) end
            wilt(pos, node)
            touched_nodes[hash(pos)] = time
        end
    end
})
