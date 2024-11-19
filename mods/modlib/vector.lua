-- Localize globals
local assert, math, pairs, rawget, rawset, setmetatable, unpack, vector = assert, math, pairs, rawget, rawset, setmetatable, unpack, vector

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

local mt_vector = vector

index_aliases = {
	x = 1,
	y = 2,
	z = 3,
	w = 4;
	"x", "y", "z", "w";
}

metatable = {
	__index = function(table, key)
		local index = index_aliases[key]
		if index ~= nil then
			return rawget(table, index)
		end
		return _ENV[key]
	end,
	__newindex = function(table, key, value)
		-- TODO
		local index = index_aliases[key]
		if index ~= nil then
			return rawset(table, index, value)
		end
		return rawset(table, key, value)
	end
}

function new(v)
	return setmetatable(v, metatable)
end

function zeros(n)
	local v = {}
	for i = 1, n do
		v[i] = 0
	end
	return new(v)
end
function from_xyzw(v)
	return new{v.x, v.y, v.z, v.w}
end

function from_minetest(v)
	return new{v.x, v.y, v.z}
end

function to_xyzw(v)
	return {x = v[1], y = v[2], z = v[3], w = v[4]}
end

--+ not necessarily required, as Minetest respects the metatable
function to_minetest(v)
	return mt_vector.new(unpack(v))
end

function equals(v, w)
	for k, v in pairs(v) do
		if v ~= w[k] then return false end
	end
	return true
end

metatable.__eq = equals

function combine(v, w, f)
	local new_vector = {}
	for key, value in pairs(v) do
		new_vector[key] = f(value, w[key])
	end
	return new(new_vector)
end

function apply(v, f, ...)
	local new_vector = {}
	for key, value in pairs(v) do
		new_vector[key] = f(value, ...)
	end
	return new(new_vector)
end

function combinator(f)
	return function(v, w)
		return combine(v, w, f)
	end, function(v, ...)
		return apply(v, f, ...)
	end
end

function invert(v)
	local res = {}
	for key, value in pairs(v) do
		res[key] = -value
	end
	return new(res)
end

add, add_scalar = combinator(function(v, w) return v + w end)
subtract, subtract_scalar = combinator(function(v, w) return v - w end)
multiply, multiply_scalar = combinator(function(v, w) return v * w end)
divide, divide_scalar = combinator(function(v, w) return v / w end)
pow, pow_scalar = combinator(function(v, w) return v ^ w end)

metatable.__add = add
metatable.__unm = invert
metatable.__sub = subtract
metatable.__mul = multiply
metatable.__div = divide

--+ linear interpolation
--: ratio number from 0 (all the first vector) to 1 (all the second vector)
function interpolate(v, w, ratio)
	return add(multiply_scalar(v, 1 - ratio), multiply_scalar(w,  ratio))
end

function norm(v)
	local sum = 0
	for _, value in pairs(v) do
		sum = sum + value ^ 2
	end
	return sum
end

function length(v)
	return math.sqrt(norm(v))
end

-- Minor code duplication for the sake of performance
function distance(v, w)
	local sum = 0
	for key, value in pairs(v) do
		sum = sum + (value - w[key]) ^ 2
	end
	return math.sqrt(sum)
end

function normalize(v)
	return divide_scalar(v, length(v))
end

function normalize_zero(v)
	local len = length(v)
	if len == 0 then
		-- Return a zeroed vector with the same keys
		local zeroed = {}
		for k in pairs(v) do
			zeroed[k] = 0
		end
		return new(zeroed)
	end
	return divide_scalar(v, len)
end

function floor(v)
	return apply(v, math.floor)
end

function ceil(v)
	return apply(v, math.ceil)
end

function clamp(v, min, max)
	return apply(apply(v, math.max, min), math.min, max)
end

function cross3(v, w)
	assert(#v == 3 and #w == 3)
	return new{
		v[2] * w[3] - v[3] * w[2],
		v[3] * w[1] - v[1] * w[3],
		v[1] * w[2] - v[2] * w[1]
	}
end

function dot(v, w)
	local sum = 0
	for i, c in pairs(v) do
		sum = sum + c * w[i]
	end
	return sum
end

function reflect(v, normal --[[**normalized** plane normal vector]])
	return subtract(v, multiply_scalar(normal, 2 * dot(v, normal))) -- reflection of v at the plane
end

--+ Angle between two vectors
--> Signed angle in radians
function angle(v, w)
	-- Based on dot(v, w) = |v| * |w| * cos(x)
	return math.acos(dot(v, w) / length(v) / length(w))
end

-- See https://www.euclideanspace.com/maths/geometry/rotations/conversions/eulerToAngle/
function axis_angle3(euler_rotation)
	assert(#euler_rotation == 3)
	euler_rotation = divide_scalar(euler_rotation, 2)
	local cos = apply(euler_rotation, math.cos)
	local sin = apply(euler_rotation, math.sin)
	return normalize_zero{
		sin[1] * sin[2] * cos[3] + cos[1] * cos[2] * sin[3],
		sin[1] * cos[2] * cos[3] + cos[1] * sin[2] * sin[3],
		cos[1] * sin[2] * cos[3] - sin[1] * cos[2] * sin[3],
	}, 2 * math.acos(cos[1] * cos[2] * cos[3] - sin[1] * sin[2] * sin[3])
end

-- Uses Rodrigues' rotation formula
-- axis must be normalized
function rotate3(v, axis, angle)
	assert(#v == 3 and #axis == 3)
	local cos = math.cos(angle)
	return multiply_scalar(v, cos)
		-- Minetest's coordinate system is *left-handed*, so `v` and `axis` must be swapped here
		+ multiply_scalar(cross3(v, axis), math.sin(angle))
		+ multiply_scalar(axis, dot(axis, v) * (1 - cos))
end

function box_box_collision(diff, box, other_box)
	for index, diff in pairs(diff) do
		if box[index] + diff > other_box[index + 3] or other_box[index] > box[index + 3] + diff then
			return false
		end
	end
	return true
end

local function moeller_trumbore(origin, direction, triangle, is_tri)
	local point_1, point_2, point_3 = unpack(triangle)
	local edge_1, edge_2 = subtract(point_2, point_1), subtract(point_3, point_1)
	local h = cross3(direction, edge_2)
	local a = dot(edge_1, h)
	if math.abs(a) < 1e-9 then
		return
	end
	local f = 1 / a
	local diff = subtract(origin, point_1)
	local u = f * dot(diff, h)
	if u < 0 or u > 1 then
		return
	end
	local q = cross3(diff, edge_1)
	local v = f * dot(direction, q)
	if v < 0 or (is_tri and u or 0) + v > 1 then
		return
	end
	local pos_on_line = f * dot(edge_2, q)
	if pos_on_line >= 0 then
		return pos_on_line, u, v
	end
end

function ray_triangle_intersection(origin, direction, triangle)
	return moeller_trumbore(origin, direction, triangle, true)
end

function ray_parallelogram_intersection(origin, direction, parallelogram)
	return moeller_trumbore(origin, direction, parallelogram)
end

function triangle_normal(triangle)
	local point_1, point_2, point_3 = unpack(triangle)
	local edge_1, edge_2 = subtract(point_2, point_1), subtract(point_3, point_1)
	return normalize(cross3(edge_1, edge_2))
end

-- Export environment
return _ENV