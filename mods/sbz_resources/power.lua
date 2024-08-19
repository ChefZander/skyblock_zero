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

local function iterate_around_pos(pos, func)
    func({ x = pos.x - 1, y = pos.y, z = pos.z })
    func({ x = pos.x + 1, y = pos.y, z = pos.z })

    func({ x = pos.x, y = pos.y - 1, z = pos.z })
    func({ x = pos.x, y = pos.y + 1, z = pos.z })

    func({ x = pos.x, y = pos.y, z = pos.z - 1 })
    func({ x = pos.x, y = pos.y, z = pos.z + 1 })
end

local hash = minetest.hash_node_position

function sbz_api.require_power(start_pos, amount)
    local seen = {}
    local power_obtained = 0
    local delayed_functions = {}

    sbz_api.vm_begin()

    local function internal(pos)
        if power_obtained < amount and not seen[hash(pos)] then
            seen[hash(pos)] = true
            iterate_around_pos(pos, function(ipos)
                local node = sbz_api.vm_get_node(ipos).name
                local is_generator = minetest.get_item_group(node, "sbz_generator") == 1
                local is_wire = node == "sbz_resources:power_pipe"
                if is_wire then
                    internal(ipos)
                elseif is_generator and power_obtained < amount and hash(ipos) ~= hash(start_pos) then
                    local meta = minetest.get_meta(ipos)
                    local power = meta:get_int("power")
                    if power >= amount then
                        power_obtained = amount -- stops iterating after
                        meta:set_int("power", (power - amount))
                    elseif power ~= 0 then      -- not quite fills it up
                        power_obtained = power_obtained + power
                        local overcharge = 0
                        if power_obtained > amount then
                            overcharge = power_obtained - amount
                            power_obtained = amount
                        end
                        delayed_functions[#delayed_functions + 1] = function()
                            meta:set_int("power", overcharge)
                        end
                    end
                end
            end)
        end
    end
    internal(table.copy(start_pos))

    sbz_api.vm_abort()
    if power_obtained == amount then
        for i = 1, #delayed_functions do
            delayed_functions[i]()
        end
        return true
    else
        return false
    end
end

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

local wire_size = 1 / 5

minetest.register_node("sbz_resources:power_pipe", {
    description = "Emittrium power pipe",
    connects_to = { "sbz_resources:power_pipe", "group:sbz_machine" },
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

-- an api to register very simple machines, if you are reading this, don't restrict yourself to what this api can do

function sbz_api.register_machine(name, def)
    def.groups.sbz_machine = 1
    def.power_needed = def.power_needed
    minetest.register_node(name, def)
    minetest.register_abm({
        nodenames = { name },
        interval = 1,
        chance = def.action_chance or 1,
        action = function(pos, node, active_object_count, active_object_count_wider)
            local meta = minetest.get_meta(pos)
            local count = meta:get_int("count")
            if sbz_api.require_power(pos, def.power_needed) then
                meta:set_string("infotext", "Running")
                count = count + 1
                meta:set_int("count", count)
                if count >= def.action_interval then
                    def.action(pos, node, meta)
                    meta:set_int("count", 0)
                end
            else
                meta:set_int("count", 0)
                meta:set_string("infotext", "Not enough power, needs: " .. def.power_needed)
                minetest.add_particlespawner({
                    amount = 10,
                    time = 1,
                    minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                    maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                    minvel = { x = -0.5, y = -0.5, z = -0.5 },
                    maxvel = { x = 0.5, y = 0.5, z = 0.5 },
                    minacc = { x = 0, y = 0, z = 0 },
                    maxacc = { x = 0, y = 0, z = 0 },
                    minexptime = 5,
                    maxexptime = 10,
                    minsize = 0.5,
                    maxsize = 1.0,
                    collisiondetection = false,
                    vertical = false,
                    texture = "error_particle.png",
                    glow = 10
                })
            end
        end
    })
end

function sbz_api.register_generator(name, def)
    def.groups.sbz_generator = 1
    def.groups.sbz_machine = 1
    if def.generation_condition == nil then
        def.generation_condition = function(...) return true end
    end
    minetest.register_node(name, def)
    minetest.register_abm({
        nodenames = { name },
        interval = def.generation_interval or 1,
        chance = def.generation_chance or 1,
        action = function(pos, node, active_object_count, active_object_count_wider)
            local meta = minetest.get_meta(pos)
            if def.generation_condition(pos, node, meta) then
                meta:set_int("power", def.power_generated)
                meta:set_string("infotext", "Generating power: " .. def.power_generated)
            else
                meta:set_string("infotext", "Off")
            end
        end
    })
end

local BATTERY_MAX_POWER = 300
local BATTERY_DRAW_PER_TICK = 10

minetest.register_node("sbz_resources:battery", {
    description = "battery",
    tiles = {"battery.png"},
    groups = { sbz_generator = 1, sbz_machine = 1, matter = 1 },
})

minetest.register_craft({
    output = "sbz_resources:battery",
    recipe = {
        {"sbz_resources:matter_blob", "sbz_resources:matter_blob", "sbz_resources:matter_blob"},
        {"sbz_resources:matter_blob", "sbz_resources:emittrium_circuit", "sbz_resources:matter_blob"},
        {"sbz_resources:matter_blob", "sbz_resources:matter_blob", "sbz_resources:matter_blob"}
    }
})

minetest.register_abm({
    nodenames = { "sbz_resources:battery" },
    interval = 1,
    chance = 1,
    action = function(pos, node)
        local meta = minetest.get_meta(pos)
        local power = meta:get_int("power")
        if power < BATTERY_MAX_POWER then
            if sbz_api.require_power(pos, BATTERY_DRAW_PER_TICK) then
                local new_power = power + BATTERY_DRAW_PER_TICK
                if new_power > BATTERY_MAX_POWER then new_power = BATTERY_MAX_POWER end
                meta:set_int("power", new_power)
            end
        end
        meta:set_string("infotext",
            string.format("Battery: %s/%s\nDraws %s power per second", meta:get_int("power"), BATTERY_MAX_POWER,
                BATTERY_DRAW_PER_TICK))
    end
})

minetest.register_node("sbz_resources:switch_off", {
    description = "Switch",
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    light_source = 3,
    groups = {sbz_machine=1, matter=1, cracky=3},
    node_box = {
        type = "fixed",
        fixed = {
            {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}
        }
    },
    tiles = {
        "switch_end.png",
        "switch_end.png",
        "switch_off.png",
        "switch_off.png",
        "switch_off.png",
        "switch_off.png"
    },
    connects_to = {"sbz_resources:power_pipe", "group:sbz_machine"},
    on_rightclick = function (pos, node)
        node.name = "sbz_resources:switch_on"
        minetest.swap_node(pos, node)
    end
})

minetest.register_node("sbz_resources:switch_on", {
    description = "Switch",
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    light_source = 5,
    groups = {sbz_machine=1, matter=1, cracky=3, not_in_creative_inventory=1},
    node_box = {
        type = "fixed",
        fixed = {
            {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}
        }
    },
    tiles = {
        "switch_end.png",
        "switch_end.png",
        "switch_on.png",
        "switch_on.png",
        "switch_on.png",
        "switch_on.png"
    },
    connects_to = {"sbz_resources:power_pipe", "group:sbz_machine"},
    on_rightclick = function (pos, node)
        node.name = "sbz_resources:switch_off"
        minetest.swap_node(pos, node)
    end
})