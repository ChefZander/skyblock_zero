local pos2network = {}
local networks = {}

local max_net_id = 0
local function get_next_net_id()
    max_net_id = max_net_id + 1
    return max_net_id
end

local h = core.hash_node_position


local remove_nets = function(pos)
    iterate_around_pos(pos, function(ipos, dir)
        if pos2network[h(ipos)] then
            local net = pos2network[h(ipos)]
            networks[net] = nil
        end
        pos2network[h(ipos)] = nil
    end)
end

core.register_node("sbz_power:starlight_catcher", {
    description = "Starlight Catcher",
    info_extra =
    "For those who insist on starlight collectors.\n Generates energy and is less laggy in large quantities.\n It generates energy that can be converted to 1Cj/s. ",
    tiles = {
        "starlight_catcher_up.png",
        "starlight_catcher_side.png",
        "starlight_catcher_side.png",
        "starlight_catcher_side.png",
        "starlight_catcher_side.png",
        "starlight_catcher_side.png",
    },
    groups = { matter = 1 },
    on_construct = remove_nets,
    on_destruct = remove_nets,
})

local wallmounted_to_dir = {
    [0] = { 0, 1, 0 },
    { 0,  -1, 0 },
    { 1,  0,  0 },
    { -1, 0,  0 },
    { 0,  0,  1 },
    { 0,  0,  -1 },
}

-- i attempted to optimize this function as much as i possibly could

local stack = {} -- attempt to optimize GC
local assemble_network = function(start_pos)
    local seen = {}
    local net_id = get_next_net_id()
    local amount = -1 -- hacky i know

    pos2network[h(start_pos)] = net_id
    ---@type number
    local index = 0

    index = index + 1
    stack[index] = start_pos

    local h_start_pos = h(start_pos)
    local get_or_load_node = sbz_api.get_or_load_node
    while index > 0 do
        local pos = stack[index]
        index = index - 1
        local hpos = h(pos)
        if not seen[hpos] then
            seen[hpos] = true
            local node = get_or_load_node(pos)
            local nodename = node.name
            if nodename == "sbz_power:starlight_catcher" or hpos == h_start_pos then
                amount = amount + 1
                pos2network[hpos] = net_id

                for i = 0, 5 do
                    local dir = wallmounted_to_dir[i]
                    local ipos = {
                        x = dir[1] + pos.x,
                        y = dir[2] + pos.y,
                        z = dir[3] + pos.z
                    }
                    index = index + 1
                    stack[index] = ipos
                end
            elseif nodename == "sbz_power:photon_energy_converter" and hpos ~= h_start_pos then
                return -1
            end
        end
    end
    networks[net_id] = amount
    return net_id
end

sbz_api.register_generator("sbz_power:photon_energy_converter", {
    description = "Photon-Energy Converter",
    info_extra =
    "Converts energy provided by starlight catchers to cosmic joules.\nFor maximum possible lag-reduction during construction, place this component last. (So for about 10 000 starlight catchers, you should consider it.)",
    tiles = {
        "photon_energy_converter.png",
    },
    groups = { matter = 1 },
    action = function(pos, node, meta, supply, demand)
        local net_id = pos2network[h(pos)]
        if not net_id or not networks[net_id] then
            net_id = assemble_network(pos)
            if net_id == -1 then
                meta:set_string("infotext", "Can't have 2 photon-energy converters. Remove this one.")
                return 0
            end
        end
        meta:set_string("infotext", "Generating " .. networks[net_id] .. "Cj")

        return networks[net_id]
    end,
    on_construct = remove_nets,
    on_destruct = remove_nets,
})

core.register_craft {
    type = "shapeless",
    output = "sbz_power:photon_energy_converter",
    recipe = {
        "sbz_power:starlight_catcher", "sbz_power:switching_station", "sbz_resources:emittrium_circuit"
    },
}

core.register_craft {
    output = "sbz_power:starlight_catcher",
    recipe = {
        { "sbz_power:starlight_collector", "sbz_power:starlight_collector", "sbz_power:starlight_collector", },
        { "sbz_power:power_pipe",          "sbz_power:power_pipe",          "sbz_power:power_pipe", }
    }
}
