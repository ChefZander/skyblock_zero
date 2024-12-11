-- https://github.com/minetest/minetest/blob/master/builtin/settingtypes.txt
-- https://github.com/minetest/minetest/blob/master/builtin/mainmenu/settings/settingtypes.lua

local f = string.format

local function get_lines_from_file(filename)
	local fh = io.open(filename, "r")
	if not fh then
		return
	end
	local lines = fh:read("*all"):split("\n")
	fh:close()
	return lines
end

local function strip_readable_name(text)
	if text:sub(1, 1) ~= "(" then
		error(f("%q %s", text, text))
	end
	local depth = 1
	local i = 2
	while depth > 0 do
		if text:sub(i, i) == ")" then
			depth = depth - 1
		elseif text:sub(i, i) == "(" then
			depth = depth + 1
		end
		i = i + 1
	end
	return text:sub(i):trim()
end

local function starts_with(s, start)
	return s:sub(1, #start) == start
end

local function parse_line(modname, line)
	if line:match("^%s*#") or line:match("^%s*%[") or line:match("^%s*$") then
		return
	end
	line = line:trim()
	local full_name, rest = unpack(line:split("%s+", false, 1, true))
	if not (full_name and rest) then
		return
	end
	local secure = false
	if starts_with(full_name, "secure.") then
		secure = true
		full_name = full_name:sub(#"secure." + 1)
	end
	local modname2, short_name = unpack(full_name:split("[:%.]", false, 1, true))
	assert(modname2 == modname, f("invalid setting name %s", full_name))
	rest = strip_readable_name(rest)
	local datatype, default, params
	datatype, rest = unpack(rest:split("%s", true, 1, true))
	rest = rest or ""
	if datatype == "string" then
		if rest:sub(1, 1) == '"' and rest:sub(#rest, #rest) == '"' then
			-- this is not actually according to spec settingtypes.txt, but there's no good way to specify that the
			-- default value is a single space, so we invent our own syntax
			default = rest:sub(2, #rest - 1)
		elseif rest:sub(1, 2) == '\\"' then
			default = rest:sub(2)
		else
			default = rest
		end
		params = ""
	else
		default, params = unpack(rest:split("%s+", false, 1, true))
	end

	full_name = (secure and "secure." or "") .. full_name
	return full_name, short_name, datatype, default, params
end

local getters = {
	-- TODO there's other setting types, but i don't use them and no-one else uses this mod
	int = function(full_name, default, params)
		return tonumber(minetest.settings:get(full_name)) or tonumber(default)
	end,
	string = function(full_name, default, params)
		return minetest.settings:get(full_name) or default
	end,
	bool = function(full_name, default, params)
		return minetest.settings:get_bool(full_name, minetest.is_yes(default))
	end,
	float = function(full_name, default, params)
		return tonumber(minetest.settings:get(full_name)) or tonumber(default)
	end,
	enum = function(full_name, default, params)
		return minetest.settings:get(full_name) or default
	end,
	path = function(full_name, default, params)
		return minetest.settings:get(full_name) or default or ""
	end,
	filepath = function(full_name, default, params)
		return minetest.settings:get(full_name) or default or ""
	end,
	key = function(full_name, default, params)
		return minetest.settings:get(full_name) or default
	end,
	flags = function(full_name, default, params)
		return (minetest.settings:get(full_name) or default):split()
	end,
	v3f = function(full_name, default, params)
		return minetest.string_to_pos(minetest.settings:get(full_name) or default)
	end,
}

return function(modname)
	local modpath = minetest.get_modpath(modname)
	local settingtypes_lines = get_lines_from_file(modpath .. DIR_DELIM .. "settingtypes.txt")

	if not settingtypes_lines then
		return
	end

	local settings = {}
	for _, line in ipairs(settingtypes_lines) do
		local full_name, short_name, datatype, default, params = parse_line(modname, line)
		if full_name then
			local getter = getters[datatype]
			if getter then
				settings[short_name] = getter(full_name, default, params)
			else
				error("TODO: implement parsing settings of type " .. datatype)
			end
		end
	end

	local listeners_by_key = {}

	return setmetatable({
		_subscribe_for_modification = function(self, key, func)
			local listeners = listeners_by_key[key] or {}
			table.insert(listeners, func)
			listeners_by_key[key] = listeners
		end,
	}, {
		__index = function(self, key)
			return settings[key]
		end,
		__newindex = function(self, key, value)
			settings[key] = value
			for _, func in ipairs(listeners_by_key[key] or {}) do
				func(value)
			end
		end,
	})
end
