chunkloader.action = function(pos, _, meta, supply, demand)
    local meta = core.get_meta(pos)
    local run = meta:get_int("running") == 1
    local prev_state = meta:get_int("prev_state") == 1
    local perpetual = meta:get_int("perpetual") == 1

    local power_needed = 25

    if not perpetual then
        if demand + power_needed > supply then
            meta:set_int("prev_state", meta:get_int("running"))
            meta:set_int("running", 0)
            return power_needed, false
        else
            meta:set_int("prev_state", meta:get_int("running"))
            meta:set_int("running", 1)
        end
    end

    local working_label = ""
    if run then
        working_label = "Running"
    else
        working_label = "Idle"
    end
    if perpetual then
        working_label = working_label .. "(Perpetual)"
    end

    meta:set_string("infotext", working_label)

    if prev_state == 0 and run == 1 then
        core.forceload_block(pos)
    elseif prev_state == 1 and run == 0 then
        core.forceload_free_block(pos)
    end

    return perpetual and 0 or power_needed
end
