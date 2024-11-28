-- Localize globals
local assert, error, ipairs, math, minetest, modlib, pairs, setmetatable, table, tonumber, tostring, type = assert, error, ipairs, math, minetest, modlib, pairs, setmetatable, table, tonumber, tostring, type

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

local metatable = {__index = _ENV}

function new(def)
	-- TODO type inference, sanity checking etc.
	return setmetatable(def, metatable)
end

local function field_name_to_title(name)
	local title = modlib.text.split(name, "_")
	title[1] = modlib.text.upper_first(title[1])
	return table.concat(title, " ")
end

function generate_settingtypes(self)
	local typ = self.type
	local settingtype, type_args
	self.title = self.title or field_name_to_title(self.name)
	self._level = self._level or 0
	local default = self.default
	if typ == "boolean" then
		settingtype = "bool"
		default = default and "true" or "false"
	elseif typ == "string" then
		settingtype = "string"
		if self.values then
			local values = {}
			for value in pairs(self.values) do
				if value:find"," then
					values = nil
					break
				end
				table.insert(values, value)
			end
			if values then
				settingtype = "enum"
				type_args = table.concat(values, ",")
			end
		end
	elseif typ == "number" then
		settingtype = self.int and "int" or "float"
		if self.range and (self.range.min or self.range.max) then
			-- TODO handle exclusive min/max
			type_args = (self.int and "%d %d" or "%f %f"):format(self.range.min or (2 ^ -30), self.range.max or (2 ^ 30))
		end
	elseif typ == "table" then
		local settings = {}
		if self._level > 0 then
			-- HACK: Minetest automatically adds the modname
			-- TODO simple names (not modname.field.other_field)
			settings = {"[" .. ("*"):rep(self._level - 1) .. self.name .. "]"}
		end
		local function setting(key, value_scheme)
			key = tostring(key)
			assert(not key:find("[=%.%s]"))
			value_scheme.name = self.name .. "." .. key
			value_scheme.title = value_scheme.title or self.title .. " " .. field_name_to_title(key)
			value_scheme._level = self._level + 1
			table.insert(settings, generate_settingtypes(value_scheme))
		end
		local keys = {}
		for key in pairs(self.entries or {}) do
			table.insert(keys, key)
		end
		table.sort(keys, function(key, other_key)
			-- Force leaves before subtrees to prevent them from being accidentally graphically treated as part of the subtree
			local is_subtree = self.entries[key].type == "table"
			local other_is_subtree = self.entries[other_key].type == "table"
			if is_subtree ~= other_is_subtree then
				return not is_subtree
			end
			return key < other_key
		end)
		for _, key in ipairs(keys) do
			setting(key, self.entries[key])
		end
		return table.concat(settings, "\n\n")
	end
	if not typ then
		return ""
	end
	local description = self.description
	-- TODO extend description by range etc.?
	-- TODO enum etc. support
	if description then
		if type(description) ~= "table" then
			description = {description}
		end
		description = "# " .. table.concat(description, "\n# ") .. "\n"
	else
		description = ""
	end
	return description .. self.name .. " (" .. self.title  .. ") " .. settingtype .. " " .. (default or "") .. (type_args and (" " .. type_args) or "")
end

function generate_markdown(self)
	-- TODO address redundancies
	local function description(lines)
		local description = self.description
		if description then
			if type(description) ~= "table" then
				table.insert(lines, description)
			else
				modlib.table.append(lines, description)
			end
		end
	end
	local typ = self.type
	self.title = self.title or field_name_to_title(self._md_name)
	self._md_level = self._md_level or 1
	if typ == "table" then
		local settings = {}
		description(settings)
		-- TODO generate Markdown for key/value-checks
		local function setting(key, value_scheme)
			value_scheme._md_name = key
			value_scheme.title = value_scheme.title or self.title .. " " .. field_name_to_title(key)
			value_scheme._md_level = self._md_level + 1
			table.insert(settings, table.concat(modlib.table.repetition("#", self._md_level)) .. " `" .. key .. "`")
			table.insert(settings, "")
			table.insert(settings, generate_markdown(value_scheme))
			table.insert(settings, "")
		end
		local keys = {}
		for key in pairs(self.entries or {}) do
			table.insert(keys, key)
		end
		table.sort(keys)
		for _, key in ipairs(keys) do
			setting(key, self.entries[key])
		end
		return table.concat(settings, "\n")
	end
	if not typ then
		return ""
	end
	local lines = {}
	description(lines)
	local function line(text)
		table.insert(lines, "* " .. text)
	end
	table.insert(lines, "")
	line("Type: " .. self.type)
	if self.default ~= nil then
		line("Default: `" .. tostring(self.default) .. "`")
	end
	if self.int then
		line"Integer"
	elseif self.list then
		line"List"
	end
	if self.infinity then
		line"Infinities allowed"
	end
	if self.nan then
		line"Not-a-Number (NaN) allowed"
	end
	if self.range then
		if self.range.min then
			line("&gt;= `" .. self.range.min .. "`")
		elseif self.range.min_exclusive then
			line("&gt; `" .. self.range.min_exclusive .. "`")
		end
		if self.range.max then
			line("&lt;= `" .. self.range.max .. "`")
		elseif self.range.max_exclusive then
			line("&lt; `" .. self.range.max_exclusive .. "`")
		end
	end
	if self.values then
		line("Possible values:")
		for value in pairs(self.values) do
			table.insert(lines, "  * " .. value)
		end
	end
	return table.concat(lines, "\n")
end

function settingtypes(self)
	self.settingtypes = self.settingtypes or generate_settingtypes(self)
	return self.settingtypes
end

function load(self, override, params)
	local converted
	if params.convert_strings and type(override) == "string" then
		converted = true
		if self.type == "boolean" then
			if override == "true" then
				override = true
			elseif override == "false" then
				override = false
			end
		elseif self.type == "number" then
			override = tonumber(override)
		else
			converted = false
		end
	end
	if override == nil and not converted then
		if self.type == "table" and self.default == nil then
			override = {}
		else
			return self.default
		end
	end
	local _error = error
	local function format_error(typ, ...)
		if typ == "type" then
			return "mismatched type: expected " .. self.type ..", got " .. type(override) .. (converted and " (converted)" or "")
		end
		if typ == "range" then
			local conditions = {}
			local function push(condition, bound)
				if self.range[bound] then
					table.insert(conditions, " " .. condition .. " " .. minetest.write_json(self.range[bound]))
				end
			end
			push(">", "min_exclusive")
			push(">=", "min")
			push("<", "max_exclusive")
			push("<=", "max")
			return "out of range: expected value" .. table.concat(conditions, " and")
		end
		if typ == "int" then
			return "expected integer"
		end
		if typ == "infinity" then
			return "expected no infinity"
		end
		if typ == "nan" then
			return "expected no nan"
		end
		if typ == "required" then
			local key = ...
			return "required field " .. minetest.write_json(key) .. " missing"
		end
		if typ == "additional" then
			local key = ...
			return "superfluous field " .. minetest.write_json(key)
		end
		if typ == "list" then
			return "not a list"
		end
		if typ == "values" then
			return "expected one of " .. minetest.write_json(modlib.table.keys(self.values)) .. ", got " .. minetest.write_json(override)
		end
		_error("unknown error type")
	end
	local function error(type, ...)
		if params.error_message then
			local formatted = format_error(type, ...)
			_error("Invalid value: " .. (self.name and (self.name .. ": ") or "") .. formatted)
		end
		_error{
			type = type,
			self = self,
			override = override,
			converted = converted
		}
	end
	local function assert(value, ...)
		if not value then
			error(...)
		end
		return value
	end
	assert(self.type == type(override), "type")
	if self.type == "number" or self.type == "string" then
		if self.range then
			if self.range.min then
				assert(self.range.min <= override, "range")
			elseif self.range.min_exclusive then
				assert(self.range.min_exclusive < override, "range")
			end
			if self.range.max then
				assert(self.range.max >= override, "range")
			elseif self.range.max_exclusive then
				assert(self.range.max_exclusive > override, "range")
			end
		end
		if self.type == "number" then
			assert((not self.int) or (override % 1 == 0), "int")
			assert(self.infinity or math.abs(override) ~= math.huge, "infinity")
			assert(self.nan or override == override, "nan")
		end
	elseif self.type == "table" then
		if self.keys then
			for key, value in pairs(override) do
				override[load(self.keys, key, params)], override[key] = value, nil
			end
		end
		if self.values then
			for key, value in pairs(override) do
				override[key] = load(self.values, value, params)
			end
		end
		if self.entries then
			for key, schema in pairs(self.entries) do
				if schema.required and override[key] == nil then
					error("required", key)
				end
				override[key] = load(schema, override[key], params)
			end
			if self.additional == false then
				for key in pairs(override) do
					if self.entries[key] == nil then
						error("additional", key)
					end
				end
			end
		end
		assert((not self.list) or modlib.table.count(override) == #override, "list")
	end
	-- Apply the values check only for primitive types where table indexing is by value;
	-- the `values` field has a different meaning for tables (constraint all values must fulfill)
	if self.type ~= "table" then
		assert((not self.values) or self.values[override], "values")
	end
	if self.func then self.func(override) end
	return override
end

-- Export environment
return _ENV