---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Map terminology and coordinates
-- luanti/doc/lua_api.md: Lua Voxel Manipulator
-- luanti/doc/lua_api.md: 'core' namespace reference > Environment access
-- luanti/doc/lua_api.md: Class reference > `VoxelManip`

--[[
WIPDOC
]]
core.MAP_BLOCKSIZE = 16

--[[
WIPDOC
]]
---@class core.ContentID: integer

--[[
WIPDOC
]]
---@type core.ContentID
core.CONTENT_UNKNOWN = 125

--[[
WIPDOC
]]
---@type core.ContentID
core.CONTENT_AIR = 126

--[[
WIPDOC
]]
---@type core.ContentID
core.CONTENT_IGNORE = 127

-- ---------------------------- VoxelManip.light ---------------------------- --

--[[
WIPDOC
]]
---@class core.VoxelManip.light
local VoxelManipLight = {}

--[[
WIPDOC
]]
---@type core.Light.part
VoxelManipLight.day = nil

--[[
WIPDOC
]]
---@type core.Light.part
VoxelManipLight.night = nil

-- ------------------------------- constructor ------------------------------ --

--[[
WIPDOC
]]
---@nodiscard
---@param p1 ivector?
---@param p2 ivector?
---@return core.VoxelManip
function VoxelManip(p1, p2) end

--[[
WIPDOC
]]
---@nodiscard
---@param p1 ivector?
---@param p2 ivector?
---@return core.VoxelManip
function core.get_voxel_manip(p1, p2) end

-- ------------------------------- VoxelManip ------------------------------- --

--[[
Unofficial note: Building the next worldedit eh?

About VoxelManip
----------------

VoxelManip is a scripting interface to the internal 'Map Voxel Manipulator'
facility. The purpose of this object is for fast, low-level, bulk access to
reading and writing Map content. As such, setting map nodes through VoxelManip
will lack many of the higher level features and concepts you may be used to
with other methods of setting nodes. For example, nodes will not have their
construction and destruction callbacks run, and no rollback information is
logged.

It is important to note that VoxelManip is designed for speed, and *not* ease
of use or flexibility. If your mod requires a map manipulation facility that
will handle 100% of all edge cases, or the use of high level node placement
features, perhaps `core.set_node()` is better suited for the job.

In addition, VoxelManip might not be faster, or could even be slower, for your
specific use case. VoxelManip is most effective when setting large areas of map
at once - for example, if only setting a 3x3x3 node area, a
`core.set_node()` loop may be more optimal. Always profile code using both
methods of map manipulation to determine which is most appropriate for your
usage.

A recent simple test of setting cubic areas showed that `core.set_node()`
is faster than a VoxelManip for a 3x3x3 node cube or smaller.
]]
---@class core.VoxelManip
local VoxelManip = {}

--[[
* `read_from_map(p1, p2)`: Loads a part of the map into the VoxelManip object
  containing the region formed by `p1` and `p2`.
    * returns actual emerged `pmin`, actual emerged `pmax` (MapBlock-aligned)
    * Note that calling this multiple times will *add* to the area loaded in the
      VoxelManip, and not reset it.
]]
---@nodiscard
---@param p1 ivector
---@param p2 ivector
---@return ivec pmin, ivec pmax
function VoxelManip:read_from_map(p1, p2) end

--[[
* `initialize(p1, p2, [node])`: Clears and resizes the VoxelManip object to
  comprise the region formed by `p1` and `p2`.
   * **No data** is read from the map, so you can use this to treat `VoxelManip`
     objects as general containers of node data.
   * `node`: if present the data will be filled with this node; if not it will
     be uninitialized
   * returns actual emerged `pmin`, actual emerged `pmax` (MapBlock-aligned)
   * (introduced in 5.13.0)
]]
---@nodiscard
---@param p1 ivector
---@param p2 ivector
---@param node core.Node.set
---@return ivec pmin, ivec pmax
function VoxelManip:initialize(p1, p2, node) end

--[[
Unofficial note: If you can, try to not use this function for performance reasons (there is no alternative, but you can avoid using it by checking if vmanip data was modified, if yes then use it)

* `write_to_map([light])`: Writes the data loaded from the `VoxelManip` back to
  the map.
    * **important**: you should call `set_data()` before this, or nothing will change.
    * if `light` is true, then lighting is automatically recalculated.
      The default value is true.
      If `light` is false, no light calculations happen, and you should correct
      all modified blocks with `core.fix_light()` as soon as possible.
      Keep in mind that modifying the map where light is incorrect can cause
      more lighting bugs.
]]
---@param light boolean?
function VoxelManip:write_to_map(light) end

--[[
Unofficial note: i don't think you should be using this for performance reasons, this is a function i would personally NEVER use
]]
---@nodiscard
---@param pos ivector
---@return core.Node.get
function VoxelManip:get_node_at(pos) end

--[[
Unofficial note: i don't think you should be using this for performance reasons, this is a function i would personally NEVER use
]]
---@param pos ivector
---@param node core.Node.set
function VoxelManip:set_node_at(pos, node) end

--[[
Retrieves the node content data loaded into the `VoxelManip` object, the `data` table will be used to store the result
]]
---@param data core.ContentID[]
---@return nil
function VoxelManip:get_data(data) end

--[[
Retrieves the node content data loaded into the `VoxelManip` object and returns it
Unofficial note: I would recommend doing VoxelManip.get_data(data) instead, as this form will make the garbage collector scream, in a way that you can't profile very well
]]
---@nodiscard
---@return core.ContentID[] data
function VoxelManip:get_data() end

--[[
WIPDOC
]]
---@param data core.ContentID[]
---@return nil
function VoxelManip:set_data(data) end

--[[
Unofficial note: In need of a noop? Instead of depending on modlib to do it, how
about using this pre-made function baked into the luanti api, written most
likely in C for super fast noop
Does nothing, kept for compatibility.
]]
---@deprecated
function VoxelManip:update_map() end

--[[
* `set_lighting(light, [p1, p2])`: Set the lighting within the `VoxelManip` to
  a uniform value.
    * `light` is a table, `{day=<0...15>, night=<0...15>}`
    * To be used only by a `VoxelManip` object from
      `core.get_mapgen_object`.
    * (`p1`, `p2`) is the area in which lighting is set, defaults to the whole
      area if left out.
]]
---@param light core.VoxelManip.light
---@param p1 ivector?
---@param p2 ivector?
function VoxelManip:set_lighting(light, p1, p2) end

--[[
* `get_light_data([buffer])`: Gets the light data read into the
  `VoxelManip` object
    * Returns an array (indices 1 to volume) of integers ranging from `0` to
      `255`.
    * Each value is the bitwise combination of day and night light values
      (`0` to `15` each).
    * `light = day + (night * 16)`
    * If the param `buffer` is present, this table will be used to store the
      result instead.
]]
---@param buffer core.Light[]
---@return nil
function VoxelManip:get_light_data(buffer) end

--[[
* `get_light_data([buffer])`: Gets the light data read into the
  `VoxelManip` object
    * Returns an array (indices 1 to volume) of integers ranging from `0` to
      `255`.
    * Each value is the bitwise combination of day and night light values
      (`0` to `15` each).
    * `light = day + (night * 16)`
    * If the param `buffer` is present, this table will be used to store the
      result instead.
]]
---@nodiscard
---@return core.Light[] light_data
function VoxelManip:get_light_data() end

--[[
* `set_light_data(light_data)`: Sets the `param1` (light) contents of each node
  in the `VoxelManip`.
    * expects lighting data in the same format that `get_light_data()` returns
]]
---@param light_data core.Light[]
function VoxelManip:set_light_data(light_data) end

--[[
WIPDOC
]]
---@nodiscard
---@return core.Param2[] param2_data
function VoxelManip:get_param2_data() end

--[[
WIPDOC
]]
---@param buffer core.Param2[]?
---@return nil
function VoxelManip:get_param2_data(buffer) end

--[[
WIPDOC
]]
---@param param2_data core.Param2[]
function VoxelManip:set_param2_data(param2_data) end

--[[
* `calc_lighting([p1, p2], [propagate_shadow])`:  Calculate lighting within the
  `VoxelManip`.
    * To be used only with a `VoxelManip` object from `core.get_mapgen_object`.
    * (`p1`, `p2`) is the area in which lighting is set, defaults to the whole
      area if left out or nil. For almost all uses these should be left out
      or nil to use the default.
    * `propagate_shadow` is an optional boolean deciding whether shadows in a
      generated mapchunk above are propagated down into the mapchunk, defaults
      to `true` if left out.
]]
---@param p1 vector?
---@param p2 vector?
---@param propagate_shadow boolean?
function VoxelManip:calc_lighting(p1, p2, propagate_shadow) end

--[[
WIPDOC
]]
function VoxelManip:update_liquids() end

--[[
* `was_modified()`: Returns `true` if the data in the VoxelManip has been modified
   since it was last read from the map. This means you have to call `get_data()` again.
   This only applies to a `VoxelManip` object from `core.get_mapgen_object`,
   where the engine will keep the map and the VM in sync automatically.
   * Note: this doesn't do what you think it does and is subject to removal. Don't use it!
]]
---@deprecated
---@nodiscard
---@return boolean
function VoxelManip:was_modified() end

--[[
* `get_emerged_area()`: Returns actual emerged minimum and maximum positions.
* "Emerged" does not imply that this region was actually loaded from the map,
   if `initialize()` has been used.
]]
---@nodiscard
---@return ivec emin, ivec emax
function VoxelManip:get_emerged_area() end

--[[
* `close()`: Frees the data buffers associated with the VoxelManip object.
   It will become empty.
   * Since Lua's garbage collector is not aware of the potentially significant
     memory behind a VoxelManip, frequent VoxelManip usage can cause the server to
     run out of RAM. Therefore it's recommend to call this method once you're done
     with the VoxelManip.
   * (introduced in 5.13.0)
]]
function VoxelManip:close() end
