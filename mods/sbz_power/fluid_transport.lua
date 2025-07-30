-- "entirety of fluid transport in 1 file, seriously?... even in the sbz_power mod... like bro"
-- - frog, writing to past self

sbz_api.fluid_transport = {}
local fluid_transport = sbz_api.fluid_transport
fluid_transport.pos2network = {}
fluid_transport.networks = {}
local network_max_id = 0
local function get_next_network_id()
    network_max_id = network_max_id + 1
    return network_max_id
end

local pos2network = fluid_transport.pos2network
local networks = fluid_transport.networks

local function add_to_pos2network(pos, net)
    local p2n = pos2network[core.hash_node_position(pos)]
    if p2n then
        p2n[#p2n + 1] = net
    else
        pos2network[core.hash_node_position(pos)] = { net }
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

local wire_size = 3 / 16

minetest.register_node("sbz_power:fluid_pipe", {
    description = "Fluid Pipe",
    info_extra = "Transports liquid",

    connects_to = { "group:fluid_pipe_connects" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },

    tiles = { "fluid_pipe.png" },

    drawtype = "nodebox",
    light_source = 3,
    paramtype = "light",
    sunlight_propagates = true,

    groups = { matter = 1, cracky = 3, fluid_pipe_connects = 1, ui_fluid = 1, sbz_fluid_conducts = 1 },

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
})

minetest.register_craft {
    output = "sbz_power:fluid_pipe 8",
    recipe = {
        { "pipeworks:tube_1", "pipeworks:tube_1",                   "pipeworks:tube_1" },
        { "pipeworks:tube_1", "sbz_resources:compressed_core_dust", "pipeworks:tube_1" },
        { "pipeworks:tube_1", "pipeworks:tube_1",                   "pipeworks:tube_1" },
    }
}


local pump_consumbtion = 5
local animation_def = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1,
}

local function liquid_inv_add_item(inv, stack, on_update, pos)
    local max_count_in_each_stack = inv.max_count_in_each_stack
    local changed = false

    for i = 1, #inv do
        local inv_stack = inv[i]
        if
            (inv_stack.name == stack.name or (inv_stack.name == "any" or (inv_stack.can_change_name and inv_stack.count == 0)))
            and inv_stack.count < max_count_in_each_stack
        then
            local leftover = 0
            inv_stack.count = inv_stack.count + stack.count
            if inv_stack.count > max_count_in_each_stack then
                leftover = inv_stack.count - max_count_in_each_stack
                inv_stack.count = inv_stack.count - leftover
            end
            stack.count = leftover
            changed = true
            if inv_stack.name == "any" then inv_stack.name = stack.name end
            if on_update then on_update(pos, inv) end
            if stack.count == 0 then
                break
            end
        end
    end
    return stack, changed
end

function fluid_transport.assemble_network(start_pos, frompos)
    local net_id = get_next_network_id()
    networks[net_id] = {
        dity = false,
    } -- a simple array of machines, beautiful really
    -- realistically, a dirty = true scenario should never happen, but who knows what i will do in the future
    local net = networks[net_id]
    sbz_api.vm_begin()
    local seen = {}
    local h = core.hash_node_position
    local queue = Queue.new()

    seen[h(start_pos)] = true
    queue:enqueue(start_pos)
    pos2network[h(start_pos)] = { net_id }

    while not queue:is_empty() do
        local current_pos = queue:dequeue()
        local node = (sbz_api.get_or_load_node(current_pos) or {}).name
        local is_conducting = minetest.get_item_group(node, "sbz_fluid_conducts") == 1
        local is_storing = minetest.get_item_group(node, "fluid_pipe_stores") == 1

        if is_storing and h(current_pos) ~= h(frompos) then
            net[#net + 1] = current_pos
        end

        if is_conducting then
            add_to_pos2network(current_pos, net_id)
            iterate_around_pos(current_pos, function(pos)
                if not seen[h(pos)] then
                    seen[h(pos)] = true
                    queue:enqueue(pos)
                end
            end)
        end
    end
    return net_id
end

function fluid_transport.pump(start_pos, liquid_stack, frompos)
    local nets = pos2network[core.hash_node_position(start_pos)]
    local net
    if nets then
        net = networks[nets[1] or -1]
    end

    if not net or net.dirty then
        net = networks[fluid_transport.assemble_network(start_pos, frompos)]
    end

    local abort = false
    for _, current_pos in ipairs(net) do
        local node = (sbz_api.get_node_force(current_pos) or {}).name

        local meta = minetest.get_meta(current_pos)
        local liquid_inventory = minetest.deserialize(meta:get_string("liquid_inv"))
        local changed
        liquid_stack, changed = liquid_inv_add_item(liquid_inventory, liquid_stack,
            minetest.registered_nodes[node].on_liquid_inv_update, current_pos)
        if liquid_stack.count == 0 then
            abort = true
        end
        if changed then
            meta:set_string("liquid_inv", minetest.serialize(liquid_inventory))
        end
        if abort then break end
    end
    return liquid_stack
end

sbz_api.register_stateful_machine("sbz_power:pump", {
    description = "Fluid Pump",
    autostate = true,
    paramtype2 = "facedir",
    after_place_node = function(pos)
        local node = minetest.get_node(pos)
        node.param2 = node.param2 + 1
        minetest.swap_node(pos, node)
    end,
    disallow_pipeworks = true,
    tiles = {
        { name = "pump_side.png", animation = animation_def },
        { name = "pump_side.png", animation = animation_def },
        "pump_output.png",
        "pump_input.png",
        { name = "pump_side.png^[transformFX", animation = animation_def },
        { name = "pump_side.png",              animation = animation_def },
    },
    groups = { matter = 1, fluid_pipe_connects = 1, ui_fluid = 1 },

    action = function(pos, node, meta, supply, demand)
        if supply < demand + pump_consumbtion then
            meta:set_string("infotext", "Not enough power")
            return pump_consumbtion, false
        else
            node = sbz_api.get_node_force(pos)
            if not node then return 0 end
            local dir = pipeworks.facedir_to_right_dir(node.param2)

            local frompos = vector.subtract(pos, dir)
            local topos = vector.add(pos, dir)

            local fromnode = (sbz_api.get_node_force(frompos) or {}).name or ""
            local tonode = (sbz_api.get_node_force(topos) or {}).name or ""

            if not minetest.get_item_group(fromnode, "fluid_pipe_stores") then
                meta:set_string("infotext", "Can't pull from that node")
                return 0
            end

            if not minetest.get_item_group(tonode, "fluid_pipe_connects") then
                meta:set_string("infotext", "Can't push to that node")
                return 0
            end

            local frommeta = minetest.get_meta(frompos)

            local from_liquid_inv = minetest.deserialize(frommeta:get_string("liquid_inv"))
            if from_liquid_inv == nil then
                meta:set_string("infotext", "The node you are pulling from doesn't have a liquid inventory.")
                return 0
            end

            local target_stack
            local target_stack_index

            for k, v in ipairs(from_liquid_inv) do
                if v.count ~= 0 then
                    target_stack = v
                    target_stack_index = k
                    break
                end
            end

            if target_stack == nil then
                meta:set_string("infotext", "The node you are pulling from is empty.")
                return 0
            end

            local target_stack_copy = table.copy(target_stack)

            local stack_left = fluid_transport.pump(topos, target_stack, frompos)
            from_liquid_inv[target_stack_index] = stack_left

            frommeta:set_string("liquid_inv", minetest.serialize(from_liquid_inv))

            if stack_left.count == target_stack_copy.count then
                meta:set_string("infotext", "Can't push - everything that can be filled is")
                return 0
            end

            meta:set_string("infotext", "Running")
            if minetest.registered_nodes[fromnode].on_liquid_inv_update then
                minetest.registered_nodes[fromnode].on_liquid_inv_update(
                    frompos,
                    minetest.deserialize(minetest.get_meta(frompos):get_string("liquid_inv")))
            end
            return pump_consumbtion
        end
    end
}, {
    light_source = 3,
}, {
    tiles = {
        [1] = "pump_side.png^[verticalframe:15:1",
        [2] = "pump_side.png^[verticalframe:15:1",
        [5] = "pump_side.png^[transformFX^[verticalframe:15:1",
        [6] = "pump_side.png^[verticalframe:15:1",
    }
})

minetest.register_craft({
    output = "sbz_power:pump_off",
    recipe = {
        { "sbz_power:fluid_pipe", "pipeworks:automatic_filter_injector", "sbz_power:fluid_pipe" }
    }
})

minetest.register_node("sbz_power:fluid_tank", {
    description = "Fluid Storage Tank",
    groups = { matter = 1, fluid_pipe_connects = 1, fluid_pipe_stores = 1, ui_fluid = 1 },
    tiles = {
        "fluid_tank_top.png",
        "fluid_tank_top.png",
        "fluid_tank_side.png",
        "fluid_tank_side.png",
        "fluid_tank_side.png",
        "fluid_tank_side.png",
    },
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("liquid_inv", minetest.serialize({
            max_count_in_each_stack = 100, -- 100 buckets
            [1] = {
                name = "any",
                count = 0,
                can_change_name = true,
            },
        }))
        meta:set_string("infotext", "Waiting for a liquid...")
    end,
    on_liquid_inv_update = function(pos, lqinv)
        local meta = minetest.get_meta(pos)
        if lqinv[1].name == "any" then
            meta:set_string("infotext", "Waiting for a liquid...")
            return
        end
        local def = minetest.registered_nodes[lqinv[1].name]
        local desc = string.gsub(def.short_description or def.description or lqinv[1].name, " Source", "")
        meta:set_string("infotext", ("Storing %s : %s/%s"):format(desc, lqinv[1].count, lqinv.max_count_in_each_stack))
        meta:set_string("formspec", sbz_api.liquid_storage_fs(lqinv[1].count, lqinv.max_count_in_each_stack))
    end
})

minetest.register_craft({
    output = "sbz_power:fluid_tank",
    recipe = {
        { "sbz_power:fluid_pipe", "sbz_resources:storinator",           "sbz_power:fluid_pipe" },
        { "sbz_power:fluid_pipe", "sbz_resources:retaining_circuit",    "sbz_power:fluid_pipe" },
        { "sbz_power:fluid_pipe", "sbz_resources:compressed_core_dust", "sbz_power:fluid_pipe" }
    }
})

local fluid_capturer_demand = 10
sbz_api.register_stateful_machine("sbz_power:fluid_capturer", {
    description = "Fluid Capturer",
    autostate = true,
    tiles = {
        "fluid_capturer_top.png^[verticalframe:7:7",
        "fluid_capturer_bottom.png",
        "fluid_capturer_side.png^[verticalframe:8:0",
    },
    groups = { matter = 1, fluid_pipe_connects = 1, fluid_pipe_stores = 1, ui_fluid = 1 },
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("liquid_inv", minetest.serialize({
            max_count_in_each_stack = 5,
            [1] = {
                name = "any",
                count = 0,
                can_change_name = false,
            },
        }))
    end,

    action = function(pos, node, meta, supply, demand)
        if supply < demand + fluid_capturer_demand then
            meta:set_string("infotext", "Not enough power")
            return fluid_capturer_demand, false
        end
        local up_pos = vector.add(pos, { x = 0, y = 1, z = 0 })
        local up_node = (sbz_api.get_node_force(up_pos) or {}).name or ""
        if minetest.get_item_group(up_node, "liquid_capturable") ~= 1 then
            meta:set_string("infotext", "Above this node isn't a valid liquid")
            return 0
        end

        local lqinv = minetest.deserialize(meta:get_string("liquid_inv"))

        local expect = lqinv[1].name

        if expect ~= "any" and expect ~= up_node then
            meta:set_string("infotext", "Can't accept that liquid, replace the fluid capturer")
            return 0
        end

        if lqinv[1].count >= lqinv.max_count_in_each_stack then
            meta:set_string("infotext", "Full")
            return 0
        end

        meta:set_string("infotext", "Running")

        lqinv[1].name = up_node
        minetest.remove_node(up_pos)
        lqinv[1].count = lqinv[1].count + 1
        meta:set_string("liquid_inv", minetest.serialize(lqinv))
        return fluid_capturer_demand
    end,

}, {
    tiles = {
        { name = "fluid_capturer_top.png", animation = animation_def },
        [3] = { name = "fluid_capturer_side.png", animation = animation_def }
    },
    light_source = 3,
})

minetest.register_craft({
    output = "sbz_power:fluid_capturer_off",
    recipe = {
        { "sbz_chem:empty_fluid_cell" },
        { "sbz_power:fluid_pipe" },
        { "sbz_power:fluid_tank" }
    }
})


sbz_api.register_machine("sbz_power:fluid_cell_filler", {
    description = "Fluid Cell Filler",
    tiles = {
        "fluid_tank_top.png",
        "fluid_tank_top.png",
        "fluid_tank_top.png^fluid_cell.png",
    },
    groups = { matter = 1, fluid_pipe_connects = 1, fluid_pipe_stores = 1, ui_fluid = 1 },
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("liquid_inv", minetest.serialize({
            max_count_in_each_stack = 5,
            [1] = {
                name = "any",
                count = 0,
                can_change_name = false,
            },
        }))
        local inv = meta:get_inventory()
        inv:set_size("input", 1)
        inv:set_size("output", 1)
        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
item_image[2.5,2;0.8,0.8;sbz_chem:empty_fluid_cell]
list[context;input;2.5,2;1,1;]
list[context;output;4.5,2;1,1;]
list[current_player;main;0.2,5;8,4;]
listring[context;input]listring[]
    ]])
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "input" then
            if stack:get_name() == "sbz_chem:empty_fluid_cell" then
                return stack:get_count()
            end
            return 0
        elseif listname == "output" then
            return 0
        else
            return stack:get_count()
        end
    end,
    tube = {
        insert_object = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            if stack:get_name() ~= "sbz_chem:empty_fluid_cell" then
                return stack
            end
            return inv:add_item("input", stack)
        end,
        can_insert = function(pos, node, stack, direction)
            if stack:get_name() ~= "sbz_chem:empty_fluid_cell" then
                return false
            end
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()

            stack = stack:peek_item(1)
            return inv:room_for_item("input", stack)
        end,
        input_inventory = "output",
        connect_sides = { left = 1, right = 1, back = 1, front = 1, top = 1, bottom = 1 },
    },
    input_inv = "input",
    output_inv = "output",
    action = function(pos, node, meta, supply, demand)
        if supply < demand + fluid_capturer_demand then
            meta:set_string("infotext", "Not enough power, needs 40")
            return 40, false
        end
        local inv = meta:get_inventory()
        local input = inv:get_stack("input", 1)
        local output = inv:get_stack("input", 1)

        local lqinv = minetest.deserialize(meta:get_string("liquid_inv"))

        if lqinv[1].count == 0 then
            meta:set_string("infotext", "Not enough fluid inside")
            return 0
        end
        if not sbz_api.sources2fluid_cells[lqinv[1].name] then
            meta:set_string("infotext", "Cannot put that liquid in a fluid cell")
            return 0
        end
        if input:get_count() == 0 then
            meta:set_string("infotext", "Ran out of empty fluid cells")
            return 0
        end

        local craftresult = sbz_api.sources2fluid_cells[lqinv[1].name]

        if not inv:room_for_item("output", craftresult) then
            meta:set_string("infotext", "Full")
            return 0
        end

        lqinv[1].count = lqinv[1].count - 1
        inv:add_item("output", craftresult)
        inv:remove_item("input", "sbz_chem:empty_fluid_cell")
        meta:set_string("liquid_inv", minetest.serialize(lqinv))

        meta:set_string("infotext", "Running")
        return 40
    end,
    on_liquid_inv_update = function() end,
})

minetest.register_craft {
    output = "sbz_power:fluid_cell_filler",
    recipe = {
        { "sbz_chem:empty_fluid_cell", "sbz_resources:robotic_arm", "sbz_power:fluid_tank" }
    }
}

local function remove_all_nets_around(pos)
    iterate_around_pos(pos, function(ipos)
        local hpos = core.hash_node_position(ipos)
        local nets_at_hpos = pos2network[hpos]
        if nets_at_hpos then
            for k, v in ipairs(nets_at_hpos) do
                if networks[v] then
                    networks[v] = nil
                end
            end
        end
        pos2network[hpos] = nil
    end, true)
end


core.register_on_mods_loaded(function()
    for name, def in pairs(core.registered_nodes) do
        if core.get_item_group(name, "fluid_pipe_connects") > 0 then
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
