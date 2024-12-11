-- pack bits into doubles
-- this is quite slow compared to how you'd do this in c or something.
-- there's https://bitop.luajit.org/api.html but that seems limited to 32 bits. we can use the full 53 bit mantissa.

local BITS_PER_NUMBER = 53

local f = string.format

local m_floor = math.floor
local s_byte = string.byte
local s_char = string.char

local BitArray = futil.class1()

function BitArray:_init(size_or_bitmap)
	if type(size_or_bitmap) == "number" then
		local data = {}
		self._size = size_or_bitmap
		for i = 1, math.ceil(size_or_bitmap / BITS_PER_NUMBER) do
			data[i] = 0
		end
		self._data = data
	elseif type(size_or_bitmap) == "table" then
		if size_or_bitmap.is_a and size_or_bitmap:is_a(BitArray) then
			self._size = size_or_bitmap._size
			self._data = table.copy(size_or_bitmap._data)
		end
	end
	if not self._data then
		error("bitmap must be initialized w/ a size or another bitmap")
	end
end

function BitArray:__eq(other)
	if self._size ~= other._size then
		return false
	end
	for i = 1, self._size do
		if self._data[i] ~= other._data[i] then
			return false
		end
	end
	return true
end

local function get_bit(n, j)
	n = n % (2 ^ j)
	return m_floor(n / (2 ^ (j - 1))) == 1
end

function BitArray:get(k)
	if type(k) ~= "number" then
		return nil
	elseif k <= 0 or k > self._size then
		return nil
	end
	local i = math.ceil(k / BITS_PER_NUMBER)
	local n = self._data[i]
	local j = ((k - 1) % BITS_PER_NUMBER) + 1
	return get_bit(n, j)
end

local function set_bit(n, j, v)
	local current = get_bit(n, j)
	if current == v then
		return n
	elseif v then
		return n + (2 ^ (j - 1))
	else
		return n - (2 ^ (j - 1))
	end
end

function BitArray:set(k, v)
	if type(v) == "number" then
		if v < 0 or v > 1 then
			error(f("invalid argument %s", v))
		end
		v = v == 1
	elseif type(v) ~= "boolean" then
		error(f("invalid argument of type %s", type(v)))
	end
	local i = math.ceil(k / BITS_PER_NUMBER)
	local n = self._data[i]
	local j = ((k - 1) % BITS_PER_NUMBER) + 1
	self._data[i] = set_bit(n, j, v)
end

function BitArray:serialize()
	local data = self._data
	local parts = {}
	for i = 1, #data do
		local datum = data[i]
		parts[i] = s_char(datum % 256)
			.. s_char(m_floor(datum / 256) % 256)
			.. s_char(m_floor(datum / (256 ^ 2)) % 256)
			.. s_char(m_floor(datum / (256 ^ 3)) % 256)
			.. s_char(m_floor(datum / (256 ^ 4)) % 256)
			.. s_char(m_floor(datum / (256 ^ 5)) % 256)
			.. s_char(m_floor(datum / (256 ^ 6)) % 256)
	end
	return table.concat(parts, "")
end

function BitArray.deserialize(s)
	if type(s) ~= "string" then
		error(f("invalid argument of type %s", type(s)))
	elseif #s % 7 ~= 0 then
		error(f("invalid serialized string (wrong length)"))
	end
	local ba = BitArray(#s / 7)
	local i = 1
	for a = 1, #s, 7 do
		local bs = {}
		for j = 0, 6 do
			bs[j + 1] = s_byte(s:sub(a + j, a + j))
		end
		ba._data[i] = bs[1]
			+ 256 * (bs[2] + 256 * (bs[3] + 256 * (bs[4] + 256 * (bs[5] + 256 * (bs[6] + 256 * bs[7])))))
		i = i + 1
	end
	return ba
end

futil.BitArray = BitArray
