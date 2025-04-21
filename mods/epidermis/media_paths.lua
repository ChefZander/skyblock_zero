local media_paths = modlib.minetest.media.paths

local dynamic_media_paths = {}
-- HACK override dynamic_add_media to capture the paths
-- Too invasive to be part of modlib
local dynamic_add_media = minetest.dynamic_add_media
function minetest.dynamic_add_media(options_or_filepath, callback)
	local filepath = options_or_filepath
	if type(filepath) ~= "string" then
		filepath = assert(options_or_filepath.filepath)
	end
	dynamic_media_paths[assert(modlib.file.get_name(filepath))] = filepath
	return dynamic_add_media(options_or_filepath, callback)
end
setmetatable(media_paths, {__index = dynamic_media_paths})

epidermis.media_paths = media_paths