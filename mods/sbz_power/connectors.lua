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
    on_rightclick = function(pos, node, person)
        if not core.is_protected(pos, person:get_player_name()) then -- fix very very bad bug!
            node.name = "sbz_power:connector_on"
            minetest.swap_node(pos, node)
            iterate_around_pos(pos, function(ipos, dir)
                if sbz_api.get_switching_station_network(ipos) then
                    sbz_api.get_switching_station_network(ipos).dirty = true
                end
            end, true)
            minetest.sound_play({ name = "door-lock-43124" }, { pos = pos }, true)
        end
    end,
    on_turn_on = function(pos)
        iterate_around_pos(pos, function(ipos, dir)
            if sbz_api.get_switching_station_network(ipos) then
                sbz_api.get_switching_station_network(ipos).dirty = true
            end
        end, true)
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
    on_rightclick = function(pos, node, person)
        if not core.is_protected(pos, person:get_player_name()) then -- fix very very bad bug!
            node.name = "sbz_power:connector_off"
            minetest.swap_node(pos, node)
            iterate_around_pos(pos, function(ipos, dir)
                if sbz_api.get_switching_station_network(ipos) then
                    sbz_api.get_switching_station_network(ipos).dirty = true
                end
            end, true)
            minetest.sound_play({ name = "door-lock-43124" }, { pos = pos }, true)
        end
    end,
    assemble = function(pos, node, dir, network, seen, parent_net_id)
        seen[hash(pos)] = true
        local self_dir = vector.copy(minetest.wallmounted_to_dir(node.param2))
        if self_dir + dir == vector.zero() or self_dir - dir == vector.zero() then
            local new_network = sbz_api.assemble_network(pos + dir, seen, parent_net_id)
            for k, val in pairs(new_network) do
                if type(val) ~= "table" then
                    network[k] = val
                else
                    table.insert_all(network[k], val)
                end
            end
        end
    end,
    use_texture_alpha = "clip",
    on_turn_off = function(pos)
        iterate_around_pos(pos, function(ipos, dir)
            if sbz_api.get_switching_station_network(ipos) then
                sbz_api.get_switching_station_network(ipos).dirty = true
            end
        end, true)
    end,

})

minetest.register_craft({
    output = "sbz_power:connector_off",
    recipe = {
        { "",                     "sbz_resources:emittrium_circuit", "" },
        { "sbz_power:power_pipe", "sbz_resources:reinforced_matter", "sbz_power:power_pipe" }
    }
})
