-- sbz_node_damage :D

local function loop()
    for _, obj in pairs(core.get_connected_players()) do
        local node_at_pos = core.get_node_or_nil(obj:get_pos())
        if node_at_pos then
            local def = core.registered_nodes[node_at_pos.name]
            if def and def.sbz_node_damage then
                sbz_api.punch(obj, nil, nil, {
                    full_punch_interval = 0,
                    damage_groups = def.sbz_node_damage,
                })
            end
        end
    end
    core.after(1, loop)
end

core.after(1, loop)
