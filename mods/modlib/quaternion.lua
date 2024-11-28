-- Localize globals
local math, modlib, pairs, unpack, vector = math, modlib, pairs, unpack, vector

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

-- TODO OOP, extend vector

function from_euler_rotation(rotation)
	rotation = vector.divide(rotation, 2)
	local cos = vector.apply(rotation, math.cos)
	local sin = vector.apply(rotation, math.sin)
	return {
		cos.z * sin.x * cos.y + sin.z * cos.x * sin.y,
		cos.z * cos.x * sin.y - sin.z * sin.x * cos.y,
		sin.z * cos.x * cos.y - cos.z * sin.x * sin.y,
		cos.z * cos.x * cos.y + sin.z * sin.x * sin.y
	}
end

function from_euler_rotation_deg(rotation)
	return from_euler_rotation(vector.apply(rotation, math.rad))
end

function multiply(self, other)
	local X, Y, Z, W = unpack(self)
	return normalize{
		(other[4] * X) + (other[1] * W) + (other[2] * Z) - (other[3] * Y);
		(other[4] * Y) + (other[2] * W) + (other[3] * X) - (other[1] * Z);
		(other[4] * Z) + (other[3] * W) + (other[1] * Y) - (other[2] * X);
		(other[4] * W) - (other[1] * X) - (other[2] * Y) - (other[3] * Z);
	}
end

function compose(self, other)
	return multiply(other, self)
end

function len(self)
	return (self[1] ^ 2 + self[2] ^ 2 + self[3] ^ 2 + self[4] ^ 2) ^ 0.5
end

function normalize(self)
	local l = len(self)
	local res = {}
	for key, value in pairs(self) do
		res[key] = value / l
	end
	return res
end

function conjugate(self)
	return {
		-self[1],
		-self[2],
		-self[3],
		self[4]
	}
end

function inverse(self)
	-- TODO this is just a fancy normalization *of the conjungate*,
	-- which for rotations is the inverse
	return modlib.vector.divide_scalar(conjugate(self), self[1] ^ 2 + self[2] ^ 2 + self[3] ^ 2 + self[4] ^ 2)
end

function negate(self)
	for key, value in pairs(self) do
		self[key] = -value
	end
end

function dot(self, other)
	return self[1] * other[1] + self[2] * other[2] + self[3] * other[3] + self[4] * other[4]
end

--: self normalized quaternion
--: other normalized quaternion
function slerp(self, other, ratio)
	local d = dot(self, other)
	if d < 0 then
		d = -d
		negate(other)
	end
	-- Threshold beyond which linear interpolation is used
	if d > 1 - 1e-10 then
		return modlib.vector.interpolate(self, other, ratio)
	end
	local theta_0 = math.acos(d)
	local theta = theta_0 * ratio
	local sin_theta = math.sin(theta)
	local sin_theta_0 = math.sin(theta_0)
	local s_1 = sin_theta / sin_theta_0
	local s_0 = math.cos(theta) - d * s_1
	return modlib.vector.add(modlib.vector.multiply_scalar(self, s_0), modlib.vector.multiply_scalar(other, s_1))
end

--> axis, angle
function to_axis_angle(self)
	local axis = modlib.vector.new{self[1], self[2], self[3]}
	local len = axis:length()
	-- HACK invert axis for correct rotation in Minetest
	return len == 0 and axis or axis:divide_scalar(-len), 2 * math.atan2(len, self[4])
end

function to_euler_rotation_rad(self)
	local rotation = {}

	local sinr_cosp = 2 * (self[4] * self[1] + self[2] * self[3])
	local cosr_cosp = 1 - 2 * (self[1] ^ 2 + self[2] ^ 2)
	rotation.x = math.atan2(sinr_cosp, cosr_cosp)

	local sinp = 2 * (self[4] * self[2] - self[3] * self[1])
	if sinp <= -1 then
		rotation.y = -math.pi/2
	elseif sinp >= 1 then
		rotation.y = math.pi/2
	else
		rotation.y = math.asin(sinp)
	end

	local siny_cosp = 2 * (self[4] * self[3] + self[1] * self[2])
	local cosy_cosp = 1 - 2 * (self[2] ^ 2 + self[3] ^ 2)
	rotation.z = math.atan2(siny_cosp, cosy_cosp)

	return rotation
end

-- TODO rename this to to_euler_rotation_deg eventually (breaking change)
--> {x = pitch, y = yaw, z = roll} euler rotation in degrees
function to_euler_rotation(self)
	return vector.apply(to_euler_rotation_rad(self), math.deg)
end

-- See https://github.com/zaki/irrlicht/blob/master/include/quaternion.h#L652
function to_euler_rotation_irrlicht(self)
	local x, y, z, w = unpack(self)
	local test = 2 * (y * w - x * z)

	local rot
	if math.abs(test - 1) <= 1e-6 then
		rot = {
			z = -2 * math.atan2(x, w),
			x = 0,
			y = math.pi/2
		}
	elseif math.abs(test + 1) <= 1e-6 then
		rot = {
				z = 2 * math.atan2(x, w),
				x = 0,
				y = math.pi/-2
			}
	else
		rot = {
			z = math.atan2(2 * (x * y + z * w), x ^ 2 - y ^ 2 - z ^ 2 + w ^ 2),
			x = math.atan2(2 * (y * z + x * w), -x ^ 2 - y ^ 2 + z ^ 2 + w ^ 2),
			y = math.asin(math.min(math.max(test, -1), 1))
		}
	end
	return vector.apply(rot, math.deg)
end

-- Export environment
return _ENV
