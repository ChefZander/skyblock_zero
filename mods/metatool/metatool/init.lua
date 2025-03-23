--[[
	Metatool provides API to register tools used for
	manipulating node metadata through copy/paste methods.

	Template configuration file can be generated using default
	settings by setting `export_default_config` to `true`.
	This causes configuration parser to write default configuration
	into file specified by `metatool.configuration_file` key.

	Configuration file is never written by metatool mod unless
	`metatool.export_default_config` is set to `true`.
--]]

-- initialize namespace and core functions
metatool = {
	configuration_file = minetest.get_worldpath() .. '/metatool.cfg',
	export_default_config = minetest.settings:get_bool("metatool_export_default_config", true),
	modpath = minetest.get_modpath('metatool'),
	S = string.format
}
dofile(metatool.modpath .. '/util.lua')
dofile(metatool.modpath .. '/settings.lua')
dofile(metatool.modpath .. '/api.lua')
dofile(metatool.modpath .. '/command.lua')
dofile(metatool.modpath .. '/formspec.lua')

print('[OK] MetaTool loaded')
