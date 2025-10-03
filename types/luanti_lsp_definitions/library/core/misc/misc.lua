---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Misc.

-- --------------------------- Player and Entities -------------------------- --

--[[
* `core.get_connected_players()`: returns list of `ObjectRefs`
]]
---@nodiscard
---@return core.PlayerRef[]
function core.get_connected_players() end

--[[
* `core.is_player(obj)`: boolean, whether `obj` is a player
]]
---@nodiscard
---@param obj core.ObjectRef
---@return boolean
function core.is_player(obj) end

--[[
* `core.is_player(obj)`: boolean, whether `obj` is a player
]]
---@nodiscard
---@param obj core.PlayerRef
---@return true
function core.is_player(obj) end

--[[
* `core.player_exists(name)`: boolean, whether player exists
  (regardless of online status)
]]
---@nodiscard
---@param name string
---@return boolean
function core.player_exists(name) end

--[[
* `core.is_valid_player_name(name)`: boolean, whether the given name
  could be used as a player name (regardless of whether said player exists).
]]
---@nodiscard
---@param name string
---@return boolean
function core.is_valid_player_name(name) end

--[[
* `core.hud_replace_builtin(name, hud_definition)`
    * Replaces definition of a builtin hud element
    * `name`: `"breath"`, `"health"`, `"minimap"` or `"hotbar"`
    * `hud_definition`: definition to replace builtin definition
]]
---@param name "breath"|"health"|"minimap"|"hotbar"
---@param hud_definition core.HUDDef
function core.hud_replace_builtin(name, hud_definition) end

-- -------------------------------------------------------------------------- --

--[[
* `core.parse_relative_number(arg, relative_to)`: returns number or nil
    * Helper function for chat commands.
    * For parsing an optionally relative number of a chat command
      parameter, using the chat command tilde notation.
    * `arg`: String snippet containing the number; possible values:
        * `"<number>"`: return as number
        * `"~<number>"`: return `relative_to + <number>`
        * `"~"`: return `relative_to`
        * Anything else will return `nil`
    * `relative_to`: Number to which the `arg` number might be relative to
    * Examples:
        * `core.parse_relative_number("5", 10)` returns 5
        * `core.parse_relative_number("~5", 10)` returns 15
        * `core.parse_relative_number("~", 10)` returns 10
]]
---@nodiscard
---@param arg string
---@param relative_to vector
---@return vec?
function core.parse_relative_number(arg, relative_to) end

--[[
* `core.send_join_message(player_name)`
    * This function can be overridden by mods to change the join message.
]]
---@param player_name string
function core.send_join_message(player_name) end

--[[
* `core.send_leave_message(player_name, timed_out)`
    * This function can be overridden by mods to change the leave message.
]]
---@param player_name string
---@param timed_out boolean
function core.send_leave_message(player_name, timed_out) end

-- ------------------------------ position hash ----------------------------- --

--[[
WIPDOC
]]
---@alias core.PosHash integer

--[[
* `core.hash_node_position(pos)`: returns a 48-bit integer
    * `pos`: table {x=number, y=number, z=number},
    * Gives a unique numeric encoding for a node position (16+16+16=48bit)
    * Despite the name, this is not a hash function (so it doesn't mix or produce collisions).
]]
---@nodiscard
---@param pos ivector
---@return core.PosHash
function core.hash_node_position(pos) end

--[[
* `core.get_position_from_hash(hash)`: returns a position
    * Inverse transform of `core.hash_node_position`
]]
---@nodiscard
---@param hash core.PosHash
---@return ivec
function core.get_position_from_hash(hash) end

-- --------------------------------- groups --------------------------------- --

--[[ core.get_item_group() .. core.get_node_group() split off into ./get_group.lua ]]--

--[[
* `core.raillike_group(name)`: returns a rating
    * Returns rating of the connect_to_raillike group corresponding to name
    * If name is not yet the name of a connect_to_raillike group, a new group
      id is created, with that name.
]]
---@nodiscard
---@param name core.Node.name
---@return integer
function core.raillike_group(name) end

-- ------------------------------- content ID ------------------------------- --

--[[
* `core.get_content_id(name)`: returns an integer
    * Gets the internal content ID of `name`
]]
---@nodiscard
---@param name core.Node.name
---@return core.ContentID
function core.get_content_id(name) end

--[[
* `core.get_name_from_content_id(content_id)`: returns a string
    * Gets the name of the content with that content ID
]]
---@nodiscard
---@param content_id core.ContentID
---@return core.Node.name
function core.get_name_from_content_id(content_id) end

-- ------------------------------ serialization ----------------------------- --

--[[
* `core.parse_json(string[, nullvalue, return_error])`: returns something
    * Convert a string containing JSON data into the Lua equivalent
    * `nullvalue`: returned in place of the JSON null; defaults to `nil`
    * On success returns a table, a string, a number, a boolean or `nullvalue`
    * On failure: If `return_error` is not set or is `false`,
      outputs an error message and returns `nil`.
      Otherwise returns `nil, err` (error message).
    * Example: `parse_json("[10, {\"a\":false}]")`, returns `{10, {a = false}}`
]]
---@nodiscard
---@param string string
---@param nullvalue any?
---@param return_error false?
---@return core.Serializable?
function core.parse_json(string, nullvalue, return_error) end

--[[
* `core.parse_json(string[, nullvalue, return_error])`: returns something
    * Convert a string containing JSON data into the Lua equivalent
    * `nullvalue`: returned in place of the JSON null; defaults to `nil`
    * On success returns a table, a string, a number, a boolean or `nullvalue`
    * On failure: If `return_error` is not set or is `false`,
      outputs an error message and returns `nil`.
      Otherwise returns `nil, err` (error message).
    * Example: `parse_json("[10, {\"a\":false}]")`, returns `{10, {a = false}}`
]]
---@nodiscard
---@param string string
---@param nullvalue any?
---@param return_error true
---@return core.Serializable?, string?
function core.parse_json(string, nullvalue, return_error) end

--[[
* `core.write_json(data[, styled])`: returns a string or `nil` and an error
  message.
    * Convert a Lua table into a JSON string
    * styled: Outputs in a human-readable format if this is set, defaults to
      false.
    * Unserializable things like functions and userdata will cause an error.
    * **Warning**: JSON is more strict than the Lua table format.
        1. You can only use strings and positive integers of at least one as
           keys.
        2. You cannot mix string and integer keys.
           This is due to the fact that JSON has two distinct array and object
           values.
    * Example: `write_json({10, {a = false}})`,
      returns `'[10, {"a": false}]'`
]]
---@nodiscard
---@param data core.Serializable
---@param styled boolean?
---@return string
function core.write_json(data, styled) end

--[[
* `core.serialize(table)`: returns a string
    * Convert a value into string form readable by `core.deserialize`.
    * Supports tables, strings, numbers, booleans and `nil`.
    * Support for dumping function bytecode is **deprecated**.
    * Note: To obtain a human-readable representation of a value, use `dump` instead.
    * Example: `serialize({foo="bar"})`, returns `'return { ["foo"] = "bar" }'`
]]
---@nodiscard
---@param table core.Serializable
---@return string
function core.serialize(table) end

--[[
* `core.deserialize(string[, safe])`: returns a table
    * Convert a string returned by `core.serialize` into a table
    * `string` is loaded in an empty sandbox environment.
    * Will load functions if `safe` is `false` or omitted.
      Although these functions cannot directly access the global environment,
      they could bypass this restriction with maliciously crafted Lua bytecode
      if mod security is disabled.
    * Will silently strip functions embedded via calls to `loadstring`
      (typically bytecode dumped by `core.serialize`) if `safe` is `true`.
      You should not rely on this if possible.
      * Example: `core.deserialize("return loadstring('')", true)` will be `nil`.
    * This function should not be used on untrusted data, regardless of the
     value of `safe`. It is fine to serialize then deserialize user-provided
     data, but directly providing user input to deserialize is always unsafe.
    * Example: `deserialize('return { ["foo"] = "bar" }')`,
      returns `{foo="bar"}`
    * Example: `deserialize('print("foo")')`, returns `nil`
      (function call fails), returns
      `error:[string "print("foo")"]:1: attempt to call global 'print' (a nil value)`
]]
---@nodiscard
---@param string string
---@param safe boolean?
---@return core.Serializable
function core.deserialize(string, safe) end

-- ------------------------------- compression ------------------------------ --

--[[
* `core.compress(data, method, ...)`: returns `compressed_data`
    * Compress a string of data.
    * `method` is a string identifying the compression method to be used.
    * Supported compression methods:
        * Deflate (zlib): `"deflate"`
        * Zstandard: `"zstd"`
    * `...` indicates method-specific arguments. Currently defined arguments
      are:
        * Deflate: `level` - Compression level, `0`-`9` or `nil`.
        * Zstandard: `level` - Compression level. Integer or `nil`. Default `3`.
        Note any supported Zstandard compression level could be used here,
        but these are subject to change between Zstandard versions.
]]
---@nodiscard
---@param data string
---@param method "deflate"
---@param level 0|1|2|3|4|5|6|7|8|9?
---@return string
function core.compress(data, method, level) end

--[[
* `core.compress(data, method, ...)`: returns `compressed_data`
    * Compress a string of data.
    * `method` is a string identifying the compression method to be used.
    * Supported compression methods:
        * Deflate (zlib): `"deflate"`
        * Zstandard: `"zstd"`
    * `...` indicates method-specific arguments. Currently defined arguments
      are:
        * Deflate: `level` - Compression level, `0`-`9` or `nil`.
        * Zstandard: `level` - Compression level. Integer or `nil`. Default `3`.
        Note any supported Zstandard compression level could be used here,
        but these are subject to change between Zstandard versions.
]]
---@nodiscard
---@param data string
---@param method "zstd"
---@param level integer?
---@return string
function core.compress(data, method, level) end

--[[
* `core.decompress(compressed_data, method, ...)`: returns data
    * Decompress a string of data using the algorithm specified by `method`.
    * See documentation on `core.compress()` for supported compression
      methods.
    * `...` indicates method-specific arguments. Currently, no methods use this
]]
---@nodiscard
---@param compressed_data string
---@param method "zstd"|"deflate"
---@return string
function core.decompress(compressed_data, method) end

-- -------------------------------------------------------------------------- --

--[[
* `core.rgba(red, green, blue[, alpha])`: returns a string
    * Each argument is an 8 Bit unsigned integer
    * Returns the ColorString from rgb or rgba values
    * Example: `core.rgba(10, 20, 30, 40)`, returns `"#0A141E28"`
]]
---@nodiscard
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer?
---@return core.ColorString
function core.rgba(red, green, blue, alpha) end

-- -------------------------------- encoding -------------------------------- --

--[[
* `core.encode_base64(string)`: returns string encoded in base64
    * Encodes a string in base64.
]]
---@param string string
---@return string
function core.encode_base64(string) end

--[[
* `core.decode_base64(string)`: returns string or nil on failure
    * Padding characters are only supported starting at version 5.4.0, where
      5.5.0 and newer perform proper checks.
    * Decodes a string encoded in base64.
]]
---@param string string
---@return string
function core.decode_base64(string) end

-- ------------------------------- protection ------------------------------- --

--[[
Unofficial note: Do NOT localize it, i know you want to, just don't
* `core.is_protected(pos, name)`: returns boolean
    * Returning `true` restricts the player `name` from modifying (i.e. digging,
       placing) the node at position `pos`.
    * `name` will be `""` for non-players or unknown players.
    * This function should be overridden by protection mods. It is highly
      recommended to grant access to players with the `protection_bypass` privilege.
    * Cache and call the old version of this function if the position is
      not protected by the mod. This will allow using multiple protection mods.
    * Example:
      ```lua
      local old_is_protected = core.is_protected
      function core.is_protected(pos, name)
          if mymod:position_protected_from(pos, name) then
              return true
          end
          return old_is_protected(pos, name)
      end
      ```
]]
---@nodiscard
---@param pos ivector
---@param name string
---@return boolean
function core.is_protected(pos, name) end

--[[
* `core.record_protection_violation(pos, name)`
    * This function calls functions registered with
      `core.register_on_protection_violation`.
]]
---@param pos ivector
---@param name string
function core.record_protection_violation(pos, name) end

--[[
* `core.is_creative_enabled(name)`: returns boolean
    * Returning `true` means that Creative Mode is enabled for player `name`.
    * `name` will be `""` for non-players or if the player is unknown.
    * This function should be overridden by Creative Mode-related mods to
      implement a per-player Creative Mode.
    * By default, this function returns `true` if the setting
      `creative_mode` is `true` and `false` otherwise.
]]
---@nodiscard
---@param name string
---@return boolean
function core.is_creative_enabled(name) end

--[[
* `core.is_area_protected(pos1, pos2, player_name, interval)`
    * Returns the position of the first node that `player_name` may not modify
      in the specified cuboid between `pos1` and `pos2`.
    * Returns `false` if no protections were found.
    * Applies `is_protected()` to a 3D lattice of points in the defined volume.
      The points are spaced evenly throughout the volume and have a spacing
      similar to, but no larger than, `interval`.
    * All corners and edges of the defined volume are checked.
    * `interval` defaults to 4.
    * `interval` should be carefully chosen and maximized to avoid an excessive
      number of points being checked.
    * Like `core.is_protected`, this function may be extended or
      overwritten by mods to provide a faster implementation to check the
      cuboid for intersections.
]]
---@nodiscard
---@param pos1 ivector
---@param pos2 ivector
---@param player_name string
---@param interval integer
---@return boolean
function core.is_area_protected(pos1, pos2, player_name, interval) end

--[[
WIPDOC
]]
---@class core.RotateAndPlace.orient_flags
--[[
WIPDOC
]]
---@field invert_wall boolean?
--[[
WIPDOC
]]
---@field force_wall boolean?
--[[
WIPDOC
]]
---@field force_ceiling boolean?
--[[
WIPDOC
]]
---@field force_floor boolean?
--[[
WIPDOC
]]
---@field force_facedir boolean?

--[[
* `core.rotate_and_place(itemstack, placer, pointed_thing[, infinitestacks,
  orient_flags, prevent_after_place])`
    * Attempt to predict the desired orientation of the facedir-capable node
      defined by `itemstack`, and place it accordingly (on-wall, on the floor,
      or hanging from the ceiling).
    * `infinitestacks`: if `true`, the itemstack is not changed. Otherwise the
      stacks are handled normally.
    * `orient_flags`: Optional table containing extra tweaks to the placement code:
        * `invert_wall`:   if `true`, place wall-orientation on the ground and
          ground-orientation on the wall.
        * `force_wall`:    if `true`, always place the node in wall orientation.
        * `force_ceiling`: if `true`, always place on the ceiling.
        * `force_floor`:   if `true`, always place the node on the floor.
        * `force_facedir`: if `true`, forcefully reset the facedir to north
          when placing on the floor or ceiling.
        * The first four options are mutually-exclusive; the last in the list
          takes precedence over the first.
    * `prevent_after_place` is directly passed to `core.item_place_node`
    * Returns the new itemstack after placement
]]
---@nodiscard
---@param itemstack core.ItemStack
---@param placer core.ObjectRef
---@param pointed_thing core.PointedThing
---@param infinitestacks boolean?
---@param orient_flags core.RotateAndPlace.orient_flags?
---@param prevent_after_place boolean?
---@return core.ItemStack
function core.rotate_and_place(itemstack, placer, pointed_thing, infinitestacks, orient_flags, prevent_after_place) end


--[[
* `core.rotate_node(itemstack, placer, pointed_thing)`
    * calls `rotate_and_place()` with `infinitestacks` set according to the state
      of the creative mode setting, checks for "sneak" to set the `invert_wall`
      parameter and `prevent_after_place` set to `true`
]]
---@param itemstack core.ItemStack
---@param placer core.ObjectRef
---@param pointed_thing core.PointedThing
function core.rotate_node(itemstack, placer, pointed_thing) end


--[[
* `core.calculate_knockback(player, hitter, time_from_last_punch,
  tool_capabilities, dir, distance, damage)`
    * Returns the amount of knockback applied on the punched player.
    * Arguments are equivalent to `register_on_punchplayer`, except the following:
        * `distance`: distance between puncher and punched player
    * This function can be overridden by mods that wish to modify this behavior.
    * You may want to cache and call the old function to allow multiple mods to
      change knockback behavior.
]]
---@nodiscard
---@param player core.PlayerRef
---@param hitter core.ObjectRef
---@param time_from_last_punch number
---@param tool_capabilities core.ToolCapabilities
---@param dir vector
---@param distance number
---@param damage integer
---@return number
function core.calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage) end

-- ----------------------------- mapblock status ---------------------------- --

--[=[
* `core.forceload_block(pos[, transient[, limit]])`
    * forceloads the position `pos`.
    * this means that the mapblock containing `pos` will always be kept in the
      `"active"` state, regardless of nearby players or server settings.
    * returns `true` if area could be forceloaded
    * If `transient` is `false` or absent, the forceload will be persistent
      (saved between server runs). If `true`, the forceload will be transient
      (not saved between server runs).
    * `limit` is an optional limit on the number of blocks that can be
      forceloaded at once. If `limit` is negative, there is no limit. If it is
      absent, the limit is the value of the setting `"max_forceloaded_blocks"`.
      If the call would put the number of blocks over the limit, the call fails.
]=]
---@nodiscard
---@param pos ivector
---@param transient boolean?
---@param limit number?
---@return boolean
function core.forceload_block(pos, transient, limit) end

--[[
* `core.forceload_free_block(pos[, transient])`
    * stops forceloading the position `pos`
    * If `transient` is `false` or absent, frees a persistent forceload.
      If `true`, frees a transient forceload.
]]
---@param pos ivector
---@param transient boolean?
function core.forceload_free_block(pos, transient) end

--[[
* `core.compare_block_status(pos, condition)`
    * Checks whether the mapblock at position `pos` is in the wanted condition.
    * `condition` may be one of the following values:
        * `"unknown"`: not in memory
        * `"emerging"`: in the queue for loading from disk or generating
        * `"loaded"`: in memory but inactive (no ABMs are executed)
        * `"active"`: in memory and active
        * Other values are reserved for future functionality extensions
    * Return value, the comparison status:
        * `false`: Mapblock does not fulfill the wanted condition
        * `true`: Mapblock meets the requirement
        * `nil`: Unsupported `condition` value
]]
---@nodiscard
---@param pos ivector
---@param condition "unknown"|"emerging"|"loaded"|"active"
---@return boolean?
function core.compare_block_status(pos, condition) end

-- -------------------------------------------------------------------------- --

--[[ core.request_insecure_environment() split off into ./insecure_environment.lua ]]--

--[[
* `core.global_exists(name)`
    * Checks if a global variable has been set, without triggering a warning.
]]
---@nodiscard
---@param name string
---@return boolean
function core.global_exists(name) end

--[[
* `core.register_portable_metatable(name, mt)`:
    * Register a metatable that should be preserved when Lua data is transferred
      between environments (via IPC or `handle_async`).
    * `name` is a string that identifies the metatable. It is recommended to
      follow the `modname:name` convention for this identifier.
    * `mt` is the metatable to register.
    * Note that the same metatable can be registered under multiple names,
      but multiple metatables must not be registered under the same name.
    * You must register the metatable in both the main environment
      and the async environment for this mechanism to work.
]]
---@param name string
---@param mt table
function core.register_portable_metatable(name, mt) end