-- THE MAPGEN OF SKYBLOCK ZERO
-- cave generation is the largest problem somehow???

-- from lvm_example
core.log('action', 'Loading planets')
core.set_mapgen_setting('mg_name', 'singlenode', true)
core.set_mapgen_setting('mg_flags', 'nolight', true)

core.register_alias('mapgen_stone', 'sbz_resources:stone')
core.register_alias('mapgen_water_source', 'sbz_resources:water_source')
core.register_alias('mapgen_river_water_source', 'sbz_resources:water_source')

local mp = core.get_modpath 'sbz_planets'

in_normal_environment = true

dofile(mp .. '/biomes.lua')
dofile(mp .. '/planet_nodes.lua')
dofile(mp .. '/orbs.lua')
dofile(mp .. '/player_manager.lua')

dofile(mp .. '/planets.lua')
core.register_mapgen_script(mp .. '/planets.lua')
core.register_mapgen_script(mp .. '/mapgen.lua')
dofile(mp .. '/planet_teleporter.lua')

local planets = sbz_api.planets

-- Use in worldedit
-- Like getplanet(5), or getplanet(0, sbz_api.has_rings)
function getplanet(id, filter)
    local a = sbz_api.planets.area
    local area = a:get_area(id, true, true)
    if not area then return core.debug 'not found' end
    local deserialized_data = core.deserialize(area.data)
    if filter then
        if filter(unpack(deserialized_data)) == false then
            if id + 1 == sbz_api.num_planets then return core.debug 'Not found' end
            return getplanet(id + 1, filter)
        end
    end
    core.debug(
        ([[
id:%s
center: %s
min: %s
max: %s
data: %s
type: %s
rings: %s
    ]]):format(
            id,
            vector.to_string((vector.subtract(area.max, area.min) / 2) + area.min),
            area.min,
            area.max,
            area.data,
            planets.types[deserialized_data[1]].name,
            dump { sbz_api.planets.has_rings(deserialized_data[1], deserialized_data[2]) }
        )
    )
end

core.log('action', 'Finished loading planets')
