-- instatube!!
sbz_api.instatube = {}
local instatube = sbz_api.instatube
instatube.networks = {}    -- table<id, network>
instatube.pos2network = {} -- table<hpos, ids>
local pos2network = instatube.pos2network

local max_net_id = 0
local function get_next_network_id()
    max_net_id = max_net_id + 1
    return max_net_id
end

local function add_to_pos2network(pos, net)
    local p2n = pos2network[core.hash_node_position(pos)]
    if p2n then
        p2n[#p2n + 1] = net
    else
        pos2network[core.hash_node_position(pos)] = { net }
    end
end

instatube.special_insert_logic = {} -- table<nodename, function>, changes if network takes a path
instatube.special_filter_logic = {} -- table<nodename, function>, different in that it accepts the stack as an argument
instatube.special_priority = {}
local special_insert_logic = instatube.special_insert_logic
local regnodes = core.registered_nodes
local hash = core.hash_node_position

sbz_api.instatube.create_instatube_network = function(start_pos, ordering)
    local net_id = get_next_network_id()
    local queue = Queue.new()
    local seen = {}
    instatube.networks[net_id] = { machines = {} }
    local network = instatube.networks[net_id]
    -- something else may be added in the future, so thats why there is the machines = {} table instead of just machines being in the root
    -- btw its not just machines, tubes and the like too
    local machines = network.machines
    local include_start_pos = true
    queue:enqueue({ start_pos, {}, 0 })
    sbz_api.vm_begin()

    while true do
        local pos, filter_logic, added_priority = unpack(queue:dequeue() or {})
        if not pos then break end
        if not seen[hash(pos)] then
            seen[hash(pos)] = true
            iterate_around_pos(pos, function(ipos, dir)
                local node = sbz_api.get_node_force(ipos)
                if not node then return end
                local is_wire = core.get_item_group(node.name, "instatube") == 1
                local is_receiver = core.get_item_group(node.name, "tubedevice") == 1
                if is_wire then
                    local should_enqueue = true
                    if special_insert_logic[node.name] then
                        local val = special_insert_logic[node.name](ipos, node, dir)
                        if type(val) == "table" then -- means its a teleport tube of some kind
                            if val.x then            -- vector
                                queue:enqueue({ val, filter_logic, added_priority })
                            else                     -- vector array
                                for _, vec in ipairs(val) do
                                    queue:enqueue({ vec, filter_logic, added_priority })
                                end
                            end
                        else
                            should_enqueue = should_enqueue and val
                        end
                    end
                    local supplied_filter_logic = filter_logic
                    if instatube.special_filter_logic[node.name] then
                        supplied_filter_logic = table.copy(filter_logic) -- avoid wasting memory and time
                        supplied_filter_logic[#supplied_filter_logic + 1] = {
                            pos = ipos,
                            dir = dir,
                            node = node,
                        }
                    end
                    local supplied_added_priority = added_priority
                    if instatube.special_priority[node.name] then
                        supplied_added_priority = added_priority + instatube.special_priority[node.name]
                    end
                    if should_enqueue then
                        add_to_pos2network(pos, net_id)
                        queue:enqueue({ ipos, supplied_filter_logic, supplied_added_priority })
                    end
                elseif is_receiver then
                    local def = regnodes[node.name]
                    if not def.tube then
                        core.log("error",

                            "This node: " ..
                            node.name ..
                            " does have the tubedevice group but doesn't have a tube={} table, REPORT THIS AS A BUG IF YOU SEE THIS! (no need for extra steps, just send need the name of the node, and that it came from here)")
                    else
                        machines[#machines + 1] = {
                            pos = ipos,
                            priority = added_priority + ((def.tube or {}).priority or 100),
                            tube = def.tube,
                            is_tube = def.tubelike == 1,
                            node = node,
                            dir = dir,
                            filter_logic = filter_logic,
                        }
                    end
                end
            end, include_start_pos)
            include_start_pos = false
        end
    end
    sbz_api.vm_commit()

    if ordering == nil then -- by priority
        table.sort(machines, function(a, b)
            return a.priority > b.priority
            -- wrongsort xD, sort that is maximally incorrect, but for my purpourses, maximally correct...?
        end)
    end
    -- else, the other sorts change with every item being inserted to instatube
    return net_id
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
    elseif stretch_to == "left+right" then -- special :D
        base_box[4] = full
        base_box[1] = -full
    end
    return base_box
end

local wire_size = 3 / 16

--[[
Do you dislike pipeworks? Have you ever wanted to burn pipeworks with fire? Here is the tube for you!
You will still interact with pipeworks just much less...
]]
local instatubes_net_id = {}

local instatube_insert_object = function(pos, _, stack, _, owner, ordering)
    local net_id = instatubes_net_id[hash(pos)] or -1
    local network = instatube.networks[net_id]
    if not network then
        net_id = sbz_api.instatube.create_instatube_network(pos, ordering)
        instatubes_net_id[hash(pos)] = net_id
        network = instatube.networks[net_id]
    end

    local machines = network.machines
    if ordering == "randomized" then
        table.shuffle(machines)
    elseif ordering == "cycle" then
        local meta = core.get_meta(pos)
        local shift_table_by = meta:get_int("cycle") % #machines
        local shifted_table = {}
        for i = 1, #machines do -- this for loop (literally, these 3 lines of code) were designed by AI, specifically microsoft copilot (not github copilot if that matters)
            shifted_table[i] = machines[((i - shift_table_by - 1) % #machines) + 1]
        end
        network.machines = shifted_table
        machines = shifted_table
        meta:set_string("infotext", "Cycle #" .. shift_table_by)
        meta:set_int("cycle", (shift_table_by + 1) % #machines)
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
            local filter_logic = machine.filter_logic
            for _, filter in ipairs(filter_logic) do
                local filter_f = instatube.special_filter_logic[filter.node.name]
                can_insert = can_insert and filter_f(filter.pos, filter.node, filter.dir, stack)
            end
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
                    stack:clear()  -- the function above (tube_inject_item) copies the stack so dont worry
                elseif entity then -- remove entity if there is entity and cant insert to tube
                    entity:remove()
                end
            end
        end
    end
    return stack
end

local function instatube_can_insert(pos, node, stack, vel, owner)
    local net_id = instatubes_net_id[hash(pos)] or -1
    local network = instatube.networks[net_id]
    if not network then
        return true -- create the network
    end
    for _, machine in ipairs(network.machines) do
        local mnode = machine.node
        local can_insert = true
        local mpos = table.copy(machine.pos)
        if machine.tube.can_insert then
            can_insert = can_insert and
                machine.tube.can_insert(mpos, mnode, stack, { x = 0, y = 0, z = 0, speed = 1 }, owner)
        end
        if can_insert then
            local filter_logic = machine.filter_logic
            for _, filter in ipairs(filter_logic) do
                local filter_f = instatube.special_filter_logic[filter.node.name]
                can_insert = can_insert and filter_f(filter.pos, filter.node, filter.dir, stack)
            end
        end
        if can_insert then
            return true
        end
    end
    return false
end

local wrap_instatube_insert_object = function(ordering)
    return function(pos, _, stack, _, owner)
        return instatube_insert_object(pos, _, stack, _, owner, ordering)
    end
end

core.register_node("sbz_instatube:instant_tube", unifieddyes.def {
    description = "Instatube",
    connects_to = { "sbz_instatube:instant_tube", "group:tubedevice", "pipeworks:automatic_filter_injector" },
    info_extra = { "Deliver items in record time! (Also less lag and less weird behavior!)" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },
    paramtype2 = "color",
    light_source = 5,
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
        can_insert = instatube_can_insert,
        priority = 75,
    },
})

core.register_node("sbz_instatube:one_way_instatube", unifieddyes.def {
    description = "One Way Instatube",
    tiles = {
        "one_way_instatube.png",
        "one_way_instatube.png",
        "instatube.png",
        "instatube.png",
        "one_way_instatube.png^[transformFX",
        "one_way_instatube.png",
    },
    light_source = 5,
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "colorfacedir",
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
        fixed = wire(wire_size, "left+right"),
    },
    use_texture_alpha = "clip",
    tube = {
        connect_sides = { left = 1, right = 1 },
        can_go = function(pos, node, stack, velocity, owner)
            return { velocity }
        end,
        can_insert = function(pos, node, stack, direction)
            return vector.equals(pipeworks.facedir_to_right_dir(node.param2), direction)
        end,
        insert_object = instatube_insert_object,
        priority = 80,
    },
    on_rotate = pipeworks.on_rotate,
})
-- i hope indexing this is faster than indexing node def
special_insert_logic["sbz_instatube:one_way_instatube"] = function(pos, node, dir)
    return vector.equals(pipeworks.facedir_to_right_dir(node.param2), dir)
end

-- now the item filter

core.register_node("sbz_instatube:item_filter", unifieddyes.def {
    description = "Instatube Item Filter",
    connects_to = { "group:tubedevice", "pipeworks:automatic_filter_injector" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },
    paramtype2 = "color",
    light_source = 5,
    tiles = { "instatube_item_filter.png" },
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
    drawtype = "nodebox",
    paramtype = "light",
    sunlight_propagates = true,
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        meta:set_string("formspec", [[
formspec_version[8]
size[10.2,8.2]
list[context;filter;0.22,0.5;5,1;]
list[current_player;main;0.22,3;8,4;]
listring[]
]])
        inv:set_size("filter", 5) -- only has virtual items, not real items
    end,
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
        priority = 80,
    },
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        local inv = minetest.get_meta(pos):get_inventory()
        local stack_copy = ItemStack(stack)
        stack_copy:set_count(1)
        inv:set_stack(listname, index, stack_copy)
        return 0
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        local inv = minetest.get_meta(pos):get_inventory()
        inv:set_stack(listname, index, ItemStack(""))
        return 0
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        local inv = minetest.get_meta(pos):get_inventory()
        inv:set_stack(from_list, from_index, ItemStack(""))
        return 0
    end,
})

instatube.special_filter_logic["sbz_instatube:item_filter"] = function(pos, node, dir, stack)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local filtlist = inv:get_list("filter")
    if not filtlist then return false end          -- this check is NEEDED!!!
    local passing_filter = false
    if inv:is_empty("filter") then return true end -- just like pipeworks lol
    for k, fstack in ipairs(filtlist) do
        if fstack:get_name() == stack:get_name() and fstack:get_count() <= stack:get_count() then
            passing_filter = true
        end
    end
    return passing_filter
end

core.register_node("sbz_instatube:high_priority_instant_tube", unifieddyes.def {
    description = "High Priority Instatube",
    connects_to = { "group:tubedevice", "pipeworks:automatic_filter_injector" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },
    paramtype2 = "color",
    light_source = 5,
    tiles = { "high_priority_instatube.png" },
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
        priority = 150,
    },
})
instatube.special_priority["sbz_instatube:high_priority_instant_tube"] = 150

core.register_node("sbz_instatube:low_priority_instant_tube", unifieddyes.def {
    description = "Low Priority Instatube",
    info_extra = "Can't be used with normal tubes, but with instatubes it works fine.",
    connects_to = { "group:tubedevice", "pipeworks:automatic_filter_injector" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },
    paramtype2 = "color",
    light_source = 5,
    tiles = { "low_priority_instatube.png" },
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
        priority = -150,
    },
})
instatube.special_priority["sbz_instatube:low_priority_instant_tube"] = -150

core.register_node("sbz_instatube:teleport_instant_tube", unifieddyes.def {
    description = "Teleport Instatube",
    info_extra = { "Links to all teleport tubes in a channel at once." },
    connects_to = { "group:tubedevice", "pipeworks:automatic_filter_injector" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },
    paramtype2 = "color",
    light_source = 5,
    tiles = { "teleport_instatube.png" },
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
        tptube = 1,
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
    -- how convenient, almost like i modified pipeworks for this or something
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("can_receive", 1) -- Enabled by default
        pipeworks.tptube.update_meta(meta)
    end,
    on_logic_send = pipeworks.tptube.logic_action,
    on_destruct = pipeworks.tptube.remove_tube,
    on_receive_fields = pipeworks.tptube.receive_fields,
    tube = {
        connect_sides = { front = 1, back = 1, left = 1, right = 1, top = 1, bottom = 1 },
        insert_object = instatube_insert_object,
        priority = 80,
    },
})

instatube.special_insert_logic["sbz_instatube:teleport_instant_tube"] = function(pos)
    local meta = minetest.get_meta(pos)
    local channel = meta:get_string("channel")
    if channel == "" then
        return false
    end
    local receivers = pipeworks.tptube.get_receivers(pos, channel)
    if #receivers == 0 then
        return false
    end
    return receivers
end

mesecon.register_on_mvps_move(function(moved_nodes)
    for _, n in ipairs(moved_nodes) do
        if n.node.name == "sbz_instatube:teleport_instant_tube" then
            local meta = minetest.get_meta(n.pos)
            pipeworks.tptube.remove_tube(n.oldpos)
            pipeworks.tptube.set_tube(n.pos, meta:get_string("channel"), meta:get_int("can_receive"))
        end
    end
end)

core.register_node("sbz_instatube:randomized_input_instant_tube", unifieddyes.def {
    description = "Randomized Input Instatube",
    connects_to = { "group:tubedevice", "pipeworks:automatic_filter_injector" },
    info_extra = { "" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },
    paramtype2 = "color",
    light_source = 5,
    tiles = { "randomized_input_instatube.png" },
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
        insert_object = wrap_instatube_insert_object("randomized"),
        priority = 75,
    },
})

core.register_node("sbz_instatube:cycling_input_instant_tube", unifieddyes.def {
    description = "Cycling Input Instatube",
    connects_to = { "group:tubedevice", "pipeworks:automatic_filter_injector" },
    info_extra = { "" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },
    paramtype2 = "color",
    light_source = 5,
    tiles = { "cycling_input_instatube.png" },
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
        insert_object = wrap_instatube_insert_object("cycle"),
        priority = 75,
    },
})

dofile(core.get_modpath("sbz_instatube") .. "/recipes.lua")

local function remove_all_nets_around(pos)
    iterate_around_pos(pos, function(ipos)
        local hpos = core.hash_node_position(ipos)
        local nets_at_hpos = pos2network[hpos]
        if nets_at_hpos then
            for k, v in ipairs(nets_at_hpos) do
                if instatube.networks[v] then
                    instatube.networks[v] = nil
                end
            end
        end
        pos2network[hpos] = nil
    end, true)
end


core.register_on_mods_loaded(function()
    for name, def in pairs(core.registered_nodes) do
        if core.get_item_group(name, "instatube") > 0 or core.get_item_group(name, "tubedevice") > 0 then
            local og_construct = def.on_construct
            local og_destruct = def.on_destruct
            core.override_item(name, {
                on_construct = function(pos)
                    remove_all_nets_around(pos)
                    if og_construct then return og_construct(pos) end
                end,
                on_destruct = function(pos)
                    remove_all_nets_around(pos)
                    if og_destruct then return og_destruct(pos) end
                end
            })
        end
    end
end)

instatube.show_network = function(p1, p2, net)
    p1, p2 = vector.sort(p1, p2)
    local A = VoxelArea(p1, p2)
    for i in A:iterp(p1, p2) do
        local p = A:position(i)
        local p2n = pos2network[core.hash_node_position(p)]
        if p2n then
            for k, v in pairs(p2n) do
                if v == net then
                    core.add_entity(p, "sbz_base:debug_entity")
                end
            end
        end
    end
    local network = instatube.networks[net]
    if network then
        for k, v in pairs(network.machines) do
            core.add_entity(v.pos, "sbz_base:debug_entity", "green")
        end
    end
end
