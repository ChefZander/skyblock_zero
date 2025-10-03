---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `AreaStore`

--[[
WIPDOC
]]
---@class core.AreaStoreID : integer

-- ----------------------------- AreaStore.area ----------------------------- --

--[[
WIPDOC
]]
---@class core.AreaStore.area.include_corners
--[[
WIPDOC
]]
---@field min ivec
--[[
WIPDOC
]]
---@field max ivec


--[[
WIPDOC
]]
---@class core.AreaStore.area.include_data
--[[
WIPDOC
]]
---@field data string

--[[
WIPDOC
]]
---@class core.AreaStore.area.include_all : core.AreaStore.area.include_corners, core.AreaStore.area.include_data

-- ------------------------- AreaStore.cache_params ------------------------- --

--[[
WIPDOC
]]
---@class core.AreaStore.cache_params
--[[
WIPDOC
]]
---@field enabled boolean?
--[[
WIPDOC
]]
---@field block_radius integer?
--[[
WIPDOC
]]
---@field limit integer?

-- ------------------------------- constructor ------------------------------ --

--[[
Unofficial note: I am aware that "Luanti" isn't a valid AreaStore type, but that makes it default to Luanti functions so, is it not accurate?
* `AreaStore(type_name)`
    * Returns a new AreaStore instance
    * `type_name`: optional, forces the internally used API.
        * Possible values: `"LibSpatial"` (default).
        * When other values are specified, or SpatialIndex is not available,
          the custom Luanti functions are used.
]]
---@nodiscard
---@param type "LibSpatial"|string?
---@return core.AreaStore
function AreaStore(type) end

-- -------------------------------- AreaStore ------------------------------- --

--[[
`AreaStore`
-----------

AreaStore is a data structure to calculate intersections of 3D cuboid volumes
and points. The `data` field (string) may be used to store and retrieve any
mod-relevant information to the specified area.

Despite its name, mods must take care of persisting AreaStore data. They may
use the provided load and write functions for this.

]]
---@class core.AreaStore
AreaStore = {}

--[[
WIPDOC
]]
---@nodiscard
---@param id core.AreaStoreID
---@param include_corners false?
---@param include_data false?
---@return true?
function AreaStore:get_area(id, include_corners, include_data) end

--[[
WIPDOC
]]
---@nodiscard
---@param id core.AreaStoreID
---@param include_corners true
---@param include_data false?
---@return core.AreaStore.area.include_corners?
function AreaStore:get_area(id, include_corners, include_data) end

--[[
WIPDOC
]]
---@nodiscard
---@param id core.AreaStoreID
---@param include_corners false?
---@param include_data true
---@return core.AreaStore.area.include_data?
function AreaStore:get_area(id, include_corners, include_data) end

--[[
WIPDOC
]]
---@nodiscard
---@param id core.AreaStoreID
---@param include_corners true
---@param include_data true
---@return core.AreaStore.area.include_all?
function AreaStore:get_area(id, include_corners, include_data) end

--[[
WIPDOC
]]
---@nodiscard
---@param id core.AreaStoreID
---@param include_corners false?
---@param include_data false?
---@return table<core.AreaStoreID, true?>
function AreaStore:get_areas_for_pos(id, include_corners, include_data) end

--[[
WIPDOC
]]
---@nodiscard
---@param id core.AreaStoreID
---@param include_corners true
---@param include_data false?
---@return table<core.AreaStoreID, core.AreaStore.area.include_corners?>
function AreaStore:get_areas_for_pos(id, include_corners, include_data) end

--[[
WIPDOC
]]
---@nodiscard
---@param id core.AreaStoreID
---@param include_corners false?
---@param include_data true
---@return table<core.AreaStoreID, core.AreaStore.area.include_data?>
function AreaStore:get_areas_for_pos(id, include_corners, include_data) end

--[[
WIPDOC
]]
---@nodiscard
---@param id core.AreaStoreID
---@param include_corners true
---@param include_data true
---@return table<core.AreaStoreID, core.AreaStore.area.include_all?>
function AreaStore:get_areas_for_pos(id, include_corners, include_data) end

--[[
WIPDOC
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@param accept_overlap boolean
---@param include_corners false?
---@param include_data false?
---@return table<core.AreaStoreID, true?>
function AreaStore:get_areas_in_area(pos1, pos2, accept_overlap, include_corners, include_data) end

--[[
WIPDOC
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@param accept_overlap boolean
---@param include_corners true
---@param include_data false?
---@return table<core.AreaStoreID, core.AreaStore.area.include_corners?>
function AreaStore:get_areas_in_area(pos1, pos2, accept_overlap, include_corners, include_data) end

--[[
WIPDOC
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@param accept_overlap boolean
---@param include_corners false?
---@param include_data true
---@return table<core.AreaStoreID, core.AreaStore.area.include_data?>
function AreaStore:get_areas_in_area(pos1, pos2, accept_overlap, include_corners, include_data) end

--[[
WIPDOC
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@param accept_overlap boolean
---@param include_corners true
---@param include_data true
---@return table<core.AreaStoreID, core.AreaStore.area.include_all?>
function AreaStore:get_areas_in_area(pos1, pos2, accept_overlap, include_corners, include_data) end

--[[
* `insert_area(corner1, corner2, data, [id])`: inserts an area into the store.
    * Returns the new area's ID, or nil if the insertion failed.
    * The (inclusive) positions `corner1` and `corner2` describe the area.
    * `data` is a string stored with the area.
    * `id` (optional): will be used as the internal area ID if it is a unique
      number between 0 and 2^32-2.
]]
---@nodiscard
---@param corner1 ivector
---@param corner2 ivector
---@param data string
---@param id core.AreaStoreID?
---@return core.AreaStoreID?
function AreaStore:insert_area(corner1, corner2, data, id) end

--[[
* `reserve(count)`
    * Requires SpatialIndex, no-op function otherwise.
    * Reserves resources for `count` many contained areas to improve
      efficiency when working with many area entries. Additional areas can still
      be inserted afterwards at the usual complexity.
]]
---@param count integer
function AreaStore:reserve(count) end

--[[
* `remove_area(id)`: removes the area with the given id from the store, returns
  success.
]]
---@nodiscard
---@param id core.AreaStoreID
---@return boolean
function AreaStore:remove_area(id) end

--[[
* `set_cache_params(params)`: sets params for the included prefiltering cache.
  Calling invalidates the cache, so that its elements have to be newly
  generated.
    * `params` is a table with the following fields:
      ```lua
      {
          enabled = boolean,   -- Whether to enable, default true
          block_radius = int,  -- The radius (in nodes) of the areas the cache
                               -- generates prefiltered lists for, minimum 16,
                               -- default 64
          limit = int,         -- The cache size, minimum 20, default 1000
      }
      ```
]]
---@param params core.AreaStore.cache_params
function AreaStore:set_cache_params(params) end

--[[
* `to_string()`: Experimental. Returns area store serialized as a (binary)
  string.
]]
---@nodiscard
---@return string
function AreaStore:to_string() end

--[[
* `to_file(filename)`: Experimental. Like `to_string()`, but writes the data to
  a file.
]]
---@param filename core.Path
function AreaStore:to_file(filename) end

--[[
* `from_string(str)`: Experimental. Deserializes string and loads it into the
  AreaStore.
  Returns success and, optionally, an error message.
]]
---@param str string
function AreaStore:from_string(str) end

--[[
* `from_file(filename)`: Experimental. Like `from_string()`, but reads the data
  from a file.
]]
---@param filename core.Path
function AreaStore:from_file(filename) end