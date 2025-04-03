-- instatube!!
local network_refresh_time = 2              -- higher reduces lag, but makes tube less responsive to changes in network... leading to strange "glitches", setting to zero is finee

sbz_api.instatube_networks = {}             -- table<poshash, network>
sbz_api.instatube_special_insert_logic = {} -- table<nodename, function>

local special_insert_logic = sbz_api.instatube_special_insert_logic
local regnodes = core.registered_nodes
local hash = core.hash_node_position

sbz_api.create_instatube_network = function(start_pos)
    local queue = Queue.new()
    local seen = {}
    local network = { --[[time = os.time(),]] machines = {} } -- something else may be added in the future
    local machines = network.machines                         -- not just machines, tubes and the like too

    queue:enqueue(start_pos)
    sbz_api.vm_begin()
    while true do
        local pos = queue:dequeue()
        if not pos then break end
        if not seen[hash(pos)] then
            seen[hash(pos)] = true
            iterate_around_pos(pos, function(ipos, dir)
                local node = sbz_api.get_node_force(ipos)
                if not node then return end
                local is_wire = core.get_item_group(node.name, "instatube") == 1
                local is_receiver = core.get_item_group(node.name, "tubedevice") == 1
                if is_wire then
                    queue:enqueue(ipos)
                elseif is_receiver then
                    local def = regnodes[node.name]
                    if not def.tube then error(node.name) end
                    machines[#machines + 1] = {
                        pos = ipos,
                        priority = (def.tube or {}).priority or 100,
                        tube = def.tube,
                        is_tube = def.tubelike == 1,
                        node = node,
                        dir = dir,
                    }
                end
            end)
        end
    end
    sbz_api.vm_commit()
    table.sort(machines, function(a, b)
        return a.priority < b.priority
    end)
    -- beautiful!
    return network
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

local wire_size = 1 / 4

--[[
Do you dislike pipeworks? Have you ever wanted to burn pipeworks with fire? Here is the tube for you!
You will still interact with pipeworks just much less...
]]

local instatube_insert_object = function(pos, _, stack, _, owner)
    local network = sbz_api.instatube_networks[core.hash_node_position(pos)]
    if not network then
        sbz_api.instatube_networks[core.hash_node_position(pos)] = sbz_api.create_instatube_network(pos)
        network = sbz_api.instatube_networks[core.hash_node_position(pos)]
    end
    -- next up... machines!
    for index, machine in ipairs(network.machines) do
        local mnode = machine.node
        local can_insert = true
        local mpos = table.copy(machine.pos)
        if machine.tube.can_insert then
            can_insert = can_insert and
                machine.tube.can_insert(mpos, mnode, stack, { x = 0, y = 0, z = 0, speed = 1 }, owner)
        end
        if can_insert then
            if not machine.is_tube then
                if machine.tube.insert_object then
                    stack = machine.tube.insert_object(mpos, mnode, stack,
                        { x = 0, y = 0, z = 0, speed = 1 },
                        owner)
                end
            else
                local entity = pipeworks.tube_inject_item(mpos, vector.subtract(mpos, machine.dir),
                    { x = machine.dir.x, y = machine.dir.y, z = machine.dir.z, speed = 4 }, stack, owner, {})
                if machine.tube.can_go then
                    can_insert = can_insert and
                        machine.tube.can_go(mpos, mnode, { x = 0, y = 0, z = 0, speed = 1 }, stack, {})
                end
                if can_insert then
                    if machine.tube.insert_object then
                        machine.tube.insert_object(mpos, mnode, stack, { x = 0, y = 0, z = 0, speed = 1 },
                            owner)
                    end
                    stack:clear() -- the function above copies the stack so dont worry ^w^
                elseif entity then
                    entity:remove()
                end
            end
        end
    end
    return stack
end

core.register_node("sbz_instatube:instant_tube", {
    description = "Instant Tube",
    connects_to = { "sbz_instatube:instant_tube", "group:tubedevice", "pipeworks:automatic_filter_injector" },
    info_extra = { "Deliver items in record time! (Also less lag and less weird behavior!)", "Shortened name: \"instatube\"." },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },

    tiles = { "instatube.png" },
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
    drawtype = "nodebox",
    paramtype = "light",
    sunlight_propagates = true,

    groups = {
        matter = 1,
        instatube = 1,
        cracky = 3,
        habitat_conducts = 1,
        explody = 100,
        tubedevice_receiver = 1,
        tubedevice = 1,
    },

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
    use_texture_alpha = "clip",
    tube = {
        connect_sides = { front = 1, back = 1, left = 1, right = 1, top = 1, bottom = 1 },
        insert_object = instatube_insert_object,
        priority = 75,
    },
})

core.register_node("sbz_instatube:one_way_instatube", {
    description = "One Way Instatube",
    tiles = { "one_way_instatube.png" },
    drawtype = "nodebox",
    paramtype = "light",
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
    groups = {
        matter = 1,
        instatube = 1,
        cracky = 3,
        habitat_conducts = 1,
        explody = 80,
        tubedevice_receiver = 1,
        tubedevice = 1,
    },
    node_box = {
        type = "fixed",
        fixed = pipeworks.tube_long
    },
    use_texture_alpha = "clip",
    tube = {
        connect_sides = { front = 1, back = 1, left = 1, right = 1, top = 1, bottom = 1 },
        can_go = function(pos, node, stack, velocity, owner)
            return { velocity }
        end,
        can_insert = function(pos, node, stack, direction)
            return vector.equals(core.facedir_to_dir(node.param2), direction)
        end,
        insert_object = function(pos, _, stack, vel, owner)
            return instatube_insert_object(pos, _, stack, vel, owner)
        end,
        priority = 80,
    },
})
special_insert_logic["sbz_instatube:one_way_instatube"] = function(pos, node, dir)
    return vector.equals(core.facedir_to_dir(node.param2), dir)
end


local timer = 0
core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer > network_refresh_time then
        sbz_api.instatube_networks = {}
        timer = 0
    end
end)
