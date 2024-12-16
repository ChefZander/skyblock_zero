local all_switching_stations = {} -- h(pos) = true|nil

sbz_api.switching_station_networks = {}


local touched_nodes = {}

---@type function
local hash = minetest.hash_node_position
local h = hash
---@type function
local unhash = minetest.get_position_from_hash
---@type table
local node_defs = minetest.registered_nodes
---@type function
local IG = minetest.get_item_group

---@param start_pos vector
---@param seen table
function sbz_api.assemble_network(start_pos, seen)
    local t0 = minetest.get_us_time()
    local by_connector = not not seen
    seen = seen or {}
    local network = {
        generators = {},
        machines = {},
        switching_stations = {},
        batteries = {},
        connectors = {},
        subticking_machines = {},
    }

    local generators = network.generators
    local machines = network.machines
    local switching_stations = network.switching_stations
    local batteries = network.batteries

    -- from wikipedia's pseudocode for BFS
    seen = seen or {}
    setmetatable(seen, {
        __index = function(t, k)
            return rawget(t, h(k))
        end,
        __newindex = function(t, k, v)
            rawset(t, h(k), v)
        end
    })
    local queue = Queue.new()
    queue:enqueue({ start_pos })
    seen[start_pos] = true

    sbz_api.vm_begin()

    -- inspired by https://github.com/minetest-mods/digilines/blob/7d4895d5d4a093041e3e6c8a8676f3b99bb477b7/internal.lua#L99

    while not queue:is_empty() do
        local current_pos, dir = unpack(queue:dequeue())
        local nn = (sbz_api.get_node_force(current_pos) or {}).name -- node name
        local is_conducting = IG(nn, "pipe_conducts") == 1

        local is_generator = IG(nn, "sbz_generator") == 1
        local is_machine = IG(nn, "sbz_machine") == 1
        local is_battery = IG(nn, "sbz_battery") == 1
        local is_connector = IG(nn, "sbz_connector") > 0
        local is_subticking = IG(nn, "sbz_machine_subticking") == 1

        if nn == "sbz_power:switching_station" then
            if by_connector then
                touched_nodes[hash(current_pos)] = os.time()
            elseif h(current_pos) ~= h(start_pos) then
                switching_stations[#switching_stations + 1] = current_pos
            end
        elseif is_battery then
            batteries[#batteries + 1] = { current_pos, nn, dir }
        elseif is_generator then
            generators[#generators + 1] = { current_pos, nn, dir }
        elseif is_machine then
            machines[#machines + 1] = { current_pos, nn, dir }
        elseif is_connector then
            minetest.registered_nodes[nn].assemble(current_pos, sbz_api.vm_get_node(current_pos), dir, network, seen)
        end

        if is_subticking then
            network.subticking_machines[#network.subticking_machines + 1] = { current_pos, nn }
        end

        if is_conducting then
            iterate_around_pos(current_pos, function(pos, dir)
                if not seen[pos] then
                    seen[pos] = true
                    queue:enqueue({ pos, dir })
                end
            end)
        end
    end

    network.lag = minetest.get_us_time() - t0
    return network
end

function sbz_api.switching_station_tick(start_pos)
    if touched_nodes[hash(start_pos)] and os.time() - touched_nodes[hash(start_pos)] < 1 then
        minetest.get_meta(start_pos):set_string("infotext", "Inactive (connected to another network)")
        return
    end

    local meta = minetest.get_meta(start_pos)
    local network_before = sbz_api.switching_station_networks[hash(start_pos)]

    if network_before ~= nil then
        -- ah batteries
        local excess = (network_before.supply - network_before.battery_supply_only) - network_before.demand
        local supply = network_before.supply
        local demand = network_before.demand
        for k, v in ipairs(network_before.batteries) do
            if excess == 0 then break end
            local position = v[1]
            local node = v[2]
            local dir = v[3]
            local max = v[4]
            local current = v[5]
            local meta = minetest.get_meta(position)

            local set_power = node_defs[node].set_power or
                function(pos, node, meta, current_power, supplied_power, dir)
                    meta:set_int("power", supplied_power)
                end

            if excess > 0 then -- charging
                local power_add = max - current
                if power_add > excess then
                    power_add = excess
                end
                excess = excess - power_add
                set_power(position, node, meta, current, current + power_add, dir)
            elseif excess < 0 then -- discharging
                local power_remove = current
                if power_remove > -excess then
                    power_remove = -excess
                end
                excess = excess + power_remove
                set_power(position, node, meta, current, current - power_remove, dir)
            end
        end

        for k, v in ipairs(network_before.batteries) do
            local position = v[1]
            local node = v[2]
            local dir = v[3]
            node_defs[node].action(position, node, minetest.get_meta(position), supply, demand, dir)
        end

        local network_size = #network_before.generators + #network_before.machines + #network_before.batteries

        meta:set_string("infotext",
            string.format(
                "Supply: %s\nDemand: %s\nBattery capacity: %s\nLag: %sms\nNetwork Size: %s",
                sbz_api.format_power(network_before.supply - network_before.battery_supply_only),
                sbz_api.format_power(network_before.demand),
                sbz_api.format_power(network_before.battery_supply_only, network_before.battery_max),
                network_before.lag / 1000, network_size
            )
        )
    end

    local t0 = minetest.get_us_time()

    ---@diagnostic disable-next-line: missing-parameter
    local network = sbz_api.assemble_network(start_pos)
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
        if meta:get_int("force_off") == 1 then
            table.remove(batteries, k)
        else
            touched_nodes[hash(position)] = os.time()

            local d = node_defs[node]
            v[4] = d.battery_max

            if d.get_power then
                v[5] = d.get_power(position, node, meta, supply, demand, v[3])
            else
                v[5] = meta:get_int("power")
            end

            battery_max = battery_max + v[4]
            supply = supply + v[5]
        end
    end

    network.battery_supply_only = supply -- copy

    for k, v in ipairs(generators) do
        local position = v[1]
        local node = v[2]
        if minetest.get_meta(v[1]):get_int("force_off") ~= 1 then
            touched_nodes[hash(position)] = os.time()
            local action_result = node_defs[node].action(position, node, minetest.get_meta(position), supply, demand)
            assert(action_result, "You need to return something in the action function... fauly node: " .. node)
            supply = supply + action_result
        end
    end

    for k, v in ipairs(machines) do
        local position = v[1]
        local node = v[2]

        if minetest.get_meta(v[1]):get_int("force_off") ~= 1 then
            touched_nodes[hash(position)] = os.time()
            local action_result = node_defs[node].action(position, node, minetest.get_meta(position), supply, demand)
            assert(action_result, "You need to return something in the action function... fauly node: " .. node)
            demand = demand + action_result
        end
    end

    local t1 = minetest.get_us_time()
    local lag = t1 - t0
    network.lag = network.lag + lag

    network.supply = supply
    network.demand = demand
    network.battery_max = battery_max

    sbz_api.switching_station_networks[hash(start_pos)] = network

    return true
end

function sbz_api.switching_station_sub_tick(start_pos)
    local t0 = minetest.get_us_time()

    local network = sbz_api.switching_station_networks[hash(start_pos)]
    if network == nil then return end

    local machines = network.subticking_machines or {}
    local supply = network.supply
    local demand = network.demand

    for k, v in ipairs(machines) do
        local position = v[1]
        local node = v[2]

        touched_nodes[hash(position)] = os.time()
        demand = demand + node_defs[node].action_subtick(position, node, minetest.get_meta(position), supply, demand)
    end

    local t1 = minetest.get_us_time()
    network.lag = network.lag + (t1 - t0)

    network.demand = demand

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
    catch_up = false,
    action = function(pos)
        local poshash = hash(pos)
        if not all_switching_stations[poshash] then
            all_switching_stations[hash(pos)] = true
        end
    end
})

local timeout_limit = 3 -- seconds

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



local dtime_accum_subtick = 0
local dtime_accum_fulltick = 0

sbz_api.power_tick = 1
sbz_api.power_subtick = 0.25

local enable_globalstep = true

sbz_api.switching_station_globalstep = function(dtime)
    if not enable_globalstep then return end
    local getnode = minetest.get_node
    local getmeta = minetest.get_meta
    dtime_accum_subtick = dtime_accum_subtick + dtime

    -- subtick
    if dtime_accum_subtick >= sbz_api.power_subtick then
        dtime_accum_subtick = 0
        dtime_accum_fulltick = dtime_accum_fulltick + sbz_api.power_subtick
        for k, v in pairs(all_switching_stations) do
            local pos = unhash(k)
            if getnode(pos).name ~= "sbz_power:switching_station" then
                getmeta(pos):set_string("infotext", "Inactive")
                all_switching_stations[k] = nil
                sbz_api.switching_station_networks[k] = nil
            else
                sbz_api.switching_station_sub_tick(pos)
            end
        end
    end

    -- tick
    if dtime_accum_fulltick >= sbz_api.power_tick then
        dtime_accum_fulltick = 0
        for k, v in pairs(all_switching_stations) do
            local pos = unhash(k)
            if getnode(pos).name ~= "sbz_power:switching_station" then
                getmeta(pos):set_string("infotext", "Inactive")
                table.remove(all_switching_stations, k) -- some may call this InEfFiCeNt and they are right
                all_switching_stations[k] = nil
                sbz_api.switching_station_networks[v] = nil
            else
                sbz_api.switching_station_tick(pos)
            end
        end
    end
end

minetest.register_globalstep(sbz_api.switching_station_globalstep)

mesecon.register_on_mvps_move(function(moved_nodes)
    for i = 1, #moved_nodes do
        local moved_node = moved_nodes[i]
        local oldpos = moved_node.oldpos
        local pos = moved_node.pos
        local node = moved_node.node

        if node.name == "sbz_power:switching_station" then
            all_switching_stations[hash(oldpos)] = nil
            all_switching_stations[hash(pos)] = true
            sbz_api.switching_station_networks[hash(pos)] = sbz_api.switching_station_networks[hash(oldpos)]
            sbz_api.switching_station_networks[hash(pos)] = nil
        elseif touched_nodes[hash(oldpos)] then
            touched_nodes[hash(pos)] = touched_nodes[hash(oldpos)]
            touched_nodes[hash(oldpos)] = nil
        end
    end
end)
