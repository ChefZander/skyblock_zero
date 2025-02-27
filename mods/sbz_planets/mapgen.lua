-- THE MAPGEN THAT EXECUTES CODE FROM planet_types.lua
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
    },

    ["geology"] = {
        np = {
            offset = 0,
            scale = 1,
            seed = 123454,
            spread = { x = 64, y = 64, z = 64 },
            octaves = 2,
            persist = 0.7,
            lacunarity = 2
        },
        noise = {}
    },
    stone_type = {
        np = {
            offset = 0,
            scale = 1,
            seed = 85795789,
            spread = { x = 80, y = 80, z = 80 },
            octaves = 2,
            persist = 0.7,
            lacunarity = 2
        },
        noise = {}
    },
    random = {
        np = {
            offset = 0,
            scale = 1,
            seed = 34512,
            spread = { x = 1, y = 1, z = 1 },
            octaves = 1,
            persist = 0.7,
            lacunarity = 2
        },
        noise = {}
    },
}

local data = {}
local planet_area = AreaStore()
planet_area:from_string(core.ipc_get("sbz_planets:store"))

core.register_on_generated(function(vm, minp, maxp, seed)
    local t0 = os.clock()
    vm:get_data(data)
    local emin, emax = vm:get_emerged_area()
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

    local planets_in_area = planet_area:get_areas_in_area(minp, maxp, true, true, true)

    for _, planet in pairs(planets_in_area) do
        local center = (vector.subtract(planet.max, planet.min) / 2) + planet.min
        local pdata = core.deserialize(planet.data)
        local ptype = pdata[1]
        local ptype_def = planets.types[ptype]
        ptype_def.mapgen(area, minp, maxp, seed, noises, data, pdata, center, vm)
    end

    vm:set_data(data)
    core.generate_ores(vm, minp, maxp)
    vm:calc_lighting()

    --core.debug("Mapgen took: " .. (os.clock() - t0) .. "s")
    -- Average: 1~2 seconds
    -- on frog's laptop, on power save mode
end)
