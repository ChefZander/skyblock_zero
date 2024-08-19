--[[
    The section below is licensed under the lgplv3 license, it was taken from mesecons
    This license text only applies to the section below, a comment will be placed indicating when that section ends


This program is free software; you can redistribute the Mesecons Mod and/or
modify it under the terms of the GNU Lesser General Public License version 3
published by the Free Software Foundation.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the
Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
Boston, MA  02110-1301, USA.

]]


-- Block position "hashing" (convert to integer) functions for voxelmanip cache
local BLOCKSIZE = 16

-- convert node position --> block hash
local function hash_blockpos(pos)
    return minetest.hash_node_position({
        x = math.floor(pos.x / BLOCKSIZE),
        y = math.floor(pos.y / BLOCKSIZE),
        z = math.floor(pos.z / BLOCKSIZE)
    })
end

local vm_cache = nil
local vm_node_cache = nil


function sbz_api.vm_begin()
    vm_cache = {}
    vm_node_cache = {}
end

function sbz_api.vm_abort()
    vm_cache = nil
    vm_node_cache = nil
end

local function vm_get_or_create_entry(pos)
    local hash = hash_blockpos(pos)
    local tbl = vm_cache[hash]
    if not tbl then
        tbl = minetest.get_voxel_manip(pos, pos)
        vm_cache[hash] = tbl
    end
    return tbl
end

function sbz_api.vm_get_node(pos)
    local hash = minetest.hash_node_position(pos)
    local node = vm_node_cache[hash]
    if not node then
        node = vm_get_or_create_entry(pos):get_node_at(pos)
        vm_node_cache[hash] = node
    end
    return node.name ~= "ignore" and { name = node.name, param1 = node.param1, param2 = node.param2 } or nil
end

--[[
    Now the code below is licensed normally
]]

local timeout_limit = 3 -- seconds
local touched_nodes = {}


local function iterate_around_pos(pos, func)
    func({ x = pos.x - 1, y = pos.y, z = pos.z })
    func({ x = pos.x + 1, y = pos.y, z = pos.z })

    func({ x = pos.x, y = pos.y - 1, z = pos.z })
    func({ x = pos.x, y = pos.y + 1, z = pos.z })

    func({ x = pos.x, y = pos.y, z = pos.z - 1 })
    func({ x = pos.x, y = pos.y, z = pos.z + 1 })
end

local hash = minetest.hash_node_position

function sbz_api.switching_station_tick(start_pos)
    local t0 = minetest.get_us_time()
    local seen, network = {}, {
        generators = {},
        machines = {},
        switching_stations = {},
        batteries = {}
    }

    local generators = network.generators
    local machines = network.machines
    local switching_stations = network.switching_stations
    local batteries = network.batteries

    local pipes_counter = 0

    sbz_api.vm_begin()

    local function internal(pos)
        if not seen[hash(pos)] then
            seen[hash(pos)] = true
            iterate_around_pos(pos, function(ipos)
                if not seen[hash(ipos)] then
                    local node = sbz_api.vm_get_node(ipos).name
                    local is_generator = minetest.get_item_group(node, "sbz_generator") == 1
                    local is_machine = minetest.get_item_group(node, "sbz_machine") == 1
                    local is_battery = minetest.get_item_group(node, "sbz_battery") == 1

                    if node == "sbz_resources:switching_station" then
                        switching_stations[#switching_stations + 1] = ipos
                    elseif node == "sbz_resources:power_pipe" then
                        pipes_counter = pipes_counter + 1
                        internal(ipos)
                    elseif is_battery then
                        batteries[#batteries + 1] = { ipos, node }
                    elseif is_generator then
                        generators[#generators + 1] = { ipos, node }
                    elseif is_machine then
                        machines[#machines + 1] = { ipos, node }
                    end
                    seen[hash(ipos)] = true
                end
            end)
        end
    end
    internal(table.copy(start_pos))
    sbz_api.vm_abort()

    local supply = 0
    local demand = 0
    local battery_max = 0

    local node_defs = minetest.registered_nodes


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
        string.format("Supply: %s\nDemand: %s\nBattery supply: %s/%s\nLag: %sus\nNetwork Size: %s", supply - battery_supply_only,
            demand, battery_supply_only, battery_max, t1 - t0, network_size))
    return true
end

minetest.register_node("sbz_resources:switching_station", {
    description = "Switching Station",
    tiles = {"switching_station.png"},
    groups = { matter = 1, cracky = 1 },
    light_source = 3,

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Loading....")
    end,
})

minetest.register_craft({
    output = "sbz_resources:switching_station",
    recipe = {
        {"", "", ""},
        {"sbz_resources:power_pipe", "sbz_resources:matter_blob", "sbz_resources:power_pipe"},
        {"", "", ""}
    }
})

local function wire(len, stretch_to)
    local full = 0.5
    local base_box = { -len, -len, -len, len, len, len }
    if stretch_to == "top" then
        base_box[5] = full
    elseif stretch_to == "bottom" then
        base_box[2] = -full
    elseif stretch_to == "front" then
        base_box[3] = -full
    elseif stretch_to == "back" then
        base_box[6] = full
    elseif stretch_to == "right" then
        base_box[4] = full
    elseif stretch_to == "left" then
        base_box[1] = -full
    end
    return base_box
end

local wire_size = 1 / 8

minetest.register_node("sbz_resources:power_pipe", {
    description = "Emittrium power pipe",
    connects_to = { "sbz_resources:power_pipe", "group:sbz_machine", "sbz_resources:switching_station" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },

    tiles = { "emitter.png" },

    drawtype = "nodebox",
    light_source = 3,

    groups = { matter = 1, cracky = 3 },

    node_box = {
        type = "connected",
        disconnected = wire(wire_size),
        connect_top = wire(wire_size, "top"),
        connect_bottom = wire(wire_size, "bottom"),
        connect_front = wire(wire_size, "front"),
        connect_back = wire(wire_size, "back"),
        connect_left = wire(wire_size, "left"),
        connect_right = wire(wire_size, "right"),
    },
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:power_pipe",
    recipe = { "sbz_resources:raw_emittrium", "sbz_resources:matter_plate" }
})

function sbz_api.register_machine(name, def)
    def.groups.sbz_machine = 1
    if not def.control_action_raw then
        local old_action = def.action

        function def.action(pos, node, meta, supply, demand)
            if (demand + def.power_needed) > supply then
                meta:set_string("infotext", "Not enough power, needs: " .. def.power_needed)
                return def.power_needed
            else
                meta:set_string("infotext", "Running")
                local count = meta:get_int("count")
                if count >= def.action_interval then
                    old_action(pos, node, meta, supply, demand)
                    meta:set_int("count", 0)
                else
                    meta:set_int("count", count + 1)
                end
                return def.power_needed
            end
        end
    end
    minetest.register_node(name, def)
end

function sbz_api.register_generator(name, def)
    def.groups.sbz_machine = 1
    def.groups.sbz_generator = 1
    if def.power_generated then
        def.action = function(pos, node, meta, ...)
            meta:set_string("infotext", "Running")
            return def.power_generated
        end
    end
    minetest.register_node(name, def)
end

local BATTERY_MAX_POWER = 300

minetest.register_node("sbz_resources:battery", {
    description = "battery",
    tiles = { "battery.png" },
    groups = { sbz_battery = 1, sbz_machine = 1, matter = 1 },
    battery_max = BATTERY_MAX_POWER,
    action = function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_string("infotext", string.format("Battery: %s/%s power", current_power, BATTERY_MAX_POWER))
    end
})


minetest.register_abm({
    label = "Machine timeout check",
    nodenames = { "group:sbz_machine" },
    interval = timeout_limit,
    chance = 1,
    action = function(pos, node)
        if not touched_nodes[hash(pos)] or (os.time() - touched_nodes[hash(pos)] >= timeout_limit) then
            minetest.get_meta(pos):set_string("infotext", "No network found")
        end
    end
})

minetest.register_abm({
    label = "Machine activation - switching stations",
    nodenames = { "sbz_resources:switching_station" },
    interval = 1,
    chance = 1,
    action = sbz_api.switching_station_tick

})
