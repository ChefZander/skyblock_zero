sbz_api.planets = {
    area = AreaStore(),
    types = {},
}

local planets = sbz_api.planets
function sbz_api.planets.register_type(data)
    planets.types[#planets.types + 1] = data
end

dofile(core.get_modpath("sbz_planets") .. "/planet_types.lua")

local num_planets = 1000

local y_min = 2000
local y_max = 10000
local mapgen_limit = 31000
local area = sbz_api.planets.area

area:reserve(num_planets)

local random = PcgRandom(core.get_mapgen_setting("seed"))
for _ = 1, num_planets do
    local pos1, pos2, center
    local planet_type = random:next(1, #planets.types)
    local planet_def = planets.types[planet_type]

    local radius = random:next(planet_def.radius.min, planet_def.radius.max)

    repeat
        center = vector.new(random:next(0, mapgen_limit), random:next(y_min, y_max), random:next(0, mapgen_limit))

        pos1 = center - vector.new(radius, radius, radius)
        pos2 = center + vector.new(radius, radius, radius)
    until #area:get_areas_in_area(pos1, pos2, false, false, false) == 0
    area:insert_area(pos1, pos2, core.serialize { planet_type, radius })
end
