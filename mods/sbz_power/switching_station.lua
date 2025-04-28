local all_switching_stations = {} -- h(pos) = true|nil
local storage = core.get_mod_storage()

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

sbz_api.pos2network = {}
sbz_api.networks = {}

local pos2network = sbz_api.pos2network
local networks = sbz_api.networks

local max_net_id = 0
local function get_next_network_id()
    max_net_id = max_net_id + 1
    return max_net_id
end

local function get_network(pos)
    local hpos = h(pos)
    if hpos and pos2network[hpos] then
        local net = networks[pos2network[hpos]]
        if net then
            if net.dirty or os.difftime(net.lagstamp, os.time()) > 12 then
                networks[pos2network[hpos]] = nil
                net = nil
            end
            return net
        end
    end
end

---@param start_pos vector
---@param seen table|nil
function sbz_api.assemble_network(start_pos, seen, parent_net_id)
    local t0 = minetest.get_us_time()
    local by_connector = parent_net_id
    seen = seen or {}

    local net_id, network
    if not by_connector then
        net_id = get_next_network_id()

        networks[net_id] = {
            generators = {},
            machines = {},
            switching_stations = {},
            batteries = {},
            connectors = {},
            subticking_machines = {},
            --            dirty = false
        }
        network = networks[net_id]
    else
        net_id = parent_net_id
        network = {
            generators = {},
            machines = {},
            switching_stations = {},
            batteries = {},
            connectors = {},
            subticking_machines = {},
            dirty = false
        }
    end

    local generators = network.generators
    local machines = network.machines
    local switching_stations = network.switching_stations
    local batteries = network.batteries

    setmetatable(seen, {
        __index = function(t, k)
            return rawget(t, h(k))
        end,
        __newindex = function(t, k, v)
            rawset(t, h(k), v)
        end
    })

    local queue = Queue.new()
    queue:enqueue({ start_pos, vector.zero() })
    seen[start_pos] = true
    pos2network[h(start_pos)] = net_id

    sbz_api.vm_begin()

    -- inspired by https://github.com/minetest-mods/digilines/blob/7d4895d5d4a093041e3e6c8a8676f3b99bb477b7/internal.lua#L99

    while not queue:is_empty() do
        local current_pos, dir = unpack(queue:dequeue())
        local nn = (sbz_api.get_node_force(current_pos) or {}).name -- node name
        local is_conducting = IG(nn, "pipe_conducts") > 0

        local is_generator = IG(nn, "sbz_generator") > 0
        local is_machine = IG(nn, "sbz_machine") > 0
        local is_battery = IG(nn, "sbz_battery") > 0
        local is_connector = IG(nn, "sbz_connector") > 0
        local is_subticking = IG(nn, "sbz_machine_subticking") > 0

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
            pos2network[h(current_pos)] = net_id
            local def = core.registered_nodes[nn]
            local node = sbz_api.get_or_load_node(current_pos)
            if def.can_assemble(current_pos, node, dir, network, seen, parent_net_id) then
                minetest.registered_nodes[nn].assemble(current_pos, node, dir, network, seen,
                    net_id)
            end
        end

        if is_subticking then
            network.subticking_machines[#network.subticking_machines + 1] = { current_pos, nn }
        end


        if is_conducting then
            if net_id then
                pos2network[h(current_pos)] = net_id
            end
            iterate_around_pos(current_pos, function(pos, dir)
                if not seen[pos] then
                    seen[pos] = true
                    queue:enqueue({ pos, dir })
                end
            end)
        end
    end

    network.lag = minetest.get_us_time() - t0
    network.lagstamp = os.time()
    if not by_connector then
        return net_id
    else
        return network
    end
end

function sbz_api.switching_station_tick(start_pos)
    if touched_nodes[hash(start_pos)] and os.time() - touched_nodes[hash(start_pos)] < 1 then
        minetest.get_meta(start_pos):set_string("infotext", "Inactive (connected to another network)")
        return
    end
    sbz_api.vm_begin()

    local meta = minetest.get_meta(start_pos)
    local network_before = get_network(start_pos)

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
            local meta = minetest.get_meta(position)
            local def = node_defs[node]
            local current = 0
            if def.get_power then
                current = def.get_power(position, node, meta, supply, demand, v[3])
            else
                current = meta:get_int("power")
            end

            if max then -- if not max then battery has not been ran
                local set_power = def.set_power or
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
                math.floor(network_before.lag / 1000), network_size
            )
        )
    end

    local net_id = pos2network[h(start_pos)]
    local network = networks[net_id]

    if network and network.dirty then
        networks[net_id] = nil
        network = nil
    end
    if network == nil then
        net_id = sbz_api.assemble_network(start_pos)
        network = networks[net_id]
    end

    local t0 = minetest.get_us_time()

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
        --        networks[net_id] = nil
        minetest.remove_node(start_pos)
        return false
    end

    local ids = {}
    for k, v in ipairs(batteries) do
        local position = v[1]
        local node = v[2]
        local meta = minetest.get_meta(position)
        local d = node_defs[node]
        local id_good = true
        if d.get_battery_id then
            local id = d.get_battery_id(position, meta)
            if ids[id] then
                touched_nodes[hash(position)] = os.time()
                id_good = false
            end
            ids[id] = true
        end
        if meta:get_int("force_off") ~= 1 and id_good then
            touched_nodes[hash(position)] = os.time()

            v[4] = d.battery_max
            if d.get_battery_max then
                v[4] = d.get_battery_max(position, meta)
            end
            local battery_power = 0
            if d.get_power then
                battery_power = d.get_power(position, node, meta, supply, demand, v[3])
            else
                battery_power = meta:get_int("power")
            end

            battery_max = battery_max + v[4]
            supply = supply + battery_power
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
            if action_result >= 0 then
                demand = demand + action_result
            else
                supply = supply - action_result
            end
        end
    end

    local t1 = minetest.get_us_time()
    local lag = t1 - t0
    if network.lagstamp == os.time() then
        network.lag = network.lag + lag
    else
        network.lag = lag
    end
    network.lagstamp = os.time()
    network.supply = supply
    network.demand = demand
    network.battery_max = battery_max
    return true
end

function sbz_api.switching_station_sub_tick(start_pos)
    local t0 = minetest.get_us_time()

    local network = get_network(start_pos)
    if network == nil then return end
    if network.dirty then
        networks[pos2network[h(start_pos)]] = nil
    end

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
        if not touched_nodes[hash(pos)] or (os.time() - touched_nodes[hash(pos)] >= timeout_limit) and core.get_item_group(node.name, "network_always_found") ~= 1 then
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


local has_monitoring = core.get_modpath("monitoring")
local switching_station_count
if has_monitoring then
    switching_station_count = monitoring.gauge("sbz_switching_station_count", "Number of active switching stations",
        { autoflush = true })
end

sbz_api.switching_station_globalstep = function(dtime)
    if not sbz_api.enable_switching_station_globalstep then return end
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
            else
                sbz_api.switching_station_sub_tick(pos)
            end
        end
    end

    -- tick
    if dtime_accum_fulltick >= sbz_api.power_tick then
        dtime_accum_fulltick = 0

        local count = 0
        for k, v in pairs(all_switching_stations) do
            count = count + 1
            local pos = unhash(k)
            if getnode(pos).name ~= "sbz_power:switching_station" then
                getmeta(pos):set_string("infotext", "Inactive")
                all_switching_stations[k] = nil
            else
                sbz_api.switching_station_tick(pos)
            end
        end

        if switching_station_count then
            switching_station_count.set(count)
        end
    end
end

minetest.register_globalstep(sbz_api.switching_station_globalstep)

if has_monitoring then
    local switching_station_lag = monitoring.counter("sbz_switching_station_lag", "Switching station lag")
    sbz_api.switching_station_globalstep = switching_station_lag.wraptime(sbz_api.switching_station_globalstep)
end

mesecon.register_on_mvps_move(function(moved_nodes)
    for i = 1, #moved_nodes do
        local moved_node = moved_nodes[i]
        local oldpos = moved_node.oldpos
        local pos = moved_node.pos
        local node = moved_node.node

        if node.name == "sbz_power:switching_station" then
            all_switching_stations[hash(oldpos)] = nil
            all_switching_stations[hash(pos)] = true
        elseif touched_nodes[hash(oldpos)] then
            touched_nodes[hash(pos)] = touched_nodes[hash(oldpos)]
            touched_nodes[hash(oldpos)] = nil
        end
    end
end)


minetest.register_chatcommand("toggle_power", {
    description = "Toggles if switching stations are enabled or not",
    params = '<yes/no>',

    privs = { ["server"] = true },
    func = function(name, param)
        if core.is_yes(param) then
            sbz_api.enable_switching_station_globalstep = true
            core.chat_send_player(name, "Enabled switching stations")
        else
            sbz_api.enable_switching_station_globalstep = false
            core.chat_send_player(name, "Temporarily disabled switching stations.")
        end
    end
})

-- MISC api related to sbz_api.assemble_network
---@param radius number|nil
function sbz_api.get_power_from_batteries(start_pos, radius)
    radius = radius or math.huge
    local radius_vect = vector.new(radius, radius, radius)
    local bat_power = 0
    local network = get_network(start_pos)
    if network and not network.dirty then
        for k, v in pairs(network.batteries) do
            local pos = v[1]
            if vector.in_area(pos, -radius_vect, radius_vect) then
                local meta = core.get_meta(pos)
                local name = v[2]
                local def = node_defs[name]
                local battery_power = 0
                if core.get_item_group(name, "limited_battery") == 0 then
                    if def.get_power then
                        battery_power = def.get_power(pos, name, meta, 0, 0, v[3])
                    else
                        battery_power = meta:get_int("power")
                    end
                    bat_power = bat_power + battery_power
                end
            end
        end
    end
    return bat_power
end

---@param radius number|nil
function sbz_api.drain_power_from_batteries(start_pos, power, radius)
    local network = get_network(start_pos)
    radius = radius or math.huge
    local radius_vect = vector.new(radius, radius, radius)
    if network and not network.dirty then
        for k, v in pairs(network.batteries) do
            local pos = v[1]
            local meta = core.get_meta(pos)
            local name = v[2]
            local def = node_defs[name]
            if vector.in_area(pos, -radius_vect, radius_vect) then
                if core.get_item_group(name, "limited_battery") == 0 then
                    local set_power = def.set_power or
                        function(pos, node, meta, current_power, supplied_power, dir)
                            meta:set_int("power", supplied_power)
                        end

                    local battery_power = 0
                    if def.get_power then
                        battery_power = def.get_power(pos, name, meta, 0, 0, v[3])
                    else
                        battery_power = meta:get_int("power")
                    end
                    local taken_away = math.min(power, battery_power)
                    set_power(pos, name, meta, battery_power, battery_power - taken_away, v[3])
                    power = power - taken_away
                    if power <= 0 then
                        break
                    end
                end
            end
        end
    end
end

core.register_on_mods_loaded(function()
    for name, def in pairs(core.registered_nodes) do
        if IG(name, "pipe_conducts") > 0 then
            local og_construct = def.on_construct
            local og_destruct = def.on_destruct
            local og_on_rotate = def.on_rotate
            core.override_item(name, {
                on_construct = function(pos)
                    iterate_around_pos(pos, function(ipos, dir)
                        if get_network(ipos) then
                            get_network(ipos).dirty = true
                        end
                    end)

                    if og_construct then return og_construct(pos) end
                end,
                on_destruct = function(pos)
                    iterate_around_pos(pos, function(ipos, dir)
                        if get_network(ipos) then
                            get_network(ipos).dirty = true
                        end
                    end)

                    if og_destruct then return og_destruct(pos) end
                end,
                on_rotate = function(pos, ...)
                    iterate_around_pos(pos, function(ipos, dir)
                        if get_network(ipos) then
                            get_network(ipos).dirty = true
                        end
                    end)
                    if og_on_rotate then return og_on_rotate(pos, ...) end
                end,
            })
        end
    end
end)

sbz_api.get_switching_station_network = get_network

-- debug

sbz_api.make_network_visible = function(p1, p2, net)
    p1, p2 = vector.sort(p1, p2)
    local va = VoxelArea(p1, p2)
    local network = networks[net]
    for i in va:iterp(p1, p2) do
        local p = va:position(i)
        if pos2network[core.hash_node_position(p)] == net then
            core.add_entity(p, "sbz_base:debug_entity")
        end
    end
end
