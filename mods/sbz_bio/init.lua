function sbz_api.get_node_heat(pos)
    return minetest.get_node_light(pos)
end

local modpath = minetest.get_modpath("sbz_bio")
dofile(modpath.."/moss.lua")