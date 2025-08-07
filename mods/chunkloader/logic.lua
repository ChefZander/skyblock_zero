chunkloader.action = function(pos, _, meta, supply, demand)
    local meta = core.get_meta(pos)
    local run = meta:get_int("running") == 1
    local prev_state = meta:get_int("prev_state") == 1
    local owner = meta:get_string("owner")

    local power_needed = 300

    if not chunkloader.player_online(owner) then
        meta:set_int("prev_state", meta:get_int("running"))
        meta:set_int("running", 0)
        return power_needed, false
    end
    if demand + power_needed > supply then
        meta:set_int("prev_state", meta:get_int("running"))
        meta:set_int("running", 0)
        return power_needed, false
    else
        meta:set_int("prev_state", meta:get_int("running"))
        meta:set_int("running", 1)
    end

    meta:set_string("infotext", run and "Running" or "Idle")

    if prev_state == 0 and run == 1 then
        core.forceload_block(pos)
    elseif prev_state == 1 and run == 0 then
        core.forceload_free_block(pos)
    end

    return power_needed
end
