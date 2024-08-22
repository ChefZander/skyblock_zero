local hash = minetest.hash_node_position

minetest.register_node("sbz_power:connector_off", {
    description = "Connector",
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    light_source = 3,
    groups = { pipe_connects = 1, matter = 1, cracky = 3, pipe_conducts = 0 },
    node_box = {
        type = "fixed",
        fixed = {
            { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 }
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
    connects_to = { "sbz_power:power_pipe", "group:sbz_machine" },
    on_rightclick = function(pos, node)
        node.name = "sbz_power:connector_on"
        minetest.swap_node(pos, node)
        minetest.sound_play({name="door-lock-43124"}, {pos=pos}, true)
    end,
    use_texture_alpha = "clip",
})

minetest.register_node("sbz_power:connector_on", {
    description = "Connector",
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    light_source = 5,
    groups = { pipe_connects = 1, sbz_connector = 1, matter = 1, cracky = 3, not_in_creative_inventory = 1, pipe_conducts = 0 },
    node_box = {
        type = "fixed",
        fixed = {
            { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 }
        }
    },
    drop = "sbz_power:connector_off",
    tiles = {
        "switch_end.png",
        "switch_end.png",
        "switch_on.png",
        "switch_on.png",
        "switch_on.png",
        "switch_on.png"
    },
    connects_to = { "sbz_power:power_pipe", "group:sbz_machine" },
    on_rightclick = function(pos, node)
        node.name = "sbz_power:connector_off"
        minetest.swap_node(pos, node)
        minetest.sound_play({name="door-lock-43124"}, {pos=pos}, true)
    end,
    assemble = function(pos, node, dir, network, seen)
        seen[hash(pos)] = true
        local self_dir = minetest.wallmounted_to_dir(node.param2)
        if self_dir + dir == vector.zero() or self_dir - dir == vector.zero() then
            local new_network = sbz_api.assemble_network(pos + dir, seen)
            for k, val in pairs(new_network) do
                table.insert_all(network[k], val)
            end
        end
    end,
    use_texture_alpha = "clip",
})

minetest.register_craft({
    output = "sbz_power:connector_off",
    recipe = {
        { "",                         "sbz_resources:emittrium_circuit", "" },
        { "sbz_power:power_pipe", "sbz_resources:reinforced_matter", "sbz_power:power_pipe" }
    }
})