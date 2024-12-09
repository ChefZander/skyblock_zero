function sbz_api.get_node_heat(pos)
    return minetest.get_node_light(pos) or 0 --placeholder
end

function sbz_api.is_sky_exposed(pos)
    --[[
    local dir = vector.random_direction()
    dir.y = math.abs(dir.y) --not downwards
    local ray = minetest.raycast(pos, pos + 200 * dir, false, true)
    for pointed in ray do
        if pointed.type == "node" then
            local node = minetest.get_node(pointed.under)
            if minetest.get_item_group(node.name, "transparent") == 0 then return false end
        end
    end
    return true
    --]]
    return true -- i think this is just stupid, why would they need to be exposed to the sky, for what? the sun? we dont have that here theidealist....
end

function sbz_api.is_hydrated(pos)
    pos = pos - vector.new(0, 1, 0)
    return is_node_within_radius(pos, "group:water", 2)
end

local modpath = minetest.get_modpath("sbz_bio")
dofile(modpath .. "/moss.lua")
dofile(modpath .. "/soil.lua")
dofile(modpath .. "/habitat.lua")
dofile(modpath .. "/fire.lua")
dofile(modpath .. "/plants.lua")
dofile(modpath .. "/misc.lua")
dofile(modpath .. "/uses.lua")
dofile(modpath .. "/potions.lua")
dofile(modpath .. "/lsystem.lua")
dofile(modpath .. "/trees.lua")
