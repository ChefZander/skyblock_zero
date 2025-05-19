-- The PLANET-SPECIFIC MAPGEN FILE!

local c = core.get_content_id

local c_stone = c("mapgen_stone")
local c_dwarf = c("sbz_planets:dwarf_stone")
local c_air = c("air")
local c_dead_core = c("sbz_planets:dead_core")

local c_nickel_fluid = c("sbz_chem:nickel_fluid_source")
local c_iron_fluid = c("sbz_chem:iron_fluid_source")

local c_silicon_fluid = c("sbz_chem:silicon_fluid_source")
local c_cobalt_fluid = c("sbz_chem:cobalt_fluid_source")

local c_red_sand = c("sbz_planets:red_sand_nofall")
local c_sand = c("sbz_planets:sand_nofall")
local c_gravel = c("sbz_planets:gravel_nofall")
local c_white_sand = c("sbz_planets:white_sand_nofall")
local c_dark_sand = c("sbz_planets:dark_sand_nofall")
local c_black_sand = c("sbz_planets:black_sand_nofall")

local c_red_stone = c("sbz_planets:red_stone")
local c_blue_stone = c("sbz_planets:blue_stone")
local c_basalt = c("sbz_planets:basalt")
local c_marble = c("sbz_planets:marble")
local c_granite = c("sbz_planets:granite")

local c_ice_core = c("sbz_resources:movable_emitter")
local c_ice = c("sbz_planets:ice")
local c_snow = c("sbz_planets:snow")
local c_snow_layer = c("sbz_planets:snow_layer")
local c_pyrograss_list = {
    c("sbz_bio:pyrograss_4"),
    c("sbz_bio:pyrograss_1"),
    c("sbz_bio:pyrograss_3"),
    c("sbz_bio:pyrograss_2"),
}

local is_in_pyrograss_list = {
    [c("sbz_bio:pyrograss_4")] = true,
    [c("sbz_bio:pyrograss_1")] = true,
    [c("sbz_bio:pyrograss_3")] = true,
    [c("sbz_bio:pyrograss_2")] = true,
}

local has_rings = sbz_api.planets.has_rings

sbz_api.planets.register_type {
    name = "Dwarf Planet",
    radius = { min = 50, max = 100 },
    gravity = 1,
    light = 2,
    num_planets = 500,
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
                            data[vi] = c_dwarf
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
    ring_chance = 10, -- 1 in 5
    num_planets = 250,
    mapgen = function(area, minp, maxp, seed, noises, data, pdata, center)
        local shapenoise = noises.shape.noise
        local cave1noise = noises.cave1.noise
        local cave2noise = noises.cave2.noise
        local geology_noise = noises.geology.noise
        local stone_type_noise = noises.stone_type.noise
        local random_noise = noises.random.noise
        local prad = pdata[2]
        -- noise index
        local ni = 1
        local vi = 1

        local function rocks(noise)
            if stone_type_noise[ni] >= 0.1 then
                if noise <= 0.1 then
                    return c_stone
                else
                    return c_red_stone
                end
            else
                if noise > 0.25 and stone_type_noise[ni] > 0.2 then
                    return c_basalt
                elseif noise > 0.25 then
                    return c_marble
                else
                    return c_granite
                end
            end
        end


        local function mapgen(x, y, z)
            local xyzvec = vector.new(x, y, z)
            local dist_to_center = vector.distance(xyzvec, center)
            if dist_to_center <= prad - (shapenoise[ni] * 1.1) then
                -- rewriting of https://github.com/gaelysam/valleys_mapgen/blob/9a672a7a2beca2baf9f4bc99a1fb2707c02a90f7/mapgen.lua#L409 i guess(?)
                data[vi] = c_stone
                local n1, n2 = math.abs(cave1noise[ni]) < 0.07, math.abs(cave2noise[ni]) < 0.07
                if (n1 and n2) and not (dist_to_center <= (prad / 4.5)) then
                    data[vi] = c_air
                end

                if data[vi] == c_stone then
                    -- do the geology stuff
                    -- THE CORE
                    if dist_to_center <= prad / 5 then
                        if dist_to_center <= prad / 8 then   -- Dead core
                            data[vi] = c_dead_core
                        elseif geology_noise[ni] > 0.35 then -- nickel
                            data[vi] = c_nickel_fluid
                        else
                            data[vi] = c_iron_fluid
                        end
                    elseif dist_to_center >= prad - 21 and dist_to_center <= prad + 20 then -- surface, not mountains
                        if geology_noise[ni] > 0.6 then                                     -- normal sand
                            data[vi] = c_sand
                        elseif geology_noise[ni] > 0.3 then                                 -- gravel
                            data[vi] = c_gravel
                        elseif geology_noise[ni] > 0.1 then                                 -- sand shades
                            if geology_noise[ni] > 0.2 then
                                data[vi] = c_white_sand
                            elseif geology_noise[ni] > 0.15 then
                                data[vi] = c_dark_sand
                            else
                                data[vi] = c_black_sand
                            end
                        else -- red sand
                            data[vi] = c_red_sand
                        end
                    else
                        data[vi] = rocks(geology_noise[ni])
                    end
                end
            end
        end

        local should_have_rings, angles = has_rings(pdata[1], pdata[2])

        local rrad = prad + sbz_api.planets.ring_size
        local width = math.max(10, math.floor(prad / 50))
        rrad = rrad - (width + 1)

        for z = minp.z, maxp.z do
            for y = minp.y, maxp.y do
                vi = area:index(minp.x, y, z)
                for x = minp.x, maxp.x do
                    local v = vector.new(x, y, z)
                    local dist = vector.distance(v, center)
                    mapgen(x, y, z)
                    if should_have_rings and dist >= (rrad - (width + 5)) and dist <= (rrad + width + 5) and random_noise[ni] > 0.95 then
                        -- very simple, just gravel

                        -- ok now the math is not so simple... crap...
                        v = vector.add(center, vector.rotate(vector.subtract(v, center), angles))
                        if (math.sqrt((v.x - center.x) ^ 2 + (v.y - center.y) ^ 2) - rrad) ^ 2 + (v.z - center.z) ^ 2 <= width ^ 2 then
                            data[vi] = c_gravel
                        end
                    end
                    vi = vi + 1
                    ni = ni + 1
                end
            end
        end
    end
}

local param2_data = {}
sbz_api.planets.register_type {
    name = "Ice Planet",
    radius = { min = 80, max = 420 },
    gravity = 1,
    light = 8,
    ring_chance = 3, -- 1 in 3
    num_planets = 250,
    mapgen = function(area, minp, maxp, seed, noises, data, pdata, center, vm)
        local shapenoise = noises.shape.noise
        local cave1noise = noises.cave1.noise
        local cave2noise = noises.cave2.noise
        local geology_noise = noises.geology.noise
        local stone_type_noise = noises.stone_type.noise
        local random_noise = noises.random.noise
        local prad = pdata[2]
        -- noise index
        local ni = 1
        local vi = 1

        local function rocks(noise)
            if stone_type_noise[ni] > 0.1 then
                if noise < 0.1 then
                    return c_stone
                else
                    return c_blue_stone
                end
            else
                if noise > 0.25 and stone_type_noise[ni] > 0.2 then
                    return c_basalt
                elseif noise > 0.25 then
                    return c_marble
                else
                    return c_granite
                end
            end
        end


        local function mapgen(x, y, z)
            local xyzvec = vector.new(x, y, z)
            local dist_to_center = vector.distance(xyzvec, center)
            local radius_value = prad - (shapenoise[ni] * 0.5)

            if dist_to_center <= radius_value then
                -- rewriting of https://github.com/gaelysam/valleys_mapgen/blob/9a672a7a2beca2baf9f4bc99a1fb2707c02a90f7/mapgen.lua#L409 i guess(?)
                data[vi] = c_stone
                local n1, n2 = math.abs(cave1noise[ni]) < 0.07, math.abs(cave2noise[ni]) < 0.07
                if (n1 and n2) and not (dist_to_center <= (prad / 4.5)) then
                    data[vi] = c_air
                end

                if data[vi] == c_stone then
                    -- do the geology stuff
                    -- THE CORE
                    if dist_to_center <= prad / 4.5 then
                        if dist_to_center <= prad / 7 then   -- Ice core
                            data[vi] = c_ice_core
                        elseif geology_noise[ni] > 0.35 then -- nickel
                            data[vi] = c_silicon_fluid
                        else
                            data[vi] = c_cobalt_fluid
                        end
                    elseif dist_to_center >= prad - 21 and dist_to_center <= prad + 20 then -- surface, not mountains
                        if geology_noise[ni] < 0.4 and stone_type_noise[ni] > 0.4 then      -- gravel
                            data[vi] = c_gravel
                        elseif geology_noise[ni] > 0.4 then                                 -- ice
                            data[vi] = c_ice
                        else
                            if dist_to_center >= radius_value - 5 then
                                data[vi] = c_snow
                            else
                                data[vi] = c_ice
                            end
                        end
                    else
                        data[vi] = rocks(geology_noise[ni])
                    end
                end
            end
        end

        local should_have_rings, angles = has_rings(pdata[1], pdata[2])

        local rrad = prad + sbz_api.planets.ring_size
        local width = math.max(10, math.floor(prad / 50))
        rrad = rrad - (width + 1)

        for z = minp.z, maxp.z do
            for y = minp.y, maxp.y do
                vi = area:index(minp.x, y, z)
                for x = minp.x, maxp.x do
                    local v = vector.new(x, y, z)
                    local dist = vector.distance(v, center)
                    mapgen(x, y, z)
                    if should_have_rings and dist >= (rrad - (width + 5)) and dist <= (rrad + width + 5) and random_noise[ni] > 0.95 then
                        -- very simple, just gravel

                        -- ok now the math is not so simple... crap...
                        v = vector.add(center, vector.rotate(vector.subtract(v, center), angles))
                        if (math.sqrt((v.x - center.x) ^ 2 + (v.y - center.y) ^ 2) - rrad) ^ 2 + (v.z - center.z) ^ 2 <= width ^ 2 then
                            data[vi] = c_gravel
                        end
                    end
                    vi = vi + 1
                    ni = ni + 1
                end
            end
        end


        vm:get_param2_data(param2_data)
        -- now... spawning the snow will be hard...
        local sidelen = maxp.x - minp.x + 1
        for z = minp.z, maxp.z do
            for x = minp.x, maxp.x do
                for y = maxp.y - 1, minp.y, -1 do
                    ni = math.abs(z - minp.z - 1) * sidelen ^ 2 + math.abs(y - minp.y - 1) * sidelen +
                        math.abs(x - minp.x)
                    vi = area:index(x, y, z)
                    local node = data[vi]

                    if node ~= c_air and shapenoise[ni] ~= nil then
                        local xyzvec = vector.new(x, y, z)
                        local dist_to_center = vector.distance(xyzvec, center)
                        local radius_value = prad - (shapenoise[ni] * 0.5)
                        if random_noise[ni] > 0.4 then
                            if dist_to_center >= radius_value - 0.5 and dist_to_center <= radius_value + 0.5 then
                                vi = area:index(x, y + 1, z)
                                data[vi] = c_snow_layer
                                param2_data[vi] = 1
                            end
                        end
                        break
                    end
                end
            end
        end
        vm:set_param2_data(param2_data)
    end
}

local c_colorium_core = c("sbz_bio:colorium_emitter")
local c_water = c("sbz_planets:water_source_nofall")
local c_pyrograss_dirt = c("sbz_bio:dirt_with_grass")
local c_dirt = c("sbz_bio:dirt")
local c_sapling = c("sbz_planets:colorium_mapgen_sapling")


sbz_api.planets.register_type {
    name = "Colorium Planet",
    radius = { min = 600, max = 800 },
    gravity = 1,
    light = 12,
    ring_chance = 12,
    invert_chance = 25, -- 1 in 25.. so 4%
    num_planets = 300,
    mapgen = function(area, minp, maxp, seed, noises, data, pdata, center)
        local shapenoise = noises.shape.noise
        local cave1noise = noises.cave1.noise
        local cave2noise = noises.cave2.noise
        local geology_noise = noises.geology.noise
        local stone_type_noise = noises.stone_type.noise
        local random_noise = noises.random.noise
        local prad = pdata[2]
        -- noise index
        local ni = 1
        local vi = 1

        local function rocks(noise)
            if stone_type_noise[ni] > 0.1 then
                if noise < 0.1 then
                    return c_stone
                else
                    return c_red_stone
                end
            else
                if noise > 0.25 and stone_type_noise[ni] > 0.2 then
                    return c_basalt
                elseif noise > 0.25 then
                    return c_marble
                else
                    return c_granite
                end
            end
        end


        local function mapgen(x, y, z)
            local xyzvec = vector.new(x, y, z)
            local dist_to_center = vector.distance(xyzvec, center)
            if dist_to_center <= prad - (shapenoise[ni] * 1.1) then
                -- rewriting of https://github.com/gaelysam/valleys_mapgen/blob/9a672a7a2beca2baf9f4bc99a1fb2707c02a90f7/mapgen.lua#L409 i guess(?)
                data[vi] = c_stone
                local n1, n2 = math.abs(cave1noise[ni]) < 0.07, math.abs(cave2noise[ni]) < 0.07
                if (n1 and n2) and not (dist_to_center <= (prad / 4.5)) then
                    data[vi] = c_air
                end

                if data[vi] == c_stone then
                    -- do the geology stuff
                    -- THE CORE
                    if dist_to_center <= prad / 5 then
                        if dist_to_center <= prad / 8 then   -- Dead core
                            data[vi] = c_colorium_core
                        elseif geology_noise[ni] > 0.35 then -- nickel
                            data[vi] = c_nickel_fluid
                        else
                            data[vi] = c_iron_fluid
                        end
                    elseif dist_to_center >= prad - 21 and dist_to_center <= prad + 20 then -- surface, not mountains
                        if dist_to_center <= prad then                                      -- sand level
                            data[vi] = c_sand
                        else                                                                -- land!
                            data[vi] = c_dirt
                        end
                    else
                        data[vi] = rocks(geology_noise[ni])
                    end
                end
            elseif dist_to_center <= prad - 4 then
                data[vi] = c_water
            end
        end

        local should_have_rings, angles = has_rings(pdata[1], pdata[2])

        local rrad = prad + sbz_api.planets.ring_size
        local width = math.max(10, math.floor(prad / 50))
        rrad = rrad - (width + 1)

        for z = minp.z, maxp.z do
            for y = minp.y, maxp.y do
                vi = area:index(minp.x, y, z)
                for x = minp.x, maxp.x do
                    local v = vector.new(x, y, z)
                    local dist = vector.distance(v, center)
                    mapgen(x, y, z)
                    if should_have_rings and dist >= (rrad - (width + 5)) and dist <= (rrad + width + 5) and random_noise[ni] > 0.95 then
                        -- very simple, just gravel

                        -- ok now the math is not so simple... crap...
                        v = vector.add(center, vector.rotate(vector.subtract(v, center), angles))
                        if (math.sqrt((v.x - center.x) ^ 2 + (v.y - center.y) ^ 2) - rrad) ^ 2 + (v.z - center.z) ^ 2 <= width ^ 2 then
                            data[vi] = c_gravel
                        end
                    end
                    vi = vi + 1
                    ni = ni + 1
                end
            end
        end

        -- inspired by what biomegen did
        local sidelen = maxp.x - minp.x + 1
        for z = minp.z, maxp.z do
            for x = minp.x, maxp.x do
                local nplaced = 0
                for y = maxp.y, minp.y - 1, -1 do
                    ni = math.abs(z - minp.z - 1) * sidelen ^ 2 + math.abs(y - minp.y - 1) * sidelen +
                        math.abs(x - minp.x)
                    vi = area:index(x, y, z)
                    local node = data[vi]
                    if node == c_dirt and nplaced < 1 then
                        data[vi] = c_pyrograss_dirt
                        nplaced = nplaced + 1
                    end

                    if node ~= c_air and not is_in_pyrograss_list[node] then
                        nplaced = nplaced + math.huge
                    end
                    if node == c_pyrograss_dirt and nplaced > 1 then
                        data[vi] = c_dirt
                    end
                end
            end
        end


        for z = minp.z, maxp.z do
            for x = minp.x, maxp.x do
                for y = maxp.y, minp.y - 1, -1 do
                    vi = area:index(x, y, z)
                    ni = 1 + math.abs(z - minp.z - 1) * sidelen ^ 2 + math.abs(y - minp.y - 1) * sidelen +
                        math.abs(x - minp.x)

                    if data[vi] == c_pyrograss_dirt and math.abs(random_noise[ni]) < 0.2 then
                        local index
                        local noise = math.abs(random_noise[ni]) / 0.2
                        index = 1 + math.round(noise * 3)
                        data[area:index(x, y + 1, z)] = c_pyrograss_list[index]
                    end

                    if data[vi] == c_pyrograss_dirt and math.abs(random_noise[ni]) > 0.995 then
                        data[area:index(x, y + 1, z)] = c_sapling
                    end

                    if data[vi] ~= c_air then
                        break
                    end
                end
            end
        end
    end
}
