---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Spatial Vectors

--[[
WIPDOC
]]
---@class core.VectorLib
vector = {}

-- ------------------------------ constructors ------------------------------ --

--[[
Returns a new vector `(a, b, c)`
]]
---@nodiscard
---@param a number
---@param b number
---@param c number
---@return vec
function vector.new(a, b, c) end

--[[
Returns a new vector `(a, a, a)`
]]
---@nodiscard
---@param a number
---@return vec
function vector.new(a) end

--[[
`vector.new(v)` does the same as `vector.copy(v)`
]]
---@deprecated
---@nodiscard
---@param a vector
---@return vec
function vector.new(a) end

--[[
`vector.new()` does the same as `vector.zero()`
]]
---@deprecated
---@nodiscard
---@return vec
function vector.new() end

--[[
Returns a new vector `(0, 0, 0)`
]]
---@nodiscard
---@return vec
function vector.zero() end

--[[
Returns a new vector of length 1, pointing into a direction chosen uniformly at random.
]]
---@nodiscard
---@return vec
function vector.random_direction() end

--[[
Returns a copy of the vector `v`.
]]
---@nodiscard
---@param v vector
---@return vec
function vector.copy(v) end

-- ---------------------------- string conversion --------------------------- --

--[[
Returns v, np, where v is a vector read from the given string s and np is the
next position in the string after the vector.
Returns nil on failure.
]]
---@nodiscard
---@param s string Has to begin with a substring of the form `"(x, y, z)"`. Additional spaces, leaving away commas, and adding an additional comma to the end is allowed.
---@param init number? Starts looking for the vector at this string index
---@return vec? v, integer? np
function vector.from_string(s, init) end

--[[
Returns a string of the form `"(x, y, z)"`
`tostring(v)` does the same
]]
---@nodiscard
---@param v vector
---@return vec
function vector.to_string(v) end

-- -------------------------------------------------------------------------- --

--[[
Returns a vector of length 1 with direction p1 to p2.
If p1 and p2 are identical, returns (0, 0, 0).
]]
---@nodiscard
---@param p1 vector
---@param p2 vector
---@return vec
function vector.direction(p1, p2) end

--[[
Returns zero or a positive number, the distance between p1 and p2.
]]
---@nodiscard
---@param p1 vector
---@param p2 vector
---@return number
function vector.distance(p1, p2) end

--[[
Returns zero or a positive number, the length of vector v.
]]
---@nodiscard
---@param v vector
---@return number
function vector.length(v) end

--[[
Returns a vector of length 1 with direction of vector v.
If v has zero length, returns (0, 0, 0).
]]
---@nodiscard
---@param v vector
---@return vec
function vector.normalize(v) end

-- -------------------------- rounding and signness ------------------------- --

--[[
Returns a vector, each dimension rounded down.
]]
---@nodiscard
---@param v vector
---@return ivec
function vector.floor(v) end

--[[
Returns a vector, each dimension rounded up.
]]
---@nodiscard
---@param v vector
---@return ivec
function vector.ceil(v) end

--[[
Returns a vector, each dimension rounded to the nearest integer.
At a multiple of 0.5, rounds away from zero.
]]
---@nodiscard
---@param v vector
---@return ivec
function vector.round(v) end

--[[
Returns a vector where `math.sign` was called for each component
]]
---@nodiscard
---@param v vector
---@param tolerance number?
---@return ivec
function vector.sign(v, tolerance) end

--[[
Returns a vector with absolute values for each component
]]
---@nodiscard
---@param v vector
---@return vec
function vector.abs(v) end

-- -------------------------------------------------------------------------- --

--[[
Applies `func` to each component
]]
---@nodiscard
---@param v vector
---@param func fun(n: number): number
---@param ... any Optional arguments passed to `func`
---@return vec
function vector.apply(v, func, ...) end

--[[
Returns a vector where the function `func` has combined both components of `v`
and `w` for each component
]]
---@nodiscard
---@param v vector
---@param w vector
---@param func fun(x:number, y:number):number
---@return vec
function vector.combine(v, w, func) end

--[[
Returns true if the vectors are identical, false if not
]]
---@nodiscard
---@param v1 vector
---@param v2 vector
---@return vec
function vector.equals(v1, v2) end

--[[
Returns in order minp, maxp vectors of the cuboid defined by v1, v2.
(Unofficial note: In other words, each component of the minp is smaller than component in maxp)
]]
---@nodiscard
---@param v1 vector
---@param v2 vector
---@return vec, vec
function vector.sort(v1, v2) end

-- -------------------------------------------------------------------------- --

--[[
Returns the angle between v1 and v2 in radians
]]
---@nodiscard
---@param v1 vector
---@param v2 vector
---@return number
function vector.angle(v1, v2) end

--[[
Returns the dot product
]]
---@nodiscard
---@param v1 vector
---@param v2 vector
---@return number
function vector.dot(v1, v2) end

--[[
Returns the cross product
]]
---@nodiscard
---@param v1 vector
---@param v2 vector
---@return vec
function vector.cross(v1, v2) end

--[[
Returns the sum of vectors `v` and `(x,y,z)`
]]
---@nodiscard
---@param v vector
---@param x number
---@param y number
---@param z number
---@return vec
function vector.offset(v, x, y, z) end

--[[
Checks if `v` is a vector, returns false even for tables like {x=,y=,z=}, has to be created with a vector function
]]
---@nodiscard
---@param v vector
---@return boolean
function vector.check(v) end

--[[
Checks if `pos` is inside an area formed by `min` and `max`
`min` and `max` are inclusive
If min is bigger than max on some axis, function always returns false.
You can use vector.sort if you have two vectors and don't know which are the minimum and the maximum.
]]
---@nodiscard
---@param pos vector
---@param min vector
---@param max vector
---@return boolean
function vector.in_area(pos, min, max) end

--[[
Returns a random integer position in area formed by min and max
min and max are inclusive.
You can use vector.sort if you have two vectors and don't know which are the minimum and the maximum.
]]
---@nodiscard
---@param min vector
---@param max vector
---@return vec
function vector.random_in_area(min, max) end

-- ------------------------- arithmetic and products ------------------------ --

--[[
WIPDOC
]]
---@nodiscard
---@param v vector
---@param x vector|number
---@return vec
function vector.add(v, x) end

--[[
WIPDOC
]]
---@nodiscard
---@param v vector
---@param x vector|number
---@return vec
function vector.subtract(v, x) end

--[[
WIPDOC
]]
---@nodiscard
---@param v vector
---@param x number
---@return vec
function vector.multiply(v, x) end

--[[
WIPDOC
]]
---@nodiscard
---@param v vector
---@param x number
---@return vec
function vector.divide(v, x) end

--[[
WIPDOC
]]
---@deprecated
---@nodiscard
---@param v vector
---@param x vector
---@return vec
function vector.multiply(v, x) end

--[[
WIPDOC
]]
---@deprecated
---@nodiscard
---@param v vector
---@param x vector
---@return vec
function vector.divide(v, x) end

-- ----------------------- rotation-related functions ----------------------- --

--[[
Applies the rotation r to v and returns the result.
vector.rotate(vector.new(0, 0, 1), r) and vector.rotate(vector.new(0, 1, 0), r) return vectors pointing forward and up relative to an entity's rotation r.
]]
---@nodiscard
---@param v vector
---@param r vector Rotation vector {x=<pitch>, y=<yaw>, z=<roll>}
---@return vec
function vector.rotate(v, r) end

--[[
Returns v1 rotated around axis v2 by a radians according to the right hand rule.
]]
---@nodiscard
---@param v1 vector
---@param v2 vector
---@param a number radians
---@return vec
function vector.rotate_around_axis(v1, v2, a) end

--[[
Returns a rotation vector for direction pointing forward using up as the up vector.
If up is omitted, the roll of the returned vector defaults to zero.
Otherwise direction and up need to be vectors in a 90 degree angle to each other.
]]
---@nodiscard
---@param up vector?
---@param direction vector
---@return vec
function vector.dir_to_rotation(direction, up) end