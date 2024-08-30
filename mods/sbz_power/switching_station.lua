local touched_nodes = {}

local function iterate_around_pos(pos, func)
    for i = 0, 5 do
        local dir = minetest.wallmounted_to_dir(i)
        func(pos + dir, dir)
    end
end

local hash = minetest.hash_node_position
local node_defs = minetest.registered_nodes

function sbz_api.assemble_network(start_pos, seen)
    local by_connector = not not seen
    seen = seen or {}
    local network = {
        generators = {},
        machines = {},
        switching_stations = {},
        batteries = {},
        connectors = {}
    }

    local generators = network.generators
    local machines = network.machines
    local switching_stations = network.switching_stations
    local batteries = network.batteries

    local pipes_counter = 0

    sbz_api.vm_begin()

    local function internal(pos, dir)
        if not seen[hash(pos)] then
            local node = sbz_api.vm_get_node(pos).name
            local is_generator = minetest.get_item_group(node, "sbz_generator") == 1
            local is_machine = minetest.get_item_group(node, "sbz_machine") == 1
            local is_battery = minetest.get_item_group(node, "sbz_battery") == 1
            local is_connector = minetest.get_item_group(node, "sbz_connector") > 0

            local is_conducting = minetest.get_item_group(node, "pipe_conducts") == 1

            if node == "sbz_power:switching_station" then
                if by_connector then
                    touched_nodes[hash(pos)] = os.time()
                elseif hash(pos) ~= hash(start_pos) then
                    switching_stations[#switching_stations + 1] = pos
                end
            elseif is_battery then
                batteries[#batteries + 1] = { pos, node }
            elseif is_generator then
                generators[#generators + 1] = { pos, node }
            elseif is_machine then
                machines[#machines + 1] = { pos, node }
            elseif is_connector then
                node_defs[node].assemble(pos, sbz_api.vm_get_node(pos), dir, network, seen)
            end
            seen[hash(pos)] = true
            if is_conducting then
                pipes_counter = pipes_counter + 1
                iterate_around_pos(pos, internal)
            end
        end
    end
    internal(table.copy(start_pos))
    --sbz_api.vm_abort()
    return network, pipes_counter
end

function sbz_api.switching_station_tick(start_pos)
    if touched_nodes[hash(start_pos)] and os.time() - touched_nodes[hash(start_pos)] < 1 then
        minetest.get_meta(start_pos):set_string("infotext", "Inactive (connected to another network)")
        return
    end

    local t0 = minetest.get_us_time()

    local network, pipes_counter = sbz_api.assemble_network(start_pos)
    local generators = network.generators
    local machines = network.machines
    local switching_stations = network.switching_stations
    local batteries = network.batteries

    local supply = 0
    local demand = 0
    local battery_max = 0

    if #switching_stations > 0 then
        local pos = vector.copy(start_pos)
        local range = vector.new(5, 5, 5)
        minetest.add_particlespawner({
            amount = 500,
            time = 0.3,
            texture = "error_particle.png",
            glow = 14,
            pos = pos,
            radius = 0.1,
            acc = { min = -range, max = range },
            vel = { min = -range, max = range },
            drag = { x = .5, y = .5, z = .5 }
        })
        minetest.remove_node(start_pos)
        return false
    end

    for k, v in ipairs(batteries) do
        local position = v[1]
        local node = v[2]
        local meta = minetest.get_meta(position)

        touched_nodes[hash(position)] = os.time()

        v[3] = node_defs[node].battery_max
        v[4] = meta:get_int("power")
        v[5] = meta

        battery_max = battery_max + v[3]
        supply = supply + v[4]
    end

    local battery_supply_only = supply -- copy

    for k, v in ipairs(generators) do
        local position = v[1]
        local node = v[2]

        touched_nodes[hash(position)] = os.time()
        supply = supply + node_defs[node].action(position, node, minetest.get_meta(position), supply, demand)
    end

    for k, v in ipairs(machines) do
        local position = v[1]
        local node = v[2]

        touched_nodes[hash(position)] = os.time()
        demand = demand + node_defs[node].action(position, node, minetest.get_meta(position), supply, demand)
    end

    local excess = (supply - battery_supply_only) - demand

    for k, v in ipairs(batteries) do
        if excess == 0 then break end
        local position = v[1]
        local node = v[2]
        local max = v[3]
        local current = v[4]
        local meta = v[5]

        if excess > 0 then -- charging
            local power_add = max - current
            if power_add > excess then
                power_add = excess
            end
            excess = excess - power_add
            meta:set_int("power", current + power_add)
        elseif excess < 0 then -- discharging
            local power_remove = current
            if power_remove > -excess then
                power_remove = -excess
            end
            excess = excess + power_remove
            meta:set_int("power", current - power_remove)
        end
    end

    for k, v in ipairs(batteries) do
        local position = v[1]
        local node = v[2]
        local meta = v[5]
        node_defs[node].action(position, node, meta, supply, demand)
    end

    local network_size = #generators + #machines + #batteries + pipes_counter

    local t1 = minetest.get_us_time()

    minetest.get_meta(start_pos):set_string("infotext",
        string.format("Supply: %s\nDemand: %s\nBattery capacity: %s/%s\nLag: %sms\nNetwork Size: %s",
            supply - battery_supply_only,
            demand, battery_supply_only, battery_max, (t1 - t0) / 1000, network_size))
    return true
end

minetest.register_node("sbz_power:switching_station", {
    description = "Switching Station",
    tiles = { "switching_station.png" },
    groups = { matter = 1, cracky = 1, pipe_connects = 1, pipe_conducts = 1 },
    light_source = 3,

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Loading....")
    end,
    info_extra = "If you put 2 of them next to eachother a funny happens",
})

minetest.register_craft({
    output = "sbz_power:switching_station",
    recipe = {
        { "",                           "sbz_resources:matter_plate", "" },
        { "sbz_resources:matter_plate", "sbz_resources:matter_plate", "sbz_resources:matter_plate" },
        { "",                           "sbz_resources:matter_plate", "" }
    }
})

minetest.register_abm({
    label = "Machine activation - switching stations",
    nodenames = { "sbz_power:switching_station" },
    interval = 1,
    chance = 1,
    action = sbz_api.switching_station_tick
})

local timeout_limit = 2 -- seconds

minetest.register_abm({
    label = "Machine timeout check",
    nodenames = { "group:sbz_machine" },
    interval = timeout_limit,
    chance = 1,
    action = function(pos, node)
        if not touched_nodes[hash(pos)] or (os.time() - touched_nodes[hash(pos)] >= timeout_limit) then
            minetest.get_meta(pos):set_string("infotext", "No network found")
            if node_defs[node.name].stateful then
                sbz_api.turn_off(pos)
            end
            if node_defs[node.name].on_timeout then
                node_defs[node.name].on_timeout(pos, node)
            end
        end
    end
})
