mapblockloader.action = function(pos, _, meta, supply, demand)
    local meta = core.get_meta(pos)
    local run = meta:get_int("running") == 1
    local prev_state = meta:get_int("prev_state") == 1
    local owner = meta:get_string("owner")

    local power_needed = 300

    if not mapblockloader.player_online(owner) then
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

local has_vizlib = core.get_modpath("vizlib")

mapblockloader.on_punch = has_vizlib and function(pos, _, player)
    if not player or player:get_wielded_item():get_name() ~= "" then
        -- Only show loaded area when using an empty hand
        return
    end
    local blockpos = {
        x = math.floor(pos.x / core.MAP_BLOCKSIZE),
        y = math.floor(pos.y / core.MAP_BLOCKSIZE),
        z = math.floor(pos.z / core.MAP_BLOCKSIZE)
    }
    local min = {
        x = blockpos.x * core.MAP_BLOCKSIZE - 0.5,
        y = blockpos.y * core.MAP_BLOCKSIZE - 0.5,
        z = blockpos.z * core.MAP_BLOCKSIZE - 0.5,
    }
    local max = {
        x = (blockpos.x + 1) * core.MAP_BLOCKSIZE - 0.5,
        y = (blockpos.y + 1) * core.MAP_BLOCKSIZE - 0.5,
        z = (blockpos.z + 1) * core.MAP_BLOCKSIZE - 0.5
    }
    vizlib.draw_area(min, max, { color = "#00ff00", player = player })
end or nil
