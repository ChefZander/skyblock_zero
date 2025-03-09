-- in node def:
-- sbz_node_hover(pointed, player)
-- called every 0.5 seconds
local on_hover_range = 5
local timer = 0
core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 0.5 then
        timer = 0
        for k, obj in pairs(core.get_connected_players()) do
            local lookdir = obj:get_look_dir()
            local eyepos = sbz_api.get_pos_with_eye_height(obj)
            local ray = core.raycast(eyepos, vector.add(eyepos, vector.multiply(lookdir, on_hover_range)), false, false)
            for pointed_thing in ray do
                if pointed_thing.type == "node" then
                    local node = core.get_node(pointed_thing.under)
                    local def = core.registered_nodes[node.name]
                    if def then
                        if def.sbz_on_hover then
                            def.sbz_on_hover(pointed_thing, obj)
                        end
                    end
                end
            end
        end
    end
end)
