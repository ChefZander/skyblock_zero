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


minetest.register_node("sbz_power:fluid_pipe", {
    description = "Fluid pipe",
    info_extra = "Transports liquid",

    connects_to = { "group:fluid_pipe_connects" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },

    tiles = { "fluid_pipe.png" },

    drawtype = "nodebox",
    light_source = 3,
    paramtype = "light",
    sunlight_propagates = true,

    groups = { matter = 1, cracky = 3, fluid_pipe_connects = 1 },

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

local pump_consumbtion = 5
local animation_def = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1,
}

function sbz_api.pump(pos, liquid_stack)
    local name, amount = liquid_stack.name, liquid_stack.amount

    sbz_api.vm_begin()

    local abort = false

    local seen = {}
    local hash = minetest.hash_node_position

    local function internal(pos)
        if not seen[hash(pos)] and not abort then
            local node = sbz_api.vm_get_node(pos).name

            local is_conducting = node == "sbz_power:fluid_pipe"
            local is_storing = minetest.get_item_group(node, "fluid_pipe_stores") == 1

            if is_storing then
                do_storey_stuff()
            end
            seen[hash(pos)] = true

            if is_conducting then
                iterate_around_pos(pos, internal)
            end
        end
    end
    internal(table.copy(start_pos))
end

sbz_api.register_stateful_machine("sbz_power:pump", {
    description = "Fluid pump",
    autostate = true,
    disallow_pipeworks = true,
    paramtype2 = "facedir",
    tiles = {
        { name = "filter_side.png^[transformFX", animation = animation_def },
        { name = "filter_side.png^[transformFX", animation = animation_def },
        "filter_output.png",
        "filter_input.png",
        { name = "filter_side.png",              animation = animation_def },
        { name = "filter_side.png^[transformFX", animation = animation_def },
    },
    groups = { matter = 1, fluid_pipe_connects = 1 },
    action = function(pos, node, meta, supply, demand)
        if supply > demand + pump_consumbtion then
            meta:set_string("infotext", "Not enough power")
            return pump_consumbtion
        else
            node = minetest.get_node(pos)
            local dir = pipeworks.facedir_to_right_dir(node.param2)

            local frompos = vector.subtract(pos, dir)
            local topos = vector.add(pos, dir)

            local fromnode = minetest.get_node(frompos).name
            local tonode = minetest.get_node(topos).name

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
            local target_stack = from_liquid_inv[#from_liquid_inv]
            if target_stack == nil then
                meta:set_string("infotext", "The node you are pulling from is empty.")
                return 0
            end

            local stack_left = sbz_api.pump(topos, target_stack)
            from_liquid_inv[#from_liquid_inv + 1] = stack_left

            frommeta:set_string("liquid_inv", minetest.serialize(from_liquid_inv))
            meta:set_string("infotext", "Running")
            return pump_consumbtion
        end
    end
}, {
    light_source = 3,
})
