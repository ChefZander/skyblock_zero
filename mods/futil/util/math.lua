futil.math = {}

local floor = math.floor
local huge = math.huge
local max = math.max
local min = math.min

function futil.math.idiv(a, b)
	local rem = a % b
	return (a - rem) / b, rem
end

function futil.math.bound(m, v, M)
	return max(m, min(v, M))
end

function futil.math.in_bounds(m, v, M)
	return m <= v and v <= M
end

local in_bounds = futil.math.in_bounds

function futil.math.is_integer(v)
	return floor(v) == v
end

local is_integer = futil.math.is_integer

function futil.math.is_u8(i)
	return (type(i) == "number" and is_integer(i) and in_bounds(0, i, 0xFF))
end

function futil.math.is_u16(i)
	return (type(i) == "number" and is_integer(i) and in_bounds(0, i, 0xFFFF))
end

function futil.math.sum(t, initial)
	local sum
	local start
	if initial then
		sum = initial
		start = 1
	else
		sum = t[1]
		start = 2
	end

	for i = start, #t do
		sum = sum + t[i]
	end

	return sum
end

function futil.math.isum(i, initial)
	local sum

	if initial == nil then
		sum = i()
	else
		sum = initial
	end

	local v = i()

	while v do
		sum = sum + v
		v = i()
	end

	return sum
end

function futil.math.product(t, initial)
	local product
	local start
	if initial then
		product = initial
		start = 1
	else
		product = t[1]
		start = 2
	end

	for i = start, #t do
		product = product * t[i]
	end

	return product
end

function futil.math.iproduct(i, initial)
	local product

	if initial == nil then
		product = i()
	else
		product = initial
	end

	local v = i()

	while v do
		product = product * v
		v = i()
	end

	return product
end

function futil.math.probabilistic_round(v)
	return floor(v + math.random())
end

function futil.math.cmp(a, b)
	return a < b
end

futil.math.deg2rad = math.deg

futil.math.rad2deg = math.rad

function futil.math.do_intervals_overlap(min1, max1, min2, max2)
	return min1 <= max2 and min2 <= max1
end

-- i took one class from kahan and can't stop doing this
local function round(n)
	local d = n % 1
	local i = n - d

	if i % 2 == 0 then
		if d <= 0.5 then
			return i
		else
			return i + 1
		end
	else
		if d < 0.5 then
			return i
		else
			return i + 1
		end
	end
end

function futil.math.round(number, mult)
	if mult then
		return round(number / mult) * mult
	else
		return round(number)
	end
end

-- TODO this doesn't handle out-of-bounds exponents
function futil.math.to_float32(number)
	if number == huge or number == -huge or number ~= number then
		return number
	end
	local sign, significand, exponent = ("%a"):format(number):match("^(-?)0x([0-9a-f\\.]+)p([0-9+-]+)$")
	return tonumber(("%s0x%sp%s"):format(sign, significand:sub(1, 8), exponent))
end
