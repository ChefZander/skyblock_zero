local media_paths = modlib.minetest.media.paths

return setmetatable({}, {__index = function(self, texture_name)
	local file = io.open(media_paths[texture_name], "rb")
	local png = modlib.minetest.decode_png(file)
	assert(not file:read(1), "EOF expected")
	file:close()
	modlib.minetest.convert_png_to_argb8(png)
	self[texture_name] = png
	return self[texture_name]
end})
