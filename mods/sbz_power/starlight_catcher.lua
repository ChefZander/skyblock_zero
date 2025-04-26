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

local assemble_network = function(start_pos)
    local seen = {}
    local net_id = get_next_net_id()
    local amount = -1 -- hacky i know

    pos2network[h(start_pos)] = net_id
    local stack = {}
    ---@type number
    local index = 0

    index = index + 1
    stack[index] = start_pos

    sbz_api.vm_begin()

    while index > 0 do
        local pos = stack[index]
        index = index - 1
        if not seen[h(pos)] then
            seen[h(pos)] = true
            local node = sbz_api.get_node_force(pos)
            if node then
                if node.name == "sbz_power:starlight_catcher" or h(pos) == h(start_pos) then
                    amount = amount + 1
                    pos2network[h(pos)] = net_id
                    sbz_api.iterate_around_pos_nocopy(pos, function(ipos)
                        index = index + 1
                        stack[index] = ipos
                    end)
                elseif node.name == "sbz_power:photon_energy_converter" and h(pos) ~= h(start_pos) then
                    return -1
                end
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
