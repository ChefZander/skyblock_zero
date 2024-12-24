-- THE MAPGEN OF SKYBLOCK ZERO
-- cave generation is the largest problem somehow???

-- from lvm_example
core.set_mapgen_setting("mg_name", "singlenode", true)
core.set_mapgen_setting("mg_flags", "nolight", true)

core.register_alias("mapgen_stone", "sbz_resources:stone")
core.register_alias("mapgen_water_source", "sbz_resources:water_source")
core.register_alias("mapgen_river_water_source", "sbz_resources:water_source")

dofile(core.get_modpath("sbz_planets") .. "/planets.lua")
dofile(core.get_modpath("sbz_planets") .. "/biomes.lua")
dofile(core.get_modpath("sbz_planets") .. "/player_manager.lua")

local c = core.get_content_id

local c_core = c("sbz_resources:the_core")

local planets = sbz_api.planets

local noises = {
    ["shape"] = {
        np = {
            offset = 0,
            scale = 20,
            spread = { x = 238, y = 238, z = 238 },
            seed = 5900033,
            octaves = 6,
            persist = 0.7,
            lacunarity = 2,
            --flags = ""
        },
        noise = {},

    },

    -- cave1 and cave2 noises are from https://github.com/gaelysam/valleys_mapgen/blob/9a672a7a2beca2baf9f4bc99a1fb2707c02a90f7/mapgen.lua#L532
    ["cave1"] = {
        np = {
            offset = 0,
            scale = 1,
            seed = -8402,
            spread = { x = 64, y = 64, z = 64 },
            octaves = 3,
            persist = 0.5,
            lacunarity = 2
        },
        noise = {}
    },
    ["cave2"] = {
        np = {
            offset = 0,
            scale = 1,
            seed = 3944,
            spread = { x = 64, y = 64, z = 64 },
            octaves = 3,
            persist = 0.5,
            lacunarity = 2
        },
        noise = {},
    }
}

local data = {}

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = core.get_mapgen_object("voxelmanip")
    vm:get_data(data)
    local area = VoxelArea:new { MinEdge = emin, MaxEdge = emax }

    if area:contains(0, 0, 0) then
        data[area:index(0, 0, 0)] = c_core
    end

    -- do the noise!!
    local sidelen = maxp.x - minp.x + 1
    local sidelen_vec = vector.new(sidelen, sidelen, sidelen)
    for name, def in pairs(noises) do
        def.map = def.map or core.get_perlin_map(def.np, sidelen_vec)
        def.map:get_3d_map_flat(minp, def.noise)
    end

    -- ok noww.... generate the PLANETS!!!!!.... crap...

    local planets_in_area = planets.area:get_areas_in_area(minp, maxp, true, true, true)

    for _, planet in pairs(planets_in_area) do
        local center = (vector.subtract(planet.max, planet.min) / 2) + planet.min
        local pdata = core.deserialize(planet.data)
        local ptype = pdata[1]
        local ptype_def = planets.types[ptype]
        ptype_def.mapgen(area, minp, maxp, seed, noises, data, pdata, center)
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
