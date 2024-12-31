-- yipee
-- TODO: FOR LATER: ADD PROBABILITIES SO P(STAR) ~= P(DWARF PLANET);

--[[
    Types:

    PLANET TYPE - think of <real/fake world example>

    Dwarf planet - pluto
    Dead planet - mercury/mars
    Water planet - earth
    Ice planet - 'anus/neptune
    Deadly planet - venus
    Star - Sun
    Neutron star - couple of blocks of neutronium, and a neutronium orb at the center
      - they would have immense gravity
    Black holes - theidealist *really* wanted to make those
    White dwarfs - maybe? dont know what they would be lmfao
    ]]

--[[
Rock ideas:

dwarfs:
    - regular stone+caves+randomly distributed dwarf orb+shape noise

dead planets:
    Crust:
       - Red Sand
       - Sand
       - Limestone
       - Marble
       - Basalt
       - Red Stone
       - Granite
       - Shape noise
       - Mountains - it's okay to use 3D noise for 2D things...
       - 1/10 chance of having rings
    Core:
       - Liquid Iron (flowing)
       - Liquid Nickel (flowing)
       - Dead Core (not flowing)

Where liquid chemicals would be registered in sbz_chem
]]

local c = core.get_content_id

local c_stone = c("mapgen_stone")
local c_dwarf = c("sbz_planets:dwarf_stone")
local c_air = c("air")
local c_dead_core = c("sbz_planets:dead_core")
local c_nickel_fluid = c("sbz_chem:nickel_fluid_source")
local c_iron_fluid = c("sbz_chem:iron_fluid_source")
local c_red_sand = c("sbz_planets:red_sand_nofall")
local c_sand = c("sbz_planets:sand_nofall")
local c_gravel = c("sbz_planets:gravel_nofall")
local c_white_sand = c("sbz_planets:white_sand_nofall")
local c_dark_sand = c("sbz_planets:dark_sand_nofall")
local c_black_sand = c("sbz_planets:black_sand_nofall")

local c_red_stone = c("sbz_planets:red_stone")
local c_basalt = c("sbz_planets:basalt")
local c_marble = c("sbz_planets:marble")
local c_granite = c("sbz_planets:granite")

local has_rings = sbz_api.planets.has_rings

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
    ring_chance = 10, -- 1 in 10
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
            if stone_type_noise[ni] > 0.25 then
                if noise > 0.25 then
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
