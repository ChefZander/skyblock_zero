-- provides sbz_player_inside
-- every 0.5 seconds
local timer = 0
core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 0.5 then
        timer = 0
        for k, obj in pairs(core.get_connected_players()) do
            local pos = obj:get_pos()
            local node = core.get_node(pos)
            local def = core.registered_nodes[node.name]
            if def and def.sbz_player_inside then
                def.sbz_player_inside(pos, obj)
            end
        end
    end
end)
