---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Environment access

-- ---------------------------------- node ---------------------------------- --

--[[
* `core.set_node(pos, node)`
    * Set node at position `pos`.
    * Any existing metadata is deleted.
    * `node`: table `{name=string, param1=number, param2=number}`
      If param1 or param2 is omitted, it's set to `0`.
    * e.g. `core.set_node({x=0, y=10, z=0}, {name="default:wood"})`
]]
---@param pos ivector
---@param node core.Node.set
function core.set_node(pos, node) end

--[[
Alias to core.set_node
Unofficial note: I think you should be strict and only use `core.set_node`
]]
core.add_node = core.set_node

--[[
WIPDOC
]]
---@param posarr ivector[]
---@param node core.Node.set
function core.bulk_set_node(posarr, node) end

--[[
* `core.swap_node(pos, node)`
    * Swap node at position with another.
    * This keeps the metadata intact and will not run con-/destructor callbacks.
]]
---@param pos ivector
---@param node core.Node.set
function core.swap_node(pos, node) end

--[[
* `core.bulk_swap_node({pos1, pos2, pos3, ...}, node)`
    * Equivalent to `core.swap_node` but in bulk.
]]
---@param posarr ivector[]
---@param node core.Node.set
function core.bulk_swap_node(posarr, node) end

--[[
* `core.remove_node(pos)`: Remove a node
    * Equivalent to `core.set_node(pos, {name="air"})`, but a bit faster.
]]
---@param pos ivector
function core.remove_node(pos) end

--[[
* `core.get_node(pos)`
    * Returns the node at the given position as table in the same format as `set_node`.
    * This function never returns `nil` and instead returns
      `{name="ignore", param1=0, param2=0}` for unloaded areas.
]]
---@nodiscard
---@param pos ivector
---@return core.Node.set
function core.get_node(pos) end

--[[
* `core.get_node_or_nil(pos)`
    * Same as `get_node` but returns `nil` for unloaded areas.
    * Note that even loaded areas can contain "ignore" nodes.
]]
---@nodiscard
---@param pos ivector
---@return core.Node.get?
function core.get_node_or_nil(pos) end

--[[
* `core.get_node_raw(x, y, z)`
    * Same as `get_node` but a faster low-level API
    * Returns `content_id`, `param1`, `param2`, and `pos_ok`
    * The `content_id` can be mapped to a name using `core.get_name_from_content_id()`
    * If `pos_ok` is false, the area is unloaded and `content_id == core.CONTENT_IGNORE`
]]
---@nodiscard
---@param x integer
---@param y integer
---@param z integer
---@return core.ContentID content_id, core.Param1 param1, core.Param2 param2, boolean pos_ok
function core.get_node_raw(x, y, z) end

--[[
* `core.get_node_light(pos[, timeofday])`
    * Gets the light value at the given position. Note that the light value
      "inside" the node at the given position is returned, so you usually want
      to get the light value of a neighbor.
    * `pos`: The position where to measure the light.
    * `timeofday`: `nil` for current time, `0` for night, `0.5` for day
    * Returns a number between `0` and `15` or `nil`
    * `nil` is returned e.g. when the map isn't loaded at `pos`
]]
---@nodiscard
---@param pos ivector
---@param timeofday number?
---@return core.Light.part?
function core.get_node_light(pos, timeofday) end

--[[
* `core.get_natural_light(pos[, timeofday])`
    * Figures out the sunlight (or moonlight) value at pos at the given time of
      day.
    * `pos`: The position of the node
    * `timeofday`: `nil` for current time, `0` for night, `0.5` for day
    * Returns a number between `0` and `15` or `nil`
    * This function tests 203 nodes in the worst case, which happens very
      unlikely
]]
---@param pos ivector
---@param timeofday number?
---@return core.Light.part?
function core.get_natural_light(pos, timeofday) end

--[[
* `core.get_artificial_light(param1)`
    * Calculates the artificial light (light from e.g. torches) value from the
      `param1` value.
    * `param1`: The param1 value of a `paramtype = "light"` node.
    * Returns a number between `0` and `15`
    * Currently it's the same as `math.floor(param1 / 16)`, except that it
      ensures compatibility.
]]
---@nodiscard
---@param param1 core.Param1
---@return core.Light.part
function core.get_artificial_light(param1) end

--[[
* `core.place_node(pos, node[, placer])`
    * Place node with the same effects that a player would cause
    * `placer`: The ObjectRef that places the node (optional)
]]
---@nodiscard
---@param pos ivector
---@param node core.Node.get
---@param placer core.PlayerRef?
---@return boolean
function core.place_node(pos, node, placer) end

--[[
* `core.dig_node(pos[, digger])`
    * Dig node with the same effects that a player would cause
    * `digger`: The ObjectRef that digs the node (optional)
    * Returns `true` if successful, `false` on failure (e.g. protected location)
]]
---@nodiscard
---@param pos ivector
---@param digger core.PlayerRef?
---@return boolean
function core.dig_node(pos, digger) end

--[[
* `core.punch_node(pos[, puncher])`
    * Punch node with the same effects that a player would cause
    * `puncher`: The ObjectRef that punches the node (optional)
]]
---@nodiscard
---@param pos ivector
---@param puncher core.PlayerRef?
---@return boolean
function core.punch_node(pos, puncher) end

--[[
* `core.spawn_falling_node(pos)`
    * Change node into falling node
    * Returns `true` and the ObjectRef of the spawned entity if successful, `false` on failure
]]
---@nodiscard
---@param pos ivector
---@return boolean
function core.spawn_falling_node(pos) end

--[[
* `core.find_nodes_with_meta(pos1, pos2)`
    * Get a table of positions of nodes that have metadata within a region
      {pos1, pos2}.
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@return vec[]
function core.find_nodes_with_meta(pos1, pos2) end

--[[
WIPDOC
]]
---@nodiscard
---@param pos ivector
---@return core.NodeMetaRef
function core.get_meta(pos) end

--[[
WIPDOC
]]
---@nodiscard
---@param pos ivector
---@return core.NodeTimerRef
function core.get_node_timer(pos) end

-- --------------------------------- entity --------------------------------- --

--[[
* `core.add_entity(pos, name, [staticdata])`: Spawn Lua-defined entity at
  position.
    * Returns `ObjectRef`, or `nil` if failed
    * Entities with `static_save = true` can be added also
      to unloaded and non-generated blocks.
]]
---@nodiscard
---@param pos vector
---@param name string
---@param staticdata string?
---@return core.EntityRef?
function core.add_entity(pos, name, staticdata) end

--[[
* `core.add_item(pos, item)`: Spawn item
    * Returns `ObjectRef`, or `nil` if failed
    * Items can be added also to unloaded and non-generated blocks.
]]
---@nodiscard
---@param pos vector
---@param item core.Item
---@return core.EntityRef?
function core.add_item(pos, item) end

--[[
* `core.get_player_by_name(name)`: Get an `ObjectRef` to a player
    * Returns nothing in case of error (player offline, doesn't exist, ...).
]]
---@nodiscard
---@param name string
---@return core.PlayerRef?
function core.get_player_by_name(name) end

--[[
* `core.get_objects_inside_radius(center, radius)`
    * returns a list of ObjectRefs
    * `radius`: using a Euclidean metric
    * **Warning**: Any kind of interaction with the environment or other APIs
      can cause later objects in the list to become invalid while you're iterating it.
      (e.g. punching an entity removes its children)
      It is recommended to use `core.objects_inside_radius` instead, which
      transparently takes care of this possibility.
]]
---@nodiscard
---@param center vector
---@param radius number
---@return core.ObjectRef[]
function core.get_objects_inside_radius(center, radius) end

--[[
* `core.objects_inside_radius(center, radius)`
    * returns an iterator of valid objects
    * example: `for obj in core.objects_inside_radius(center, radius) do obj:punch(...) end`
]]
---@nodiscard
---@param center vector
---@param radius number
---@return fun():core.ObjectRef?
function core.objects_inside_radius(center, radius) end

--[[
* `core.get_objects_in_area(min_pos, max_pos)`
    * returns a list of ObjectRefs
    * `min_pos` and `max_pos` are the min and max positions of the area to search
    * **Warning**: The same warning as for `core.get_objects_inside_radius` applies.
      Use `core.objects_in_area` instead to iterate only valid objects.
]]
---@nodiscard
---@param minp vector
---@param maxp vector
---@return core.ObjectRef[]
function core.get_objects_in_area(minp, maxp) end

--[[
* `core.objects_in_area(min_pos, max_pos)`
    * returns an iterator of valid objects
]]
---@nodiscard
---@param minp vector
---@param maxp vector
---@return fun():core.ObjectRef?
function core.objects_in_area(minp, maxp) end

-- ---------------------------------- time ---------------------------------- --

--[[
WIPDOC
]]
---@param val number
function core.set_timeofday(val) end

--[[
* `core.get_timeofday()`: get time of day
]]
---@nodiscard
---@return number
function core.get_timeofday() end

--[[
* `core.get_gametime()`: returns the time, in seconds, since the world was
  created. The time is not available (`nil`) before the first server step.
]]
---@nodiscard
---@return number?
function core.get_gametime() end

--[[
* `core.get_day_count()`: returns number days elapsed since world was
  created.
    * Time changes are accounted for.
]]
---@nodiscard
---@return integer
function core.get_day_count() end

-- -------------------------------- find node ------------------------------- --

--[[
Unofficial note: I think this function is a lot laggier than the alternatives
If you are simply trying to check if a node is in a big area, use `core.find_nodes_in_area`
Anyway, someone will need to fact check me on that claim! Anyway: The actual docs:
But you can notice that it doesn't have that pesky volume limit, so it's implemented differently

* `core.find_node_near(pos, radius, nodenames, [search_center])`: returns
  pos or `nil`.
    * `radius`: using a maximum metric
    * `nodenames`: e.g. `{"ignore", "group:tree"}` or `"default:dirt"`
    * `search_center` is an optional boolean (default: `false`)
      If true `pos` is also checked for the nodes
]]
---@nodiscard
---@param pos ivector
---@param radius integer
---@param nodenames OneOrMany<core.Node.namelike>
---@param search_center boolean?
---@return vec?
function core.find_node_near(pos, radius, nodenames, search_center) end

--[[
* `core.find_nodes_in_area(pos1, pos2, nodenames, [grouped])`
    * `pos1` and `pos2` are the min and max positions of the area to search.
    * `nodenames`: e.g. `{"ignore", "group:tree"}` or `"default:dirt"`
    * If `grouped` is true the return value is a table indexed by node name
      which contains lists of positions.
    * If `grouped` is false or absent the return values are as follows:
      first value: Table with all node positions
      second value: Table with the count of each node with the node name
      as index
    * Area volume is limited to 150,000,000 nodes
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@param nodenames OneOrMany<core.Node.namelike>
---@param grouped true
---@return table<core.Node.name, ivec[]>
function core.find_nodes_in_area(pos1, pos2, nodenames, grouped) end

--[[
WIPDOC
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@param nodenames OneOrMany<core.Node.namelike>
---@param grouped false?
---@return ivec[], table<core.Node.name, integer>
function core.find_nodes_in_area(pos1, pos2, nodenames, grouped) end

--[[
* `core.find_nodes_in_area_under_air(pos1, pos2, nodenames)`: returns a
  list of positions.
    * `nodenames`: e.g. `{"ignore", "group:tree"}` or `"default:dirt"`
    * Return value: Table with all node positions with a node air above
    * Area volume is limited to 150,000,000 nodes
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@param nodenames OneOrMany<core.Node.namelike>
---@return ivec[]
function core.find_nodes_in_area_under_air(pos1, pos2, nodenames) end

-- ---------------------- mapblocks and map generation ---------------------- --

--[[ core.get_value_noise() .. core.get_perlin() split off into library/classes/ValueNoise.lua ]]--

--[[ core.get_voxel_manip() split off into library/classes/VoxelManip.lua ]]--

--[[
* `core.set_gen_notify(flags, [deco_ids], [custom_ids])`
    * Set the types of on-generate notifications that should be collected.
    * `flags`: flag field, see [`gennotify`] for available generation notification types.
    * The following parameters are optional:
    * `deco_ids` is a list of IDs of decorations which notification
      is requested for.
    * `custom_ids` is a list of user-defined IDs (strings) which are
      requested. By convention these should be the mod name with an optional
      colon and specifier added, e.g. `"default"` or `"default:dungeon_loot"`
]]
---@param flags core.GenNotify.flags
---@param deco_ids core.DecorationID[]?
---@param custom_ids string[]?
function core.set_gen_notify(flags, deco_ids, custom_ids) end

--[[
* `core.get_gen_notify()`
    * Returns a flagstring, a table with the `deco_id`s and a table with
      user-defined IDs.
]]
---@nodiscard
---@return core.GenNotify.flags.stringfmt flags, core.DecorationID[] deco_ids, string[] custom_ids
function core.get_gen_notify() end

--[[
WIPDOC
]]
---@nodiscard
---@param decoration_name string
---@return core.DecorationID?
function core.get_decoration_id(decoration_name) end

--[[
WIPDOC
]]
---@nodiscard
---@param objectname "voxelmanip"
---@return core.VoxelManip, ivec emin, ivec emax
function core.get_mapgen_object(objectname) end

--[[
WIPDOC
]]
---@nodiscard
---@param objectname "heightmap"
---@return integer[]
function core.get_mapgen_object(objectname) end

--[[
WIPDOC
]]
---@nodiscard
---@param objectname "biomemap"
---@return core.BiomeID[]
function core.get_mapgen_object(objectname) end

--[[
WIPDOC
]]
---@nodiscard
---@param objectname "heatmap"
---@return number[]
function core.get_mapgen_object(objectname) end

--[[
WIPDOC
]]
---@nodiscard
---@param objectname "humiditymap"
---@return number[]
function core.get_mapgen_object(objectname) end

--[[
WIPDOC
]]
---@nodiscard
---@param objectname "gennotify"
---@return core.GenNotify
function core.get_mapgen_object(objectname) end

--[[
Unofficial note: this relates to the biome heat, idk override it and make your own custom mapgen if you dare
* `core.get_heat(pos)`
    * Returns the heat at the position, or `nil` on failure.
]]
---@nodiscard
---@param pos ivector
---@return number?
function core.get_heat(pos) end

--[[
Unofficial note: this relates to the biome humidity, idk override it and make your own custom mapgen if you dare
* `core.get_humidity(pos)`
    * Returns the humidity at the position, or `nil` on failure.
]]
---@nodiscard
---@param pos ivector
---@return number?
function core.get_humidity(pos) end

--[[ core.get_biome_data() split off into ./biome_data.lua ]]--

--[[
* `core.get_biome_id(biome_name)`
    * Returns the biome id, as used in the biomemap Mapgen object and returned
      by `core.get_biome_data(pos)`, for a given biome_name string.
]]
---@nodiscard
---@param biome_name string
---@return core.BiomeID
function core.get_biome_id(biome_name) end

--[[
* `core.get_biome_name(biome_id)`
    * Returns the biome name string for the provided biome id, or `nil` on
      failure.
    * If no biomes have been registered, such as in mgv6, returns `default`.
]]
---@nodiscard
---@param biome_id core.BiomeID
---@return string?
function core.get_biome_name(biome_id) end

--[[ core.get_mapgen_params() .. core.set_mapgen_params() split off into ./mapgen_params.lua ]]--

--[=[
* `core.get_mapgen_edges([mapgen_limit[, chunksize]])`
    * Returns the minimum and maximum possible generated node positions
      in that order.
    * `mapgen_limit` is an optional number. If it is absent, its value is that
      of the *active* mapgen setting `"mapgen_limit"`.
    * `chunksize` is an optional number. If it is absent, its value is that
      of the *active* mapgen setting `"chunksize"`.
]=]
---@nodiscard
---@param mapgen_limit integer?
---@param chunksize integer?
---@return ivec min, ivec max
function core.get_mapgen_edges(mapgen_limit, chunksize) end

--[[
* `core.get_mapgen_chunksize()`
    * Returns the currently active chunksize of the mapgen, as a vector.
      The size is specified in blocks.
]]
---@nodiscard
---@return ivec
function core.get_mapgen_chunksize() end

--[[
* `core.get_mapgen_setting(name)`
    * Gets the *active* mapgen setting (or nil if none exists) in string
      format with the following order of precedence:
        1) Settings loaded from map_meta.txt or overrides set during mod
           execution.
        2) Settings set by mods without a metafile override
        3) Settings explicitly set in the user config file, minetest.conf
        4) Settings set as the user config default
]]
---@nodiscard
---@param name _.LuantiSettings.mapgen.keys
---@return string?
function core.get_mapgen_setting(name) end

--[[
* `core.get_mapgen_setting_noiseparams(name)`
    * Same as above, but returns the value as a NoiseParams table if the
      setting `name` exists and is a valid NoiseParams.
]]
---@nodiscard
---@param name _.LuantiSettings.mapgen.keys.noise_params.3d
---@return core.NoiseParams.3d?
function core.get_mapgen_setting_noiseparams(name) end

--[[
* `core.get_mapgen_setting_noiseparams(name)`
    * Same as above, but returns the value as a NoiseParams table if the
      setting `name` exists and is a valid NoiseParams.
]]
---@nodiscard
---@param name _.LuantiSettings.mapgen.keys.noise_params.2d
---@return core.NoiseParams.2d?
function core.get_mapgen_setting_noiseparams(name) end

--[[
* `core.set_mapgen_setting(name, value, [override_meta])`
    * Sets a mapgen param to `value`, and will take effect if the corresponding
      mapgen setting is not already present in map_meta.txt.
    * `override_meta` is an optional boolean (default: `false`). If this is set
      to true, the setting will become the active setting regardless of the map
      metafile contents.
    * Note: to set the seed, use `"seed"`, not `"fixed_map_seed"`.
]]
---@param name _.LuantiSettings.mapgen.keys
---@param value string
---@param override_meta boolean?
function core.set_mapgen_setting(name, value, override_meta) end

--[[
* `core.set_mapgen_setting_noiseparams(name, value, [override_meta])`
    * Same as above, except value is a NoiseParams table.
]]
---@param name _.LuantiSettings.mapgen.keys.noise_params.3d
---@param value core.NoiseParams.3d
---@param override_meta boolean?
function core.set_mapgen_setting_noiseparams(name, value, override_meta) end

--[[
* `core.set_mapgen_setting_noiseparams(name, value, [override_meta])`
    * Same as above, except value is a NoiseParams table.
]]
---@param name _.LuantiSettings.mapgen.keys.noise_params.2d
---@param value core.NoiseParams.2d
---@param override_meta boolean?
function core.set_mapgen_setting_noiseparams(name, value, override_meta) end

--[[
* `core.set_noiseparams(name, noiseparams, set_default)`
    * Sets the noiseparams setting of `name` to the noiseparams table specified
      in `noiseparams`.
    * `set_default` is an optional boolean (default: `true`) that specifies
      whether the setting should be applied to the default config or current
      active config.
]]
---@param name _.LuantiSettings.mapgen.keys.noise_params.3d
---@param noiseparams core.NoiseParams.3d
---@param set_default boolean?
function core.set_noiseparams(name, noiseparams, set_default) end

--[[
* `core.set_noiseparams(name, noiseparams, set_default)`
    * Sets the noiseparams setting of `name` to the noiseparams table specified
      in `noiseparams`.
    * `set_default` is an optional boolean (default: `true`) that specifies
      whether the setting should be applied to the default config or current
      active config.
]]
---@param name _.LuantiSettings.mapgen.keys.noise_params.2d
---@param noiseparams core.NoiseParams.2d
---@param set_default boolean?
function core.set_noiseparams(name, noiseparams, set_default) end

--[[
WIPDOC
]]
---@nodiscard
---@param name _.LuantiSettings.mapgen.keys.noise_params.3d
---@return core.NoiseParams.3d
function core.get_noiseparams(name) end

--[[
WIPDOC
]]
---@nodiscard
---@param name _.LuantiSettings.mapgen.keys.noise_params.2d
---@return core.NoiseParams.2d
function core.get_noiseparams(name) end

--[[
* `core.generate_ores(vm, pos1, pos2)`
    * Generate all registered ores within the VoxelManip `vm` and in the area
      from `pos1` to `pos2`.
    * `pos1` and `pos2` are optional and default to mapchunk minp and maxp.
]]
---@param vm core.VoxelManip
---@param pos1 ivector?
---@param pos2 ivector?
function core.generate_ores(vm, pos1, pos2) end

--[=[
* `core.generate_decorations(vm[, pos1, pos2, [use_mapgen_biomes]])`
    * Generate all registered decorations within the VoxelManip `vm` and in the
      area from `pos1` to `pos2`.
    * `pos1` and `pos2` are optional and default to mapchunk minp and maxp.
    * `use_mapgen_biomes` (optional boolean). For use in on_generated callbacks only.
       If set to true, decorations are placed in respect to the biome map of the current chunk.
       `pos1` and `pos2` must match the positions of the current chunk, or an error will be raised.
       default: `false`
]=]
---@param vm core.VoxelManip
---@param pos1 ivector?
---@param pos2 ivector?
---@param use_mapgen_biomes boolean?
function core.generate_decorations(vm, pos1, pos2, use_mapgen_biomes) end

--[[
WIPDOC
]]
---@class core.ClearObjectsOptions
--[[
WIPDOC
]]
---@field mode "full"|"quick"

--[[
* `core.clear_objects([options])`
    * Clear all objects in the environment
    * Takes an optional table as an argument with the field `mode`.
        * mode = `"full"`: Load and go through every mapblock, clearing
                            objects (default).
        * mode = `"quick"`: Clear objects immediately in loaded mapblocks,
                            clear objects in unloaded mapblocks only when the
                            mapblocks are next activated.
]]
---@param options core.ClearObjectsOptions?
function core.clear_objects(options) end

--[[
* `core.load_area(pos1[, pos2])`
    * Load the mapblocks containing the area from `pos1` to `pos2`.
      `pos2` defaults to `pos1` if not specified.
    * This function does not trigger map generation.
]]
---@param pos1 ivector
---@param pos2 ivector?
function core.load_area(pos1, pos2) end

--[[ core.emerge_area() split off into ./emerge_area.lua ]]--

--[[
* `core.delete_area(pos1, pos2)`
    * delete all mapblocks in the area from pos1 to pos2, inclusive
]]
---@param pos1 ivector
---@param pos2 ivector
function core.delete_area(pos1, pos2) end

-- ----------------------- ray casting and pathfinding ---------------------- --

--[[
Unofficial note: The annoying thing about this little function is that it is hardcoded to check specifically for "air", nothing else
Though i am sure you can make it work out

* `core.line_of_sight(pos1, pos2)`: returns `boolean, pos`
    * Checks if there is anything other than air between pos1 and pos2.
    * Returns false if something is blocking the sight.
    * Returns the position of the blocking node when `false`
    * `pos1`: First position
    * `pos2`: Second position
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@return true
function core.line_of_sight(pos1, pos2) end

--[[
Unofficial note: The annoying thing about this little function is that it is hardcoded to check specifically for "air", nothing else
Though i am sure you can make it work out

* `core.line_of_sight(pos1, pos2)`: returns `boolean, pos`
    * Checks if there is anything other than air between pos1 and pos2.
    * Returns false if something is blocking the sight.
    * Returns the position of the blocking node when `false`
    * `pos1`: First position
    * `pos2`: Second position
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@return false, core.Node.get
function core.line_of_sight(pos1, pos2) end

--[[ core.raycast() split off into classes/Raycast.lua ]]--

--[[
* `core.find_path(pos1, pos2, searchdistance, max_jump, max_drop, algorithm)`
    * returns table containing path that can be walked on
    * returns a table of 3D points representing a path from `pos1` to `pos2` or
      `nil` on failure.
    * Reasons for failure:
        * No path exists at all
        * No path exists within `searchdistance` (see below)
        * Start or end pos is buried in land
    * `pos1`: start position
    * `pos2`: end position
    * `searchdistance`: maximum distance from the search positions to search in.
      In detail: Path must be completely inside a cuboid. The minimum
      `searchdistance` of 1 will confine search between `pos1` and `pos2`.
      Larger values will increase the size of this cuboid in all directions
    * `max_jump`: maximum height difference to consider walkable
    * `max_drop`: maximum height difference to consider droppable
    * `algorithm`: One of `"A*_noprefetch"` (default), `"A*"`, `"Dijkstra"`.
      Difference between `"A*"` and `"A*_noprefetch"` is that
      `"A*"` will pre-calculate the cost-data, the other will calculate it
      on-the-fly
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@param searchdistance integer
---@param max_jump integer
---@param max_drop integer
---@param algo "A*_noprefetch"|"A*"|"Dijkstra"
---@return ivec[]?
function core.find_path(pos1, pos2, searchdistance, max_jump, max_drop, algo) end

-- ------------------------------ L-system tree ----------------------------- --

--[[
WIPDOC
]]
---@param pos ivector
---@param lsystem core.LSystemTreeDef
function core.spawn_tree(pos, lsystem) end

--[[
WIPDOC
]]
---@param vmanip core.VoxelManip
---@param pos ivector
---@param treedef core.LSystemTreeDef
function core.spawn_tree_on_vmanip(vmanip, pos, treedef) end

-- --------------------------------- liquid --------------------------------- --

--[[
* `core.transforming_liquid_add(pos)`
    * add node to liquid flow update queue
]]
---@param pos ivector
function core.transforming_liquid_add(pos) end

-- ------------------------------- node level ------------------------------- --

--[[
* `core.get_node_max_level(pos)`
    * get max available level for leveled node
]]
---@nodiscard
---@param pos ivector
---@return core.Param2.leveled
function core.get_node_max_level(pos) end

--[[
* `core.get_node_level(pos)`
    * get level of leveled node (water, snow)
]]
---@nodiscard
---@param pos ivector
---@return core.Param2.leveled
function core.get_node_level(pos) end

--[[
* `core.set_node_level(pos, level)`
    * set level of leveled node, default `level` equals `1`
    * if `totallevel > maxlevel`, returns rest (`total-max`).
]]
---@nodiscard
---@param pos ivector
---@param level core.Param2.leveled
---@return core.Param2.leveled?
function core.set_node_level(pos, level) end

--[[
* `core.add_node_level(pos, level)`
    * increase level of leveled node by level, default `level` equals `1`
    * if `totallevel > maxlevel`, returns rest (`total-max`)
    * `level` must be between -127 and 127
]]
---@nodiscard
---@param pos ivector
---@param level core.Param2.leveled
---@return core.Param2.leveled?
function core.add_node_level(pos, level) end

-- ---------------------------------- misc ---------------------------------- --

--[[
* `core.get_node_boxes(box_type, pos, [node])`
    * `box_type` must be `"node_box"`, `"collision_box"` or `"selection_box"`.
    * `pos` must be a node position.
    * `node` can be a table in the form `{name=string, param1=number, param2=number}`.
      If `node` is `nil`, the actual node at `pos` is used instead.
    * Resolves any facedir-rotated boxes, connected boxes and the like into
      actual boxes.
    * Returns a list of boxes in the form
      `{{x1, y1, z1, x2, y2, z2}, {x1, y1, z1, x2, y2, z2}, ...}`. Coordinates
      are relative to `pos`.
    * See also: [Node boxes](#node-boxes)
]]
---@param box_type "node_box"|"collision_box"|"selection_box"
---@param pos ivector
---@param node core.Node.get?
---@return core.NodeBox.box[]
function core.get_node_boxes(box_type, pos, node) end

--[[
* `core.fix_light(pos1, pos2)`: returns `true`/`false`
    * resets the light in a cuboid-shaped part of
      the map and removes lighting bugs.
    * Loads the area if it is not loaded.
    * `pos1` is the corner of the cuboid with the least coordinates
      (in node coordinates), inclusive.
    * `pos2` is the opposite corner of the cuboid, inclusive.
    * The actual updated cuboid might be larger than the specified one,
      because only whole map blocks can be updated.
      The actual updated area consists of those map blocks that intersect
      with the given cuboid.
    * However, the neighborhood of the updated area might change
      as well, as light can spread out of the cuboid, also light
      might be removed.
    * returns `false` if the area is not fully generated,
      `true` otherwise
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@return boolean
function core.fix_light(pos1, pos2) end

--[[
Unofficial note: You can override this one for your own custom cool falling blocks
* `core.check_single_for_falling(pos)`
    * causes an unsupported `group:falling_node` node to fall and causes an
      unattached `group:attached_node` node to fall.
    * does not spread these updates to neighbors.
]]
---@param pos ivector
function core.check_single_for_falling(pos) end

--[[
* `core.check_for_falling(pos)`
    * causes an unsupported `group:falling_node` node to fall and causes an
      unattached `group:attached_node` node to fall.
    * spread these updates to neighbors and can cause a cascade
      of nodes to fall.
]]
---@param pos ivector
function core.check_for_falling(pos) end

--[[
* `core.get_spawn_level(x, z)`
    * Returns a player spawn y coordinate for the provided (x, z)
      coordinates, or `nil` for an unsuitable spawn point.
    * For most mapgens a 'suitable spawn point' is one with y between
      `water_level` and `water_level + 16`, and in mgv7 well away from rivers,
      so `nil` will be returned for many (x, z) coordinates.
    * The spawn level returned is for a player spawn in unmodified terrain.
    * The spawn level is intentionally above terrain level to cope with
      full-node biome 'dust' nodes.
]]
---@param x integer
---@param z integer
---@return integer? y
function core.get_spawn_level(x, z) end