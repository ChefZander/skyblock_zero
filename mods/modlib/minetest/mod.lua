-- Localize globals
local Settings, _G, assert, dofile, error, getmetatable, ipairs, loadfile, loadstring, minetest, modlib, pairs, rawget, rawset, setfenv, setmetatable, tonumber, type, table_concat, unpack
	= Settings, _G, assert, dofile, error, getmetatable, ipairs, loadfile, loadstring, minetest, modlib, pairs, rawget, rawset, setfenv, setmetatable, tonumber, type, table.concat, unpack

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

local loaded = {}
function require(filename)
	local modname = minetest.get_current_modname()
	loaded[modname] = loaded[modname] or {}
	-- Minetest ensures that `/` works even on Windows (path normalization)
	loaded[modname][filename] = loaded[modname][filename] -- already loaded?
		or dofile(minetest.get_modpath(modname) .. "/" .. filename:gsub("%.", "/") .. ".lua")
	return loaded[modname][filename]
end

function loadfile_exports(filename)
	local env = setmetatable({}, {__index = _G})
	local file = assert(loadfile(filename))
	setfenv(file, env)
	file()
	return env
end

-- get resource + dofile
function include(modname, file)
	if not file then
		file = modname
		modname = minetest.get_current_modname()
	end
	return dofile(get_resource(modname, file))
end

function include_env(file_or_string, env, is_string)
	setfenv(assert((is_string and loadstring or loadfile)(file_or_string)), env)()
end

function create_namespace(namespace_name, parent_namespace)
	namespace_name = namespace_name or minetest.get_current_modname()
	parent_namespace = parent_namespace or _G
	local metatable = {__index = parent_namespace == _G and function(_, key) return rawget(_G, key) end or parent_namespace}
	local namespace = {}
	namespace = setmetatable(namespace, metatable)
	if parent_namespace == _G then
		rawset(parent_namespace, namespace_name, namespace)
	else
		parent_namespace[namespace_name] = namespace
	end
	return namespace
end

-- formerly extend_mod
function extend(modname, file)
	if not file then
		file = modname
		modname = minetest.get_current_modname()
	end
	include_env(get_resource(modname, file .. ".lua"), rawget(_G, modname))
end

-- runs main.lua in table env
-- formerly include_mod
function init(modname)
	modname = modname or minetest.get_current_modname()
	create_namespace(modname)
	extend(modname, "main")
end

-- TODO `require` relative to current mod

local warn_parent_leaf = "modlib: setting %s used both as parent setting and as leaf, ignoring children"
local function build_tree(dict)
	local tree = {}
	for key, value in pairs(dict) do
		local path = modlib.text.split_unlimited(key, ".", true)
		local subtree = tree
		for i = 1, #path - 1 do
			local index = tonumber(path[i]) or path[i]
			subtree[index] = subtree[index] or {}
			subtree = subtree[index]
			if type(subtree) ~= "table" then
				minetest.log("warning", warn_parent_leaf:format(table_concat({unpack(path, 1, i)}, ".")))
				break
			end
		end
		if type(subtree) == "table" then
			if type(subtree[path[#path]]) == "table" then
				minetest.log("warning", warn_parent_leaf:format(key))
			end
			subtree[path[#path]] = value
		end
	end
	return tree
end

settings = build_tree(minetest.settings:to_table())

--> conf, schema
function configuration(modname)
	modname = modname or minetest.get_current_modname()
	local schema = modlib.schema.new(assert(include(modname, "schema.lua")))
	schema.name = schema.name or modname
	local settingtypes = schema:generate_settingtypes()
	assert(schema.type == "table")
	local overrides = {}
	local conf
	local function add(path)
		for _, format in ipairs{
			{extension = "lua", read = function(text)
				assert(overrides._C == nil)
				local additions =  setfenv(assert(loadstring(text)), setmetatable(overrides, {__index = {_C = overrides}}))()
				setmetatable(overrides, nil)
				if additions == nil then
					return overrides
				end
				return additions
			end},
			{extension = "luon", read = function(text)
				local value = {setfenv(assert(loadstring("return " .. text)), setmetatable(overrides, {}))()}
				assert(#value == 1)
				value = value[1]
				local function check_type(value)
					local type = type(value)
					if type == "table" then
						assert(getmetatable(value) == nil)
						for key, value in pairs(value) do
							check_type(key)
							check_type(value)
						end
					elseif not (type == "boolean" or type == "number" or type == "string") then
						error("disallowed type " .. type)
					end
				end
				check_type(value)
				return value
			end},
			{extension = "conf", read = function(text)
				return build_tree(Settings(text):to_table())
			end, convert_strings = true},
			{extension = "json", read = minetest.parse_json}
		} do
			local content = modlib.file.read(path .. "." .. format.extension)
			if content then
				overrides = modlib.table.deep_add_all(overrides, format.read(content))
				conf = schema:load(overrides, {convert_strings = format.convert_strings, error_message = true})
			end
		end
	end
	add(minetest.get_worldpath() .. "/conf/" .. modname)
	add(get_resource(modname, "conf"))
	local minetest_conf = settings[schema.name]
	if minetest_conf then
		overrides = modlib.table.deep_add_all(overrides, minetest_conf)
		conf = schema:load(overrides, {convert_strings = true, error_message = true})
	end
	modlib.file.ensure_content(get_resource(modname, "settingtypes.txt"), settingtypes)
	local readme_path = get_resource(modname, "Readme.md")
	local readme = modlib.file.read(readme_path)
	if readme then
		local modified = false
		readme = readme:gsub("<!%-%-modlib:conf:(%d)%-%->" .. "(.-)" .. "<!%-%-modlib:conf%-%->", function(level, content)
			schema._md_level = assert(tonumber(level)) + 1
			-- HACK: Newline between comment and heading (MD implementations don't handle comments properly)
			local markdown = "\n" .. schema:generate_markdown()
			if content ~= markdown then
				modified = true
				return "<!--modlib:conf:" .. level .. "-->" .. markdown .. "<!--modlib:conf-->"
			end
		end, 1)
		if modified then
			-- FIXME mod security messes with this (disallows it if enabled)
			assert(modlib.file.write(readme_path, readme))
		end
	end
	if conf == nil then
		return schema:load({}, {error_message = true}), schema
	end
	return conf, schema
end

-- Export environment
return _ENV