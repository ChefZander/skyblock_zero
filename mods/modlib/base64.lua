local assert, floor, char, insert, concat = assert, math.floor, string.char, table.insert, table.concat

local base64 = {}

local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

--! This is currently 5 - 10x slower than a C(++) implementation like Minetest's `minetest.encode_base64`
function base64.encode(
	str, -- byte string to encode
	padding -- whether to add padding, defaults to `true`
)
	local res = {}
	for i = 1, #str - 2, 3 do
		-- Convert 3 bytes to 4 sextets
		local b1, b2, b3 = str:byte(i, i + 2)
		insert(res, char(
			alphabet:byte(floor(b1 / 4) + 1), -- high 6 bits of first byte
			alphabet:byte(16 * (b1 % 4) + floor(b2 / 16) + 1), -- low 2 bits of first byte & high 4 bits of second byte
			alphabet:byte(4 * (b2 % 16) + floor(b3 / 64) + 1), -- low 4 bits of second byte & high 2 bits of third byte
			alphabet:byte((b3 % 64) + 1) -- low 6 bits of third byte
		))
	end
	-- Handle remaining 1 or 2 bytes:
	-- Treat "missing" bytes to a multiple of 3 as "0" bytes, add appropriate padding.
	local bytes_left = #str % 3
	if bytes_left == 1 then
		local b = str:byte(#str) -- b2 and b3 are missing ("= 0")
		insert(res, char(
			alphabet:byte(floor(b / 4) + 1),
			alphabet:byte(16 * (b % 4) + 1)
		))
		-- Last two sextets depend only on missing bytes => padding
		if padding ~= false then
			insert(res, "==")
		end
	elseif bytes_left == 2 then
		local b1, b2 = str:byte(#str - 1, #str) -- b3 is missing ("= 0")
		insert(res, char(
			alphabet:byte(floor(b1 / 4) + 1),
			alphabet:byte(16 * (b1 % 4) + floor(b2 / 16) + 1),
			alphabet:byte(4 * (b2 % 16) + 1)
		))
		-- Last sextet depends only on missing byte => padding
		if padding ~= false then
			insert(res, "=")
		end
	end

	return concat(res)
end

-- Build reverse lookup table
local values = {}
for i = 1, #alphabet do
	values[alphabet:byte(i)] = i - 1
end

local function decode_sextets_2(b1, b2)
	local v1, v2 = values[b1], values[b2]
	assert(v1 and v2)
	assert(v2 % 16 == 0) -- 4 low bits from second sextet must be 0
	return char(4 * v1 + floor(v2 / 16)) -- first sextet + 2 high bits from second sextet
end

local function decode_sextets_3(b1, b2, b3)
	local v1, v2, v3 = values[b1], values[b2], values[b3]
	assert(v1 and v2 and v3)
	assert(v3 % 4 == 0) -- 2 low bits from third sextet must be 0
	return char(
		4 * v1 + floor(v2 / 16), -- first sextet + 2 high bits from second sextet
		16 * (v2 % 16) + floor(v3 / 4) -- 4 low bits from second sextet + 4 high bits from third sextet
	)
end

local function decode_sextets_4(b1, b2, b3, b4)
	local v1, v2, v3, v4 = values[b1], values[b2], values[b3], values[b4]
	assert(v1 and v2 and v3 and v4)
	return char(
		4 * v1 + floor(v2 / 16), -- first sextet + 2 high bits from second sextet
		16 * (v2 % 16) + floor(v3 / 4), -- 4 low bits from second sextet + 4 high bits from third sextet
		64 * (v3 % 4) + v4 -- 2 low bits from third sextet + fourth sextet
	)
end

--! This is also about 10x slower than a C(++) implementation like Minetest's `minetest.decode_base64`
function base64.decode(
	-- base64-encoded string to decode
	str,
	-- Whether to expect padding:
	-- * `nil` (default) - may (or may not) be padded,
	-- * `false` - must not be padded,
	-- * `true` - must be padded
	padding
)
	-- Handle the empty string - the below code expects a nonempty string
	if str == "" then return "" end

	local res = {}
	-- Note: the last (up to) 4 sextets are deliberately excluded, since they may contain padding
	for i = 1, #str - 4, 4 do
		-- Convert 4 sextets to 3 bytes
		insert(res, decode_sextets_4(str:byte(i, i + 3)))
	end
	local sextets_left = #str % 4
	if sextets_left == 0 then -- possibly padded
		-- Convert 4 sextets to 3 bytes, taking padding into account
		local b3, b4 = str:byte(#str - 1, #str)
		if b3 == ("="):byte() then
			assert(b4 == ("="):byte())
			assert(padding ~= false, "got padding")
			insert(res, decode_sextets_2(str:byte(#str - 3, #str - 2)))
		elseif b4 == ("="):byte() then
			assert(padding ~= false, "got padding")
			insert(res, decode_sextets_3(str:byte(#str - 3, #str - 1)))
		else -- no padding necessary
			assert(#str >= 4)
			assert(#({str:byte(#str - 3, #str)}) == 4)
			insert(res, decode_sextets_4(str:byte(#str - 3, #str)))
		end
	else -- no padding and length not divisible by 4
		assert(padding ~= true, "missing/invalid padding")
		assert(sextets_left ~= 1)
		if sextets_left == 2 then
			insert(res, decode_sextets_2(str:byte(#str - 1, #str)))
		elseif sextets_left == 3 then
			insert(res, decode_sextets_3(str:byte(#str - 2, #str)))
		end
	end
	return concat(res)
end

return base64