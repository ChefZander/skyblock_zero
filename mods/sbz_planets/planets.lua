if not core.global_exists("sbz_api") then
    sbz_api = {
        deg2rad = math.pi / 180,
        rad2deg = 180 / math.pi,
    }
end
sbz_api.planets = {
    types = {},
    ring_size = 100,
}

local function has_rings(type, radius)
    local def = sbz_api.planets.types[type]
    if not def.ring_chance then return false end
    if radius % def.ring_chance == 1 then
        local rand = PcgRandom(radius, { 13452142 })
        return true,
            vector.new(rand:next(0, 360) * sbz_api.deg2rad, rand:next(0, 360) * sbz_api.deg2rad, 0)
        -- yes i knowww im using the radius as a seed... proabbly shouldnt xD
    end
    return false, 0
end
sbz_api.planets.has_rings = has_rings

local planets = sbz_api.planets
function sbz_api.planets.register_type(data)
    planets.types[#planets.types + 1] = data
end

local MP = core.get_modpath("sbz_planets")
dofile(MP .. "/planet_types.lua")
if core.global_exists("in_normal_environment") then
    dofile(MP .. "/pre_generate_planets.lua")
end
