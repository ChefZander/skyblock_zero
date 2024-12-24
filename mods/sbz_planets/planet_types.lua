-- yipee

local c = core.get_content_id

local c_stone = c("mapgen_stone")
local c_air = c("air")

sbz_api.planets.register_type {
    name = "Dwarf Planet",
    radius = { min = 50, max = 100 },
    gravity = 1,
    light = 2,
    mapgen = function(area, minp, maxp, seed, noises, data, pdata, center)
        local shapenoise = noises.shape.noise
        local cave1noise = noises.cave1.noise
        local cave2noise = noises.cave2.noise
        local prad = pdata[2]
        -- noise index
        local ni = 1
        for z = minp.z, maxp.z do
            for y = minp.y, maxp.y do
                local vi = area:index(minp.x, y, z)
                for x = minp.x, maxp.x do
                    if vector.distance(vector.new(x, y, z), center) <= prad - (shapenoise[ni]) then
                        -- rewriting of https://github.com/gaelysam/valleys_mapgen/blob/9a672a7a2beca2baf9f4bc99a1fb2707c02a90f7/mapgen.lua#L409 i guess(?)
                        local n1, n2 = math.abs(cave1noise[ni]) < 0.07, math.abs(cave2noise[ni]) < 0.07
                        if not (n1 and n2) then
                            data[vi] = c_stone
                        end
                    end

                    vi = vi + 1
                    ni = ni + 1
                end
            end
        end
    end
}

sbz_api.planets.register_type {
    name = "Dead Planet",
    radius = { min = 120, max = 500 },
    gravity = 1,
    light = 6,
    mapgen = function(area, minp, maxp, seed, noises, data, pdata, center)
        local shapenoise = noises.shape.noise
        local cave1noise = noises.cave1.noise
        local cave2noise = noises.cave2.noise
        local prad = pdata[2]
        -- noise index
        local ni = 1
        for z = minp.z, maxp.z do
            for y = minp.y, maxp.y do
                local vi = area:index(minp.x, y, z)
                for x = minp.x, maxp.x do
                    if vector.distance(vector.new(x, y, z), center) <= prad - (shapenoise[ni]) then
                        -- rewriting of https://github.com/gaelysam/valleys_mapgen/blob/9a672a7a2beca2baf9f4bc99a1fb2707c02a90f7/mapgen.lua#L409 i guess(?)
                        data[vi] = c_stone
                        local n1, n2 = math.abs(cave1noise[ni]) < 0.07, math.abs(cave2noise[ni]) < 0.07
                        if (n1 and n2) then
                            data[vi] = c_air
                        end
                    end

                    vi = vi + 1
                    ni = ni + 1
                end
            end
        end
    end
}
--[[
sbz_api.planets.register_type {
    name = "Water Planet",
    radius = { min = 120, max = 500 },
    node = c("mapgen_stone"),
    gravity = 1,
    light = 2,
}

sbz_api.planets.register_type {
    name = "Deadly Planet",
    radius = { min = 90, max = 450 },
    node = c("mapgen_stone"),
    gravity = 1,
    light = 2,
}

sbz_api.planets.register_type {
    name = "Star",
    radius = { min = 500, max = 1000 },
    node = c("mapgen_stone"),
    gravity = 1,
    light = 2,
}
]]
