
local fake_metadata = {}
local identifier = "fakelib:metadata"
local check, secure_table = ...

-- API functions
----------------------------------------

function fakelib.is_metadata(x)
	if type(x) == "userdata" and x.get_keys then
		return true
	elseif type(x) == "table" and getmetatable(x) == identifier then
		return true
	end
	return false
end

function fakelib.create_metadata(data)
	local fields = {}
	if type(data) == "table" then
		for k,v in pairs(data) do
			if type(k) == "string" and type(v) == "string" then
				fields[k] = v
			end
		end
	end
	return secure_table({fields = fields}, fake_metadata, identifier)
end

-- Metadata functions
----------------------------------------

function fake_metadata:contains(key)
	check(1, key, "string", "number")
	key = tostring(key)
	return self.fields[key] ~= nil
end

function fake_metadata:get(key)
	check(1, key, "string", "number")
	key = tostring(key)
	return self.fields[key]
end

function fake_metadata:set_string(key, value)
	check(1, key, "string", "number")
	check(2, value, "string", "number")
	key = tostring(key)
	value = tostring(value)
	if value == "" then
		self.fields[key] = nil
	end
	self.fields[key] = value
end

function fake_metadata:get_string(key)
	check(1, key, "string", "number")
	key = tostring(key)
	return self.fields[key] or ""
end

function fake_metadata:set_int(key, value)
	check(1, key, "string", "number")
	check(2, value, "number")
	key = tostring(key)
	if value >= 2^31 then
		value = 0
	end
	self.fields[key] = string.format("%i", value)
end

function fake_metadata:get_int(key)
	check(1, key, "string", "number")
	key = tostring(key)
	return tonumber(self.fields[key]) or 0
end

function fake_metadata:set_float(key, value)
	check(1, key, "string", "number")
	check(2, value, "number")
	key = tostring(key)
	self.fields[key] = string.format("%s", value)
end

function fake_metadata:get_float(key)
	check(1, key, "string", "number")
	key = tostring(key)
	return tonumber(self.fields[key]) or 0
end

function fake_metadata:get_keys()
	local keys = {}
	for key in pairs(self.fields) do
		table.insert(keys, key)
	end
	return keys
end

function fake_metadata:to_table()
	return {fields = table.copy(self.fields)}
end

function fake_metadata:from_table(data)
	if type(data) ~= "table" or type(data.fields) ~= "table" then
		self.fields = {}
		return true
	end
	local fields = {}
	for k,v in pairs(data.fields) do
		check(4, k, "string")
		check(5, v, "string", "number")
		fields[k] = tostring(v)
	end
	self.fields = fields
	return true
end

function fake_metadata:equals(other)
	if not fakelib.is_metadata(other) then
		check(1, other, "MetaDataRef")
	end
	local fields = other:to_table().fields
	for k,v in pairs(self.fields) do
		if fields[k] == v then
			fields[k] = nil
		elseif fields[k] ~= nil then
			return false
		end
	end
	if next(fields) == nil then
		return true
	end
	return false
end
