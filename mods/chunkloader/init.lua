chunkloader = {}
chunkloader.modpath = core.get_modpath("chunkloader")
chunkloader.version = "1.0"

function chunkloader.dofile(filename)
    dofile(chunkloader.modpath .. DIR_DELIM .. filename .. ".lua")
end

chunkloader.dofile("utils")
chunkloader.dofile("logic")
chunkloader.dofile("chunkloader")
chunkloader.dofile("perpetual_chunkloader")
chunkloader.dofile("crafting")

chunkloader.log("Ready!")
