core.log("action", "Generating planets!")
local t0 = os.clock()
local planets = sbz_api.planets
planets.area = AreaStore()
planets.num_planets = 0


local tries = 0
if not (core.global_exists("mtt") and mtt.enabled) then
    local has_rings = sbz_api.planets.has_rings

    for _, planet_def in pairs(planets.types) do
        planets.num_planets = planets.num_planets + planet_def.num_planets
    end

    local y_min = 2000
    local y_max = 20000
    local mapgen_limit = 31000
    local area = planets.area

    area:reserve(planets.num_planets) -- Improves performance, cost: 4us
    local random = PcgRandom(core.get_mapgen_setting("seed"))

    for planet_type, planet_def in pairs(planets.types) do
        for _ = 1, planet_def.num_planets do
            local pos1, pos2, center, areas_result

            local radius = random:next(planet_def.radius.min, planet_def.radius.max)

            repeat
                tries = tries + 1
                center = vector.new(random:next(0, mapgen_limit), random:next(y_min, y_max), random:next(0, mapgen_limit))

                local size = radius
                if has_rings(planet_type, radius) then
                    size = size + (size + planets.ring_size + 10)
                end

                pos1 = center - vector.new(size, size, size)
                pos2 = center + vector.new(size, size, size)
                areas_result = area:get_areas_in_area(pos1, pos2, true, false, false)
            until areas_result == nil or next(areas_result) == nil
            area:insert_area(pos1, pos2, core.serialize { planet_type, radius })
        end
    end
end

core.ipc_set("sbz_planets:store", planets.area:to_string())
core.log("action",
    ("Finished generating planets! Took %s seconds. Generated %s planets. Took %s attempts."):format(os.clock() - t0,
        planets.num_planets, tries))
