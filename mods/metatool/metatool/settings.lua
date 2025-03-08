--[[
	Metatool settings parser, should be loaded
	before initializing any other functionality.
--]]

local S = metatool.S

local settings = Settings(metatool.configuration_file)

local settings_data = settings:to_table()

local parsed_settings = {}

-- return table elements starting from index
local slice = function(source, index)
	local res = {}
	local maxindex = #source
	if index > 0 and index <= maxindex then
		for i=index,maxindex do
			table.insert(res, source[i])
		end
	end
	return res
end

local convert = function(value, to_type)
	if to_type == "boolean" then
		-- False values are "", "0", "n", "no", "false" and everything else is true
		return not (
			value == "" or
			value == "0" or
			value == "n" or
			value == "no" or
			value == "false"
		)
	elseif to_type == "number" then
		-- For number types always return number, return 0 if conversion fails
		return tonumber(value) or 0
	end
	-- Unknown to_type, no conversion available
	return value
end

local get_table = function(t, key)
	if t[key] == nil then
		t[key] = {}
	end
	return t[key]
end

local write_table_value = function(t, key, value)
	if type(key) == 'table' then
		for i=1,#key-1 do
			t = get_table(t, key[i])
		end
		key = key[#key]
	end
	t[key] = value
end

-- Parse tool specific configuration keys
local parsekey = function(key)
	local parts = key:gsub('\\s',''):split(':')
	if #parts == 2 then
		-- Core API settings metatool:settingname
		return parts[1], parts[2]
	end
	-- Tool settings metatool:whatevertool:settingname
	local remain = slice(parts, 3)
	remain = #remain == 1 and remain[1] or remain
	return parts[1] .. ':' .. parts[2], remain
end

-- Build tool specific configuration keys
local makekey = function(name, key)
	return string.format('%s:%s', name, key)
end

local get_toolname = function(name)
	local parts = name:gsub('\\s',''):split(':')
	if #parts < 1 or #parts > 2 then
		return
	end
	return 'metatool:' .. parts[#parts]
end

-- Parse settings to table structure where settings for metatool API
-- and settings for registered tools stay isolated from each other.
for rawkey, value in pairs(settings_data) do
	local toolname, key = parsekey(rawkey)
	local target = get_table(parsed_settings, toolname)
	write_table_value(target, key, value)
end

metatool.settings = function(toolname, key)
	-- TODO: Make copy of settings table before returning to protect against modification.
	-- Settings are intended to be read only.
	-- Return nil if key does not exist and return whole settings table if key is nil.
	local name = get_toolname(toolname)

	if parsed_settings[name] then
		if key then
			return parsed_settings[name][key]
		end
		return parsed_settings[name]
	end
end

local update_setting = function(target, name, key, value)
	if target[key] == nil then
		-- If key is not set use provided value and export it if asked to
		target[key] = value
		-- Export default configuration to settings file
		if metatool.export_default_config then
			if type(value) == "boolean" then
				settings:set_bool(makekey(name, key), value)
			else
				settings:set(makekey(name, key), value)
			end
		end
	else
		-- If key is set convert configuration value to type of default setting
		target[key] = convert(target[key], type(value))
	end
end

local node_specials = { "protection_bypass_info", "protection_bypass_read", "protection_bypass_write" }
metatool.merge_node_settings = function(toolname, nodename, nodedef)
	local name = get_toolname(toolname)
	local path = string.format("%s:nodes:%s", name, nodename)
	print(S('metatool.merge_node_settings merging settings for node %s', path))

	local tool_nodes = get_table(parsed_settings[name], "nodes")
	local node_settings = get_table(tool_nodes, nodename)
	for _,key in ipairs(node_specials) do
		if nodedef[key] then
			update_setting(node_settings, path, key, nodedef[key])
		end
		if node_settings[key] then
			nodedef[key] = node_settings[key]
		end
	end
	if type(nodedef.settings) == 'table' then
		-- Merge default tool settings
		for key, value in pairs(nodedef.settings) do
			update_setting(node_settings, path, key, value)
		end
	end
	nodedef.settings = node_settings
	if metatool.export_default_config then
		settings:write()
	end
end

local tool_specials = { privs = 1 }
metatool.merge_tool_settings = function(toolname, tooldef)
	-- Merges default setting values for tool using tooldef.settings table.
	-- Should be called once during tool registration, assuming settings_data is kept
	-- unchanged multiple calls wont do anything useful as settings are already merged.
	local name = get_toolname(toolname)
	print(S('metatool.merge_tool_settings merging settings for tool %s', name))

	local tool_settings = get_table(parsed_settings, name)
	for key,_ in pairs(tool_specials) do
		if tooldef[key] then
			update_setting(tool_settings, name, key, tooldef[key])
		end
		tooldef[key] = tool_settings[key]
	end
	if type(tooldef.settings) == 'table' then
		-- Merge default tool settings
		for key, value in pairs(tooldef.settings) do
			update_setting(tool_settings, name, key, value)
		end
	else
		tooldef.settings = {}
	end
	for key, value in pairs(tool_settings) do
		if not tool_specials[key] and key ~= 'nodes' then
			tooldef.settings[key] = value
		end
	end
	if metatool.export_default_config then
		settings:write()
	end
end
