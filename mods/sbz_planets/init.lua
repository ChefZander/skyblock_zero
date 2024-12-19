-- set up mapgen

-- from lvm_example
core.set_mapgen_setting("mg_name", "singlenode", true)
core.set_mapgen_setting("mg_flags", "nolight", true)

core.register_alias("mapgen_stone", "sbz_resources:stone")
core.register_alias("mapgen_water_source", "sbz_resources:water_source")
core.register_alias("mapgen_river_water_source", "sbz_resources:water_source")

dofile(core.get_modpath("sbz_planets") .. "/planets.lua")
dofile(core.get_modpath("sbz_planets") .. "/biomes.lua")

local c = core.get_content_id

local c_air = c("air")
local c_core = c("sbz_resources:the_core")
local c_emitter = c("sbz_resources:emitter")

local c_stone = c("mapgen_stone")
local c_water = c("mapgen_water_source")

local planets = sbz_api.planets

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local data = vm:get_data()
    local area = VoxelArea:new { MinEdge = emin, MaxEdge = emax }

    local vi = 0
    for z = minp.z, maxp.z do
        for y = minp.y, maxp.y do
            for x = minp.x, maxp.x do
                vi = vi + 1
                data[vi] = c_air
            end
        end
    end

    if minp.x == 0 and minp.y == 0 and minp.z == 0 then
        data[area:index(0, 0, 0)] = c_core
    end


    -- ok noww.... generate the PLANETS!!!!!.... crap...

    local planets_in_area = planets.area:get_areas_in_area(minp, maxp, true, true, true)

    for _, planet in pairs(planets_in_area) do
        local center = (vector.subtract(planet.max, planet.min) / 2) + planet.min
        local pdata = core.deserialize(planet.data)
        -- definitely not named like this so it looks "cool", i definitely couldn't have to call it planet_data, planet_type...
        local ptype = pdata[1]
        local prad = pdata[2]
        local ptype_def = planets.types[ptype]
        local pnode = ptype_def.node

        local vi = 0
        for z = minp.z, maxp.z do
            for y = minp.y, maxp.y do
                for x = minp.x, maxp.x do
                    vi = vi + 1

                    -- x^2 + y^2 + z^2 <= r^2
                    if vector.distance(vector.new(x, y, z), center) <= prad then
                        data[vi] = pnode
                    end
                end
            end
        end
    end

    biomegen.generate_all(data, area, vm, minp, maxp, seed)
    vm:calc_lighting()
    vm:write_to_map()
end)

minetest.register_ore({
    ore_type = "scatter",
    ore = "sbz_resources:emitter",
    wherein = "air",
    clust_scarcity = 80 * 80 * 80,
    clust_num_ores = 1,
    clust_size = 1,
    y_min = -300,
    y_max = 1500,
})


function getplanet(id)
    local a = sbz_api.planets.area
    local area = a:get_area(id, true, true)
    minetest.debug(([[
center: %s
min: %s
max: %s
data: %s
    ]]):format(
        vector.to_string((vector.subtract(area.max, area.min) / 2) + area.min),
        area.min,
        area.max,
        area.data))
end
