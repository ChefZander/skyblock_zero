core.log("action", "Generating planets!")
local planets = sbz_api.planets
planets.area = AreaStore()

if not (core.global_exists("mtt") and mtt.enabled) then
    local has_rings = sbz_api.planets.has_rings
    local num_planets = 1000

    local y_min = 2000
    local y_max = 10000
    local mapgen_limit = 31000
    local area = planets.area

    area:reserve(num_planets)

    local random = PcgRandom(core.get_mapgen_setting("seed"))

    for _ = 1, num_planets do
        local pos1, pos2, center, areas_result
        local planet_type = random:next(1, #planets.types)
        local planet_def = planets.types[planet_type]

        local radius = random:next(planet_def.radius.min, planet_def.radius.max)

        repeat
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

core.ipc_set("sbz_planets:store", planets.area:to_string())
core.log("action", "Finished generating planets!")
