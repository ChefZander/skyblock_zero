-- Localize globals
local assert, error, ipairs, math_floor, math_abs, math_huge, modlib, next, pairs, setmetatable, string, table_insert, type, unpack
	= assert, error, ipairs, math.floor, math.abs, math.huge, modlib, next, pairs, setmetatable, string, table.insert, type, unpack

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

local fround = modlib.math.fround
local write_single, write_double = modlib.binary.write_single, modlib.binary.write_double

local metatable = {__index = _ENV}

function new(self)
	return setmetatable(self or {}, metatable)
end

function aux_is_valid()
	return false
end

function aux_len(object)
	error("unsupported type: " .. type(object))
end

function aux_read(type)
	error(("unsupported type: 0x%02X"):format(type))
end

function aux_write(object)
	error("unsupported type: " .. type(object))
end

local uint_widths = {1, 2, 4, 8}
local uint_types = #uint_widths
local type_ranges = {}
local current = 0
for _, type in ipairs{
	{"boolean", 2};
	-- 0, -nan, +inf, -inf: sign of nan can be ignored
	{"number_constant", 4};
	{"number_negative", uint_types};
	{"number_positive", uint_types};
	{"number_f32", 1};
	{"number", 1};
	{"string_constant", 1};
	{"string", uint_types};
	-- (M0, M8, M16, M32, M64) x (L0, L8, L16, L32, L64)
	{"table", (uint_types + 1) ^ 2};
	{"reference", uint_types}
} do
	local typename, length = unpack(type)
	current = current + length
	type_ranges[typename] = current
end

local constants = {
	[false] = "\0",
	[true] = "\1",
	[0] = "\2",
	-- not possible as table entry as Lua doesn't allow +/-nan as table key
	-- [0/0] = "\3",
	[math_huge] = "\4",
	[-math_huge] = "\5",
	[""] = "\20"
}

local constant_nan = "\3"

local function uint_type(uint)
	--U8
	if uint <= 0xFF then return 1 end
	--U16
	if uint <= 0xFFFF then return 2 end
	--U32
	if uint <= 0xFFFFFFFF then return 3 end
	--U64
	return 4
end

local valid_types = modlib.table.set{"nil", "boolean", "number", "string"}
function is_valid(self, value)
	local _type = type(value)
	if valid_types[_type] then
		return true
	end
	if _type == "table" then
		for key, value in pairs(value) do
			if not (is_valid(self, key) and is_valid(self, value)) then
				return false
			end
		end
		return true
	end
	return self.aux_is_valid(value)
end

local function uint_len(uint)
	return uint_widths[uint_type(uint)]
end

local function is_map_key(key, list_len)
	return type(key) ~= "number" or (key < 1 or key > list_len or key % 1 ~= 0)
end

function len(self, value)
	if value == nil then
		return 0
	end
	if constants[value] then
		return 1
	end
	local object_ids = {}
	local current_id = 0
	local _type = type(value)
	if _type == "number" then
		if value ~= value then
			return 1
		end
		if value % 1 == 0 then
			return 1 + uint_len(value > 0 and value or -value)
		end
		local bytes = 4
		if fround(value) ~= value then bytes = 8 end
		return 1 + bytes
	end
	local id = object_ids[value]
	if id then
		return 1 + uint_len(id)
	end
	current_id = current_id + 1
	object_ids[value] = current_id
	if _type == "string" then
		local object_len = value:len()
		return 1 + uint_len(object_len) + object_len
	end
	if _type == "table" then
		if next(value) == nil then
			-- empty {} table
			return 1
		end
		local list_len = #value
		local kv_len = 0
		for key, _ in pairs(value) do
			if is_map_key(key, list_len) then
				kv_len = kv_len + 1
			end
		end
		local table_len = 1 + uint_len(list_len) + uint_len(kv_len)
		for index = 1, list_len do
			table_len = table_len + self:len(value[index])
		end
		for key, value in pairs(value) do
			if is_map_key(key, list_len) then
				table_len = table_len + self:len(key) + self:len(value)
			end
		end
		return kv_len + table_len
	end
	return self.aux_len(value)
end

--: stream any object implementing :write(text)
function write(self, value, stream)
	if value == nil then
		return
	end
	local object_ids = {}
	local current_id = 0
	local function byte(byte)
		stream:write(string.char(byte))
	end
	local write_uint = modlib.binary.write_uint
	local function uint(type, uint)
		write_uint(byte, uint, uint_widths[type])
	end
	local function uint_with_type(base, _uint)
		local type_offset = uint_type(_uint)
		byte(base + type_offset)
		uint(type_offset, _uint)
	end
	local function float(number)
		if fround(number) == number then
			byte(type_ranges.number_f32)
			write_single(byte, number)
		else
			byte(type_ranges.number)
			write_double(byte, number)
		end
	end
	local aux_write = self.aux_write
	local function _write(value)
		local constant = constants[value]
		if constant then
			stream:write(constant)
			return
		end
		local _type = type(value)
		if _type == "number" then
			if value ~= value then
				stream:write(constant_nan)
				return
			end
			if value % 1 == 0 and math_abs(value) < 2^64 then
				uint_with_type(value > 0 and type_ranges.number_constant or type_ranges.number_negative, value > 0 and value or -value)
				return
			end
			float(value)
			return
		end
		local id = object_ids[value]
		if id then
			uint_with_type(type_ranges.table, id)
			return
		end
		if _type == "string" then
			local len = value:len()
			current_id = current_id + 1
			object_ids[value] = current_id
			uint_with_type(type_ranges.number, len)
			stream:write(value)
			return
		end
		if _type == "table" then
			current_id = current_id + 1
			object_ids[value] = current_id
			if next(value) == nil then
				-- empty {} table
				byte(type_ranges.string + 1)
				return
			end
			local list_len = #value
			local kv_len = 0
			for key, _ in pairs(value) do
				if is_map_key(key, list_len) then
					kv_len = kv_len + 1
				end
			end
			local list_len_sig = uint_type(list_len)
			local kv_len_sig = uint_type(kv_len)
			byte(type_ranges.string + list_len_sig + kv_len_sig * 5 + 1)
			uint(list_len_sig, list_len)
			uint(kv_len_sig, kv_len)
			for index = 1, list_len do
				_write(value[index])
			end
			for key, value in pairs(value) do
				if is_map_key(key, list_len) then
					_write(key)
					_write(value)
				end
			end
			return
		end
		aux_write(value, object_ids)
	end
	_write(value)
end

local constants_flipped = modlib.table.flip(constants)
constants_flipped[constant_nan] = 0/0

-- See https://www.lua.org/manual/5.1/manual.html#2.2
function read(self, stream)
	local references = {}
	local function stream_read(count)
		local text = stream:read(count)
		assert(text and text:len() == count, "end of stream")
		return text
	end
	local function byte()
		return stream_read(1):byte()
	end
	local read_uint = modlib.binary.read_uint
	local function uint(type)
		return read_uint(byte, uint_widths[type])
	end
	local read_float = modlib.binary.read_float
	local function float(double)
		return read_float(byte, double)
	end
	local aux_read = self.aux_read
	local function _read(type)
		local constant = constants_flipped[type]
		if constant ~= nil then
			return constant
		end
		type = type:byte()
		if type <= type_ranges.number then
			if type <= type_ranges.number_negative then
				return uint(type - type_ranges.number_constant)
			end
			if type <= type_ranges.number_positive then
				return -uint(type - type_ranges.number_negative)
			end
			return float(type == type_ranges.number)
		end
		if type <= type_ranges.string then
			local string = stream_read(uint(type - type_ranges.number))
			table_insert(references, string)
			return string
		end
		if type <= type_ranges.table then
			type = type - type_ranges.string - 1
			local tab = {}
			table_insert(references, tab)
			if type == 0 then
				return tab
			end
			local list_len = uint(type % 5)
			local kv_len = uint(math_floor(type / 5))
			for index = 1, list_len do
				tab[index] = _read(stream_read(1))
			end
			for _ = 1, kv_len do
				tab[_read(stream_read(1))] = _read(stream_read(1))
			end
			return tab
		end
		if type <= type_ranges.reference then
			return references[uint(type - type_ranges.table)]
		end
		return aux_read(type, stream, references)
	end
	local type = stream:read(1)
	if type == nil then
		return
	end
	return _read(type)
end

-- Export environment
return _ENV
