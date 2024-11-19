local modules = {}
for _, file in pairs{
	"schema",
	"file",
	"func",
	"less_than",
	"iterator",
	"math",
	"table",
	"vararg",
	"text",
	"utf8",
	"vector",
	"matrix4",
	"quaternion",
	"trie",
	"kdtree",
	"hashlist",
	"hashheap",
	"heap",
	"binary",
	"b3d",
	"json",
	"luon",
	"bluon",
	"base64",
	"persistence",
	"debug",
	"web",
	"tex"
} do
	modules[file] = file
end
if minetest then
	modules.minetest = "minetest"
end

-- modlib.mod is an alias for modlib.minetest.mod
modules.string = "text"
modules.number = "math"

local parent_dir
if not minetest then
	-- TOFIX
	local init_path = arg and arg[0]
	parent_dir = init_path and init_path:match"^.[/\\]" or ""
end

local dir_delim = rawget(_G, "DIR_DELIM") -- Minetest
	or (rawget(_G, "package") and package.config and assert(package.config:match("^(.-)[\r\n]"))) or "/"

local function concat_path(path)
	return table.concat(path, dir_delim)
end

-- only used if Minetest is available
local function get_resource(modname, resource, ...)
	if not resource then
		resource = modname
		modname = minetest.get_current_modname()
	end
	return concat_path{minetest.get_modpath(modname), resource, ...}
end

local function load_module(self, module_name_or_alias)
	local module_name = modules[module_name_or_alias]
	if not module_name then
		-- no such module
		return
	end
	local environment
	if module_name ~= module_name_or_alias then
		-- alias handling
		environment = self[module_name]
	else
		environment = dofile(minetest
			and get_resource(self.modname, module_name .. ".lua")
			or (parent_dir .. module_name .. ".lua"))
	end
	self[module_name_or_alias] = environment
	return environment
end

local rawget, rawset = rawget, rawset
modlib = setmetatable({}, { __index = load_module })

-- TODO bump on release
modlib.version = 102

if minetest then
	modlib.modname = minetest.get_current_modname()
end

-- Raw globals
modlib._RG = setmetatable({}, {
	__index = function(_, index)
		return rawget(_G, index)
	end,
	__newindex = function(_, index, value)
		return rawset(_G, index, value)
	end
})

-- Globals merged with modlib
modlib.G = setmetatable({}, {__index = function(self, module_name)
	local module = load_module(self, module_name)
	if module == nil then
		return _G[module_name]
	end
	if _G[module_name] then
		setmetatable(module, {__index = _G[module_name]})
	end
	return module
end})

-- "Imports" modlib by changing the environment of the calling function
--! This alters environments at the expense of performance. Use with caution.
--! Prefer localizing modlib library functions or API tables if possible.
function modlib.set_environment()
	setfenv(2, setmetatable({}, {__index = modlib.G}))
end

-- Force load file module to pass dir_delim & to set concat_path
modlib.file = assert(loadfile(get_resource"file.lua"))(dir_delim)
modlib.file.concat_path = concat_path

if minetest then
	-- Force-loading of the minetest & mod modules
	-- Also sets modlib.mod -> modlib.minetest.mod alias.
	local ml_mt = modlib.minetest
	ml_mt.mod.get_resource = get_resource
	modlib.mod = ml_mt.mod
	-- HACK force load minetest/gametime.lua to ensure that the globalstep is registered earlier than globalsteps of mods depending on modlib
	dofile(get_resource(modlib.modname, "minetest", "gametime.lua"))
	local ie = minetest.request_insecure_environment()
	if ie then
		-- Force load persistence namespace to pass insecure require
		-- TODO currently no need to set _G.require, lsqlite3 loads no dependencies that way
		modlib.persistence = assert(loadfile(get_resource"persistence.lua"))(ie.require)
	end
end

-- Run build scripts
-- dofile(modlib.mod.get_resource("modlib", "build", "html_entities.lua"))

-- TODO verify localizations suffice
return modlib
