-- Localize globals
local assert, math, math_floor, minetest, modlib_table_reverse, os, string_char, select, setmetatable, table_insert, table_concat
	= assert, math, math.floor, minetest, modlib.table.reverse, os, string.char, select, setmetatable, table.insert, table.concat

local inf = math.huge

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

-- TODO might be too invasive
-- Make random random
math.randomseed(minetest and minetest.get_us_time() or os.time() + os.clock())
for _ = 1, 100 do math.random() end

negative_nan = 0/0
positive_nan = negative_nan ^ 1

function sign(number)
	if number ~= number then return number end -- nan
	if number == 0 then return 0 end
	if number < 0 then return -1 end
	if number > 0 then return 1 end
end

function clamp(number, min, max)
	return math.min(math.max(number, min), max)
end

-- Random integer from 0 to 2^53 - 1 (inclusive)
local function _randint()
	return math.random(0, 2^27 - 1) * 2^26 + math.random(0, 2^26 - 1)
end

-- Random float from 0 to 1 (exclusive)
local function _randfloat()
	return _randint() / (2^53)
end

--+ Increased randomness float random without overflows
--+ `random()`: Random number from `0` to `1` (exclusive)
--+ `random(max)`: Random number from `0` to `max` (exclusive)
--+ `random(min, max)`: Random number from `min` to `max` (exclusive)
function random(...)
	local n = select("#", ...)
	if n == 0 then
		return _randfloat()
	end if n == 1 then
		local max = ...
		return _randfloat() * max
	end do assert(n == 2)
		local min, max = ...
		return min + (max - min) * _randfloat()
	end
end

-- Increased randomness integer random
--+ `randint()`: Random integer from `0` to `2^53 - 1` (inclusive)
--+ `randint(max)`: Random integer from `0` to `max` (inclusive)
--+ `randint(min, max)`: Random integer from `min` to `max` (inclusive)
function randint(...)
	local n = select("#", ...)
	if n == 0 then
		return _randint()
	end if n == 1 then
		local max = ...
		return math.floor(_randfloat() * max + 0.5)
	end do assert(n == 2)
		local min, max = ...
		return min + math.floor(_randfloat() * (max - min) + 0.5)
	end
end

log = setmetatable({}, {
	__index = function(self, base)
		local div = math.log(base)
		local function base_log(number)
			return math.log(number) / div
		end
		self[base] = base_log
		return base_log
	end,
	__call = function(_, number, base)
		if not base then
			return math.log(number)
		end
		return math.log(number) / math.log(base)
	end
})

-- one-based mod
function onemod(number, modulus)
	return ((number - 1) % modulus) + 1
end

function round(number, steps)
	steps = steps or 1
	return math_floor(number * steps + 0.5) / steps
end

local c0 = ("0"):byte()
local cA = ("A"):byte()

function default_digit_function(digit)
	if digit <= 9 then return string_char(c0 + digit) end
	return string_char(cA + digit - 10)
end

default_precision = 10

-- See https://github.com/appgurueu/Luon/blob/master/index.js#L724
function tostring(number, base, digit_function, precision)
	if number ~= number then
		return "nan"
	end
	if number == inf then
		return "inf"
	end
	if number == -inf then
		return "-inf"
	end
	digit_function = digit_function or default_digit_function
	precision = precision or default_precision
	local out = {}
	if number < 0 then
		table_insert(out, "-")
		number = -number
	end
	-- Rounding
	number = number + base ^ -precision / 2
	local digit
	while number >= base do
		digit = math_floor(number % base)
		table_insert(out, digit_function(digit))
		number = (number - digit) / base
	end
	digit = math_floor(number)
	table_insert(out, digit_function(digit))
	modlib_table_reverse(out)
	number = number % 1
	if number ~= 0 and number >= base ^ -precision then
		table_insert(out, ".")
		while precision >= 0 and number >= base ^ -precision do
			number = number * base
			digit = math_floor(number % base)
			table_insert(out, digit_function(digit))
			number = number - digit
			precision = precision - 1
		end
	end
	return table_concat(out)
end

-- See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/fround#polyfill
-- Rounds a 64-bit float to a 32-bit float;
-- if the closest 32-bit float is out of bounds,
-- the appropriate infinity is returned.
function fround(number)
	if number == 0 or number ~= number then
		return number
	end
	local sign = 1
	if number < 0 then
		sign = -1
		number = -number
	end
	local _, exp = math.frexp(number)
	exp = exp - 1 -- we want 2^exponent >= number > 2^(exponent-1)
	local powexp = 2 ^ math.max(-126, math.min(exp, 127))
	local leading = exp <= -127 and 0 or 1 -- subnormal number?
	local mantissa = math.floor((number / powexp - leading) * 0x800000 + 0.5)
	if
		mantissa > 0x800000 -- doesn't fit in mantissa
		or (exp >= 127 and mantissa == 0x800000) -- fits if the exponent can be increased
	then
		return sign * inf
	end
	return sign * powexp * (leading + mantissa / 0x800000)
end

-- Export environment
return _ENV
