---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Fractal Value Noise
-- luanti/doc/lua_api.md: 'core' namespace reference > Environment access
-- luanti/doc/lua_api.md: Class Reference > `ValueNoise`

-- ------------------------------ constructors ------------------------------ --

--[[
`ValueNoise`
-------------

A value noise generator.
It can be created via `ValueNoise()` or `core.get_value_noise()`.
For `core.get_value_noise()`, the actual seed used is the noiseparams seed
plus the world seed, to create world-specific noise.

**Important**: These require the mapgen environment to be initalized, do not use at load time.

* `ValueNoise(noiseparams)`
* `ValueNoise(seed, octaves, persistence, spread)` (deprecated)
* `core.get_value_noise(noiseparams)`
* `core.get_value_noise(seeddiff, octaves, persistence, spread)` (deprecated)

These were previously called `PerlinNoise()` and `core.get_perlin()`, but the
implemented noise was not Perlin noise. They were renamed in 5.12.0. The old
names still exist as aliases.
]]
---@nodiscard
---@param noiseparams core.NoiseParams
---@return core.ValueNoise
function ValueNoise(noiseparams) end

--[[
WIPDOC
]]
---@nodiscard
---@param noiseparams core.NoiseParams
---@return core.ValueNoise
function PerlinNoise(noiseparams) end

--[[
* `core.get_value_noise(noiseparams)`
    * Return world-specific value noise.
    * The actual seed used is the noiseparams seed plus the world seed.
    * **Important**: Requires the mapgen environment to be initalized, do not use at load time.
]]
---@nodiscard
---@param noiseparams core.NoiseParams
---@return core.ValueNoise
function core.get_value_noise(noiseparams) end

--[[
* `core.get_perlin(noiseparams)`
    * Deprecated: renamed to `core.get_value_noise` in version 5.12.0.
]]
---@deprecated
---@nodiscard
---@param noiseparams core.NoiseParams
---@return core.ValueNoise
function core.get_perlin(noiseparams) end

-- ---------------------------- old constructors ---------------------------- --

--[[
`ValueNoise`
-------------

A value noise generator.
It can be created via `ValueNoise()` or `core.get_value_noise()`.
For `core.get_value_noise()`, the actual seed used is the noiseparams seed
plus the world seed, to create world-specific noise.

**Important**: These require the mapgen environment to be initalized, do not use at load time.

* `ValueNoise(noiseparams)`
* `ValueNoise(seed, octaves, persistence, spread)` (deprecated)
* `core.get_value_noise(noiseparams)`
* `core.get_value_noise(seeddiff, octaves, persistence, spread)` (deprecated)

These were previously called `PerlinNoise()` and `core.get_perlin()`, but the
implemented noise was not Perlin noise. They were renamed in 5.12.0. The old
names still exist as aliases.
]]
---@deprecated
---@nodiscard
---@param seeddiff integer
---@param octaves integer
---@param persistence number
---@param spread vector|vec2.xy
---@return core.ValueNoise
function ValueNoise(seeddiff, octaves, persistence, spread) end

--[[
WIPDOC
]]
---@deprecated
---@nodiscard
---@param seeddiff integer
---@param octaves integer
---@param persistence number
---@param spread vector|vec2.xy
---@return core.ValueNoise
function PerlinNoise(seeddiff, octaves, persistence, spread) end

--[[
* `core.get_value_noise(seeddiff, octaves, persistence, spread)`
    * Deprecated: use `core.get_value_noise(noiseparams)` instead.
]]
---@deprecated
---@nodiscard
---@param seeddiff integer
---@param octaves integer
---@param persistence number
---@param spread vector|vec2.xy
---@return core.ValueNoise
function core.get_value_noise(seeddiff, octaves, persistence, spread) end

--[[
* `core.get_perlin(seeddiff, octaves, persistence, spread)`
    * Deprecated: renamed to `core.get_value_noise` in version 5.12.0.
]]
---@deprecated
---@nodiscard
---@param seeddiff integer
---@param octaves integer
---@param persistence number
---@param spread vector|vec2.xy
---@return core.ValueNoise
function core.get_perlin(seeddiff, octaves, persistence, spread) end

-- ------------------------------- ValueNoise ------------------------------- --

--[[
`ValueNoise`
-------------

A value noise generator.
It can be created via `ValueNoise()` or `core.get_value_noise()`.
For `core.get_value_noise()`, the actual seed used is the noiseparams seed
plus the world seed, to create world-specific noise.

**Important**: These require the mapgen environment to be initalized, do not use at load time.

* `ValueNoise(noiseparams)`
* `ValueNoise(seed, octaves, persistence, spread)` (deprecated)
* `core.get_value_noise(noiseparams)`
* `core.get_value_noise(seeddiff, octaves, persistence, spread)` (deprecated)

These were previously called `PerlinNoise()` and `core.get_perlin()`, but the
implemented noise was not Perlin noise. They were renamed in 5.12.0. The old
names still exist as aliases.
]]
---@class core.ValueNoise
local ValueNoise = {}

--[[
* `get_2d(pos)`: returns 2D noise value at `pos={x=,y=}`
]]
---@nodiscard
---@param pos vec2.xy
---@return vec2.xy
function ValueNoise:get_2d(pos) end

--[[
* `get_3d(pos)`: returns 3D noise value at `pos={x=,y=,z=}`
]]
---@nodiscard
---@param pos vector
---@return vec
function ValueNoise:get_3d(pos) end