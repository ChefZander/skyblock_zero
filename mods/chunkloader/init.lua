chunkloader = {}
chunkloader.config_path = core.get_worldpath() .. "/chunkloader.cfg"
chunkloader.modpath = core.get_modpath("chunkloader")
chunkloader.version = "1.0"
chunkloader.storage = core.get_mod_storage()

function chunkloader.dofile(filename)
    dofile(chunkloader.modpath .. DIR_DELIM .. filename .. ".lua")
end

chunkloader.dofile("utils")
chunkloader.dofile("logic")
chunkloader.dofile("chunkloader")
chunkloader.dofile("perpetual_chunkloader")
chunkloader.dofile("crafting")

if not chunkloader.config_exists() then
    chunkloader.create_config()
end

chunkloader.log("Ready!")
