local MP = minetest.get_modpath("jumpdrive")

local has_locator_mod = minetest.get_modpath("locator")
local has_pipeworks_mod = minetest.get_modpath("pipeworks")
local has_sethome_mod = minetest.get_modpath("sethome")
local has_areas_mod = minetest.get_modpath("areas")

if minetest.get_modpath("travelnet") then
    dofile(MP .. "/compat/travelnet.lua")
end

if has_areas_mod then
    dofile(MP .. "/compat/areas.lua")
end

if has_sethome_mod then
    dofile(MP .. "/compat/sethome.lua")
end

if has_pipeworks_mod then
    dofile(MP .. "/compat/teleporttube.lua")
end

jumpdrive.node_compat = function(name, source_pos, target_pos, source_pos1, source_pos2, delta_vector)
    if has_pipeworks_mod and string.find(name, "^pipeworks:teleport_tube") then
        jumpdrive.teleporttube_compat(source_pos, target_pos)
    end
end

jumpdrive.commit_node_compat = function()
    -- Nothing to do here
end


jumpdrive.target_region_compat = function(_, _, target_pos1, target_pos2, delta_vector)
    -- sync compat functions
end
