mapblockloader = {}
mapblockloader.config_path = core.get_worldpath() .. "/mapblockloader.cfg"
mapblockloader.modpath = core.get_modpath("mapblockloader")
mapblockloader.version = "1.0"
mapblockloader.storage = core.get_mod_storage()

function mapblockloader.dofile(filename)
    dofile(mapblockloader.modpath .. DIR_DELIM .. filename .. ".lua")
end

mapblockloader.dofile("utils")
mapblockloader.dofile("logic")
mapblockloader.dofile("mapblockloader")
mapblockloader.dofile("perpetual_mapblockloader")
mapblockloader.dofile("crafting")

if not mapblockloader.config_exists() then
    mapblockloader.create_config()
end

mapblockloader.log("Ready!")
