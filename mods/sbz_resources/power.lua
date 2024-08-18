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

    local function internal(pos)
        if power_obtained < amount and not seen[hash(pos)] then
            seen[hash(pos)] = true
            iterate_around_pos(pos, function(ipos)
                local node = minetest.get_node(ipos).name
                local is_generator = minetest.get_item_group(node, "sbz_generator") == 1
                local is_wire = node == "sbz_resources:power_pipe"
                if is_wire then
                    internal(ipos)
                elseif is_generator and power_obtained < amount then
                    local meta = minetest.get_meta(ipos)
                    local power = meta:get_int("power")
                    if power >= amount then
                        power_obtained = amount -- stops iterating after
                        meta:set_int("power", power - amount)
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
                count = count + 1
                meta:set_int("count", count)
                if count == def.action_interval then
                    meta:set_string("infotext", "Running")
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