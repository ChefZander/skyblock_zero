-- Lua module to serialize values as Lua code

local assert, error, rawget, pairs, pcall, type, setfenv, setmetatable, select, loadstring, loadfile
	= assert, error, rawget, pairs, pcall, type, setfenv, setmetatable, select, loadstring, loadfile

local table_concat, string_format, math_huge
	= table.concat, string.format, math.huge

local count_objects = modlib.table.count_objects
local is_identifier = modlib.text.is_identifier

local function quote(string)
	return string_format("%q", string)
end

local _ENV = {}
setfenv(1, _ENV)
local metatable = {__index = _ENV}
_ENV.metatable = metatable

function new(self)
	return setmetatable(self, metatable)
end

function aux_write(_self, _object)
	-- returns reader, arguments
	return
end

aux_read = {}

function write(self, value, write)
	-- TODO evaluate custom aux. writers *before* writing for circular structs
	local reference, refnum = "1", 1
	-- [object] = reference
	local references = {}
	-- Circular tables that must be filled using `table[key] = value` statements
	local to_fill = {}

	-- TODO (?) sort objects by count, give frequently referenced objects shorter references
	for object, count in pairs(count_objects(value)) do
		local type_ = type(object)
		-- Object must appear more than once. If it is a string, the reference has to be shorter than the string.
		if count >= 2 and (type_ ~= "string" or #reference + 5 < #object) then
			if refnum == 1 then
				write"local _={};" -- initialize reference table
			end
			write"_["
			write(reference)
			write"]="
			if type_ == "table" then
				write"{}"
			elseif type_ == "string" then
				write(quote(object))
			end
			write";"
			references[object] = reference
			if type_ == "table" then
				to_fill[object] = reference
			end
			refnum = refnum + 1
			reference = string_format("%d", refnum)
		end
	end
	-- Used to decide whether we should do "key=..."
	local function use_short_key(key)
		return not references[key] and type(key) == "string" and is_identifier(key)
	end
	local function dump(value)
		-- Primitive types
		if value == nil then
			return write"nil"
		end if value == true then
			return write"true"
		end if value == false then
			return write"false"
		end
		local type_ = type(value)
		if type_ == "number" then
			-- Explicit handling of special values for forwards compatibility
			if value ~= value then -- nan
				return write"0/0"
			end if value == math_huge then
				return write"1/0"
			end if value == -math_huge then
				return write"-1/0"
			end
			return write(string_format("%.17g", value))
		end
		-- Reference types: table and string
		local ref = references[value]
		if ref then
			-- Referenced
			write"_["
			write(ref)
			return write"]"
		end if type_ == "string" then
			return write(quote(value))
		end if type_ == "table" then
			write"{"
			-- First write list keys:
			-- Don't use the table length #value here as it may horribly fail
			-- for tables which use large integers as keys in the hash part;
			-- stop at the first "hole" (nil value) instead
			local len = 0
			local first = true -- whether this is the first entry, which may not have a leading comma
			while true do
				local v = rawget(value, len + 1) -- use rawget to avoid metatables like the vector metatable
				if v == nil then break end
				if first then first = false else write(",") end
				dump(v)
				len = len + 1
			end
			-- Now write map keys ([key] = value)
			for k, v in pairs(value) do
				-- We have written all non-float keys in [1, len] already
				if type(k) ~= "number" or k % 1 ~= 0 or k < 1 or k > len then
					if first then first = false else write(",") end
					if use_short_key(k) then
						write(k)
					else
						write"["
						dump(k)
						write"]"
					end
					write"="
					dump(v)
				end
			end
			return write"}"
		end
		-- TODO move aux_write to start, to allow dealing with metatables etc.?
		return (function(func, ...)
			-- functions are the only way to deal with varargs
			if not func then
				return error("unsupported type: " .. type_)
			end
			write(func)
			write"("
			local n = select("#", ...)
			for i = 1, n - 1 do
				dump(select(i, ...))
				write","
			end
			if n > 0 then
				dump(select(n, ...))
			end
			write")"
		end)(self:aux_write(value))
	end
	-- Write the statements to fill circular tables
	for table, ref in pairs(to_fill) do
		for k, v in pairs(table) do
			write"_["
			write(ref)
			write"]"
			if use_short_key(k) then
				write"."
				write(k)
			else
				write"["
				dump(k)
				write"]"
			end
			write"="
			dump(v)
			write";"
		end
	end
	write"return "
	dump(value)
end

function write_file(self, value, file)
	return self:write(value, function(text)
		file:write(text)
	end)
end

function write_string(self, value)
	local rope = {}
	self:write(value, function(text)
		rope[#rope + 1] = text
	end)
	return table_concat(rope)
end

function read(self, ...)
	local read = assert(...)
	-- math.huge was serialized to inf, 0/0 was serialized to -nan by `%.17g`
	setfenv(read, setmetatable({inf = math_huge, nan = 0/0}, {__index = self.aux_read}))
	local success, value_or_err = pcall(read)
	if success then
		return value_or_err
	end
	return nil, value_or_err
end

function read_file(self, path)
	return self:read(loadfile(path))
end

function read_string(self, string)
	return self:read(loadstring(string))
end

return _ENV