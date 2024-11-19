local minetest, modlib, pairs, ipairs
	= minetest, modlib, pairs, ipairs

-- TODO support for server texture packs (and possibly client TPs in singleplayer?)
local media_foldernames = {"textures", "sounds", "media", "models", "locale"}
local media_extensions = modlib.table.set{
	-- Textures
	"png", "jpg", "bmp", "tga", "pcx", "ppm", "psd", "wal", "rgb";
	-- Sounds
	"ogg";
	-- Models
	"x", "b3d", "md2", "obj";
	-- Translations
	"tr";
}

local function collect_media(modname)
	local media = {}
	local function traverse(folderpath)
		-- Traverse files (collect media)
		local filenames = minetest.get_dir_list(folderpath, false)
		for _, filename in pairs(filenames) do
			local _, ext = modlib.file.get_extension(filename)
			if media_extensions[ext] then
				media[filename] = modlib.file.concat_path{folderpath, filename}
			end
		end
		-- Traverse subfolders
		local foldernames = minetest.get_dir_list(folderpath, true)
		for _, foldername in pairs(foldernames) do
			if not foldername:match"^[_%.]" then -- ignore hidden subfolders / subfolders starting with `_`
				traverse(modlib.file.concat_path{folderpath, foldername})
			end
		end
	end
	for _, foldername in ipairs(media_foldernames) do -- order matters!
		traverse(modlib.mod.get_resource(modname, foldername))
	end
	return media
end

-- TODO clean this up eventually
local paths = {}
local mods = {}
local overridden_paths = {}
local overridden_mods = {}
for _, mod in ipairs(modlib.minetest.get_mod_load_order()) do
	local mod_media = collect_media(mod.name)
	for medianame, path in pairs(mod_media) do
		if paths[medianame] then
			overridden_paths[medianame] = overridden_paths[medianame] or {}
			table.insert(overridden_paths[medianame], paths[medianame])
			overridden_mods[medianame] = overridden_mods[medianame] or {}
			table.insert(overridden_mods[medianame], mods[medianame])
		end
		paths[medianame] = path
		mods[medianame] = mod.name
	end
end

return {paths = paths, mods = mods, overridden_paths = overridden_paths, overridden_mods = overridden_mods}
