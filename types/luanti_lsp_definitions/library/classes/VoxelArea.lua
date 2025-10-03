---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Map terminology and coordinates
-- luanti/doc/lua_api.md: Lua Voxel Manipulator
-- luanti/doc/lua_api.md: Class reference > `VoxelArea`

-- ------------------------------- constructor ------------------------------ --

--[[
WIPDOC
]]
---@nodiscard
---@param pmin ivector
---@param pmax ivector
---@return VoxelArea
function VoxelArea(pmin, pmax) end

--[[
WIPDOC
]]
---@nodiscard
---@param arg {MinEdge:ivector, MaxEdge:ivector}
---@return VoxelArea
function VoxelArea:new(arg) end

-- -------------------------------- VoxelArea ------------------------------- --

--[[
WIPDOC
]]
---@class VoxelArea
VoxelArea = {}

--[[
WIPDOC
]]
---@nodiscard
---@return ivec
function VoxelArea:getExtent() end

--[[
WIPDOC
]]
---@nodiscard
---@return integer
function VoxelArea:getVolume() end

--[[
* `index(x, y, z)`: returns the index of an absolute position in a flat array
  starting at `1`.
    * `x`, `y` and `z` must be integers to avoid an incorrect index result.
    * The position (x, y, z) is not checked for being inside the area volume,
      being outside can cause an incorrect index result.
    * Useful for things like `VoxelManip`, raw Schematic specifiers,
      `ValueNoiseMap:get2d`/`3dMap`, and so on.
]]
---@nodiscard
---@param x integer
---@param y integer
---@param z integer
---@return integer i
function VoxelArea:index(x, y, z) end

--[[
* `indexp(p)`: same functionality as `index(x, y, z)` but takes a vector.
    * As with `index(x, y, z)`, the components of `p` must be integers, and `p`
      is not checked for being inside the area volume.
]]
---@nodiscard
---@param p ivector
---@return integer i
function VoxelArea:indexp(p) end

--[[
* `position(i)`: returns the absolute position vector corresponding to index
  `i`.
]]
---@nodiscard
---@param i integer
---@return ivec p
function VoxelArea:position(i) end

--[[
WIPDOC
]]
---@nodiscard
---@param x number
---@param y number
---@param z number
---@return boolean
function VoxelArea:contains(x, y, z) end

--[[
WIPDOC
]]
---@nodiscard
---@param p vector
---@return boolean
function VoxelArea:containsp(p) end

--[[
WIPDOC
]]
---@nodiscard
---@param i integer
---@return boolean
function VoxelArea:containsi(i) end

--[[
WIPDOC
]]
---@nodiscard
---@param minx integer
---@param miny integer
---@param minz integer
---@param maxx integer
---@param maxy integer
---@param maxz integer
---@return fun():integer?
function VoxelArea:iter(minx, miny, minz, maxx, maxy, maxz) end

--[[
WIPDOC
]]
---@nodiscard
---@param minp ivector
---@param maxp ivector
---@return fun():integer?
function VoxelArea:iterp(minp, maxp) end
