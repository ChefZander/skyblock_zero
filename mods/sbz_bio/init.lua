function sbz_api.get_node_heat(pos)
    return minetest.get_node_light(pos) --placeholder
end

function sbz_api.is_sky_exposed(pos)
    local dir = vector.random_direction()
    dir.y = math.abs(dir.y) --not downwards
    local ray = minetest.raycast(pos, pos+200*dir, false, true)
    ray:next() --discard itself
    for pointed in ray do
        if pointed.type == "node" then
            local node = minetest.get_node(pointed.under)
            if minetest.get_item_group(node.name, "transparent") == 0 then return false end
        end
    end
    return true
end

function sbz_api.is_hydrated(pos)
    pos = pos-vector.new(0, 1, 0)
    return is_node_within_radius(pos, "sbz_resources:water_source", 1) or is_node_within_radius(pos, "sbz_resources:water_flowing", 1)
end

local modpath = minetest.get_modpath("sbz_bio")
dofile(modpath.."/moss.lua")
dofile(modpath.."/habitat.lua")
dofile(modpath.."/plants.lua")
dofile(modpath.."/misc.lua")