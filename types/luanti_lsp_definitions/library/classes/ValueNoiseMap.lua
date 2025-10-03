---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Fractal Value Noise
-- luanti/doc/lua_api.md: Class Reference > `ValueNoiseMap`

-- ------------------------------ constructors ------------------------------ --

--[[
WIPDOC
]]
---@nodiscard
---@param noiseparams core.NoiseParams
---@param size ivector|vec2i.xy
---@return core.ValueNoiseMap
function ValueNoiseMap(noiseparams, size) end

--[[
WIPDOC
]]
---@nodiscard
---@param noiseparams core.NoiseParams
---@param size ivector|vec2i.xy
---@return core.ValueNoiseMap
function core.get_value_noise_map(noiseparams, size) end

--[[
WIPDOC
]]
---@nodiscard
---@param noiseparams core.NoiseParams
---@param size ivector|vec2i.xy
---@return core.ValueNoiseMap
function PerlinNoiseMap(noiseparams, size) end

--[[
WIPDOC
]]
---@nodiscard
---@param noiseparams core.NoiseParams
---@param size ivector|vec2i.xy
---@return core.ValueNoiseMap
function core.get_perlin_noise_map(noiseparams, size) end

-- ------------------------------ ValueNoiseMap ----------------------------- --

--[[
WIPDOC
]]
---@class core.ValueNoiseMap
local ValueNoiseMap = {}

--[[
* `get_2d_map(pos)`: returns a `<size.x>` times `<size.y>` 2D array of 2D noise
  with values starting at `pos={x=,y=}`
]]
---@nodiscard
---@param pos vec2.xy
---@return number[][]
function ValueNoiseMap:get_2d_map(pos) end

--[[
* `get_3d_map(pos)`: returns a `<size.x>` times `<size.y>` times `<size.z>`
  3D array of 3D noise with values starting at `pos={x=,y=,z=}`.
]]
---@nodiscard
---@param pos vector
---@return number[][][]
function ValueNoiseMap:get_3d_map(pos) end

--[[
* `get_2d_map_flat(pos, buffer)`: returns a flat `<size.x * size.y>` element
  array of 2D noise with values starting at `pos={x=,y=}`
]]
---@nodiscard
---@param pos vec2.xy
---@return number[]
function ValueNoiseMap:get_2d_map_flat(pos) end

--[[
* `get_2d_map_flat(pos, buffer)`: returns a flat `<size.x * size.y>` element
  array of 2D noise with values starting at `pos={x=,y=}`
]]
---@nodiscard
---@param pos vec2.xy
---@param buffer number[]
---@return nil
function ValueNoiseMap:get_2d_map_flat(pos, buffer) end

--[[
* `get_3d_map_flat(pos, buffer)`: Same as `get2dMap_flat`, but 3D noise
]]
---@nodiscard
---@param pos vector
---@return number[]
function ValueNoiseMap:get_3d_map_flat(pos) end

--[[
* `get_3d_map_flat(pos, buffer)`: Same as `get2dMap_flat`, but 3D noise
]]
---@nodiscard
---@param pos vector
---@param buffer number[]
---@return nil
function ValueNoiseMap:get_3d_map_flat(pos, buffer) end

--[[
* `calc_2d_map(pos)`: Calculates the 2d noise map starting at `pos`. The result
  is stored internally.
]]
---@param pos vec2.xy
function ValueNoiseMap:calc_2d_map(pos) end

--[[
* `calc_3d_map(pos)`: Calculates the 3d noise map starting at `pos`. The result
  is stored internally.
]]
---@param pos vector
function ValueNoiseMap:calc_3d_map(pos) end

--[[
* `get_map_slice(slice_offset, slice_size, buffer)`: In the form of an array,
  returns a slice of the most recently computed noise results. The result slice
  begins at coordinates `slice_offset` and takes a chunk of `slice_size`.
  E.g., to grab a 2-slice high horizontal 2d plane of noise starting at buffer
  offset `y = 20`:
  ```lua
  noisevals = noise:get_map_slice({y=20}, {y=2})
  ```
  It is important to note that `slice_offset` offset coordinates begin at 1,
  and are relative to the starting position of the most recently calculated
  noise.
  To grab a single vertical column of noise starting at map coordinates
  `x = 1023, y=1000, z = 1000`:
  ```lua
  noise:calc_3d_map({x=1000, y=1000, z=1000})
  noisevals = noise:get_map_slice({x=24, z=1}, {x=1, z=1})
  ```
]]
---@nodiscard
---@param slice_offset vector
---@param slice_size vector
---@return number[]
function ValueNoiseMap:get_map_slice(slice_offset, slice_size, buffer) end

--[[
* `get_map_slice(slice_offset, slice_size, buffer)`: In the form of an array,
  returns a slice of the most recently computed noise results. The result slice
  begins at coordinates `slice_offset` and takes a chunk of `slice_size`.
  E.g., to grab a 2-slice high horizontal 2d plane of noise starting at buffer
  offset `y = 20`:
  ```lua
  noisevals = noise:get_map_slice({y=20}, {y=2})
  ```
  It is important to note that `slice_offset` offset coordinates begin at 1,
  and are relative to the starting position of the most recently calculated
  noise.
  To grab a single vertical column of noise starting at map coordinates
  `x = 1023, y=1000, z = 1000`:
  ```lua
  noise:calc_3d_map({x=1000, y=1000, z=1000})
  noisevals = noise:get_map_slice({x=24, z=1}, {x=1, z=1})
  ```
]]
---@nodiscard
---@param slice_offset vector
---@param slice_size vector
---@param buffer number[]
---@return nil
function ValueNoiseMap:get_map_slice(slice_offset, slice_size, buffer) end