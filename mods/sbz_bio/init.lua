function sbz_api.get_node_heat(pos)
    return minetest.get_node_light(pos) --placeholder
end

local modpath = minetest.get_modpath("sbz_bio")
dofile(modpath.."/moss.lua")
dofile(modpath.."/habitat.lua")
dofile(modpath.."/plants.lua")