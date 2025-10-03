---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

--[[
WIPDOC
]]
---@class core.PlayerRef : _.ObjectRef.__base
local PlayerRef = {}

-- --------------------------- ObjectRef overrides -------------------------- --

--[[
* `add_velocity(vel)`
    * Changes velocity by adding to the current velocity.
    * `vel` is a vector, e.g. `{x=0.0, y=2.3, z=1.0}`
    * In comparison to using `get_velocity`, adding the velocity and then using
      `set_velocity`, `add_velocity` is supposed to avoid synchronization problems.
      Additionally, players also do not support `set_velocity`.
    * If object is a player:
        * Does not apply during `free_move`.
        * Note that since the player speed is normalized at each move step,
          increasing e.g. Y velocity beyond what would usually be achieved
          (see: physics overrides) will cause existing X/Z velocity to be reduced.
        * Example: `add_velocity({x=0, y=6.5, z=0})` is equivalent to
          pressing the jump key (assuming default settings)
]]
---@param vel vector
function PlayerRef:add_velocity(vel) end

--[[
* `move_to(pos, continuous=false)`
    * Does an interpolated move for Lua entities for visually smooth transitions.
    * If `continuous` is true, the Lua entity will not be moved to the current
      position before starting the interpolated move.
    * For players this does the same as `set_pos`,`continuous` is ignored.
    * no-op if object is attached
]]
---@param pos vector
---@param continuous boolean?
function PlayerRef:move_to(pos, continuous) end

--[[
* `set_hp(hp, reason)`: set number of health points
    * See reason in register_on_player_hpchange
    * Is limited to the range of 0 ... 65535 (2^16 - 1)
    * For players: HP are also limited by `hp_max` specified in object properties
]]
---@param hp integer
---@param reason core.PlayerHPChangeReason?
function PlayerRef:set_hp(hp, reason) end

--[[
* `get_inventory()`: returns an `InvRef` for players, otherwise returns `nil`
]]
---@nodiscard
---@return core.InvRef
function PlayerRef:get_inventory() end

--[[
* `set_properties(object property table)`
]]
---@param objprops core.PlayerProperties.set
function PlayerRef:set_properties(objprops) end

--[[
* `get_properties()`: returns a table of all object properties
]]
---@nodiscard
---@return core.PlayerProperties.get objprops
function PlayerRef:get_properties() end

--[[
* `is_player()`: returns true for players, false otherwise
]]
---@nodiscard
---@return true
function PlayerRef:is_player() end

--[[
* `get_guid()`: returns a global unique identifier (a string)
    * For players, this is a player name.
    * For Lua entities, this is a uniquely generated string, guaranteed not to collide with player names.
      * example: `@bGh3p2AbRE29Mb4biqX6OA`
    * GUIDs only use printable ASCII characters.
    * GUIDs persist between object reloads, and their format is guaranteed not to change.
      Thus you can use the GUID to identify an object in a particular world online and offline.
]]
---@nodiscard
---@return string
function PlayerRef:get_guid() end

-- ------------------------------- player name ------------------------------ --

--[[
* `get_player_name()`: Returns player name or `""` if is not a player
]]
---@nodiscard
---@return string
function PlayerRef:get_player_name() end

-- ---------------------- player position and movement ---------------------- --

--[[
* `get_player_velocity()`: **DEPRECATED**, use get_velocity() instead.
  table {x, y, z} representing the player's instantaneous velocity in nodes/s
]]
---@deprecated
---@nodiscard
---@return vec vel
function PlayerRef:get_player_velocity() end

--[[
* `add_player_velocity(vel)`: **DEPRECATED**, use add_velocity(vel) instead.
]]
---@deprecated
---@param vel vector
function PlayerRef:add_player_velocity(vel) end

-- ------------------------------ player camera ----------------------------- --

--[[
* `get_look_dir()`: get camera direction as a unit vector
]]
---@nodiscard
---@return vector radians
function PlayerRef:get_look_dir() end

--[[
* `get_look_vertical()`: pitch in radians
    * Angle ranges between -pi/2 and pi/2, which are straight up and down
      respectively.
]]
---@nodiscard
---@return number radians
function PlayerRef:get_look_vertical() end

--[[
* `get_look_horizontal()`: yaw in radians
    * Angle is counter-clockwise from the +z direction.
]]
---@nodiscard
---@return number radians
function PlayerRef:get_look_horizontal() end

--[[
* `set_look_vertical(radians)`: sets look pitch
    * radians: Angle from looking forward, where positive is downwards.
]]
---@param radians number
function PlayerRef:set_look_vertical(radians) end

--[[
* `get_look_horizontal()`: yaw in radians
    * Angle is counter-clockwise from the +z direction.
]]
---@param radians number
function PlayerRef:set_look_horizontal(radians) end

--[[
* `get_look_pitch()`: pitch in radians - Deprecated as broken. Use
  `get_look_vertical`.
]]
---@deprecated
---@nodiscard
---@return number radians
function PlayerRef:get_look_pitch() end

--[[
* `get_look_yaw()`: yaw in radians - Deprecated as broken. Use
  `get_look_horizontal`.
]]
---@deprecated
---@nodiscard
---@return number radians
function PlayerRef:get_look_yaw() end

--[[
* `set_look_pitch(radians)`: sets look pitch - Deprecated. Use
  `set_look_vertical`.
]]
---@deprecated
---@param radians number
function PlayerRef:set_look_pitch(radians) end

--[[
* `set_look_yaw(radians)`: sets look yaw - Deprecated. Use
  `set_look_horizontal`.
]]
---@deprecated
---@param radians number
function PlayerRef:set_look_yaw(radians) end

-- ------------------------------ player breath ----------------------------- --

--[[
* `get_breath()`: returns player's breath
]]
---@nodiscard
---@return integer value
function PlayerRef:get_breath() end

--[[
* `set_breath(value)`: sets player's breath
    * values:
        * `0`: player is drowning
    * Is limited to range 0 ... 65535 (2^16 - 1)
]]
---@nodiscard
---@param value integer
function PlayerRef:set_breath(value) end

-- ------------------------------- player fov ------------------------------- --

--[[
* `set_fov(fov, is_multiplier, transition_time)`: Sets player's FOV
    * `fov`: Field of View (FOV) value.
    * `is_multiplier`: Set to `true` if the FOV value is a multiplier.
      Defaults to `false`.
    * `transition_time`: If defined, enables smooth FOV transition.
      Interpreted as the time (in seconds) to reach target FOV.
      If set to 0, FOV change is instantaneous. Defaults to 0.
    * Set `fov` to 0 to clear FOV override.
]]
---@param fov number
---@param is_multiplier boolean?
---@param transition_time number?
function PlayerRef:set_fov(fov, is_multiplier, transition_time) end

--[[
* `get_fov()`: Returns the following:
    * Server-sent FOV value. Returns 0 if an FOV override doesn't exist.
    * Boolean indicating whether the FOV value is a multiplier.
    * Time (in seconds) taken for the FOV transition. Set by `set_fov`.
]]
---@nodiscard
---@return number fov, boolean is_multiplier, number transition_time
function PlayerRef:get_fov() end

-- ----------------------------- player metadata ---------------------------- --

--[[
* `set_attribute(attribute, value)`:  DEPRECATED, use get_meta() instead
    * Sets an extra attribute with value on player.
    * `value` must be a string, or a number which will be converted to a
      string.
    * If `value` is `nil`, remove attribute from player.
]]
---@deprecated
---@param attribute string
---@param value string|number?
function PlayerRef:set_attribute(attribute, value) end

--[[
* `get_attribute(attribute)`:  DEPRECATED, use get_meta() instead
    * Returns value (a string) for extra attribute.
    * Returns `nil` if no attribute found.
]]
---@deprecated
---@nodiscard
---@param attribute string
---@return string?
function PlayerRef:get_attribute(attribute) end

--[[
* `get_meta()`: Returns metadata associated with the player (a PlayerMetaRef).
]]
---@nodiscard
---@return core.PlayerMetaRef
function PlayerRef:get_meta() end

-- ----------------------------- player formspec ---------------------------- --

--[[
* `set_inventory_formspec(formspec)`
    * Redefines the player's inventory formspec.
    * Should usually be called at least once in the `on_joinplayer` callback.
    * If `formspec` is `""`, the player's inventory is disabled.
    * If the inventory formspec is currently open on the client, it is
      updated immediately.
    * See also: `core.register_on_player_receive_fields`
]]
---@param formspec core.Formspec
function PlayerRef:set_inventory_formspec(formspec) end

--[[
* `get_inventory_formspec()`: returns a formspec string
]]
---@nodiscard
---@return core.Formspec? formspec
function PlayerRef:get_inventory_formspec() end

--[[
* `set_formspec_prepend(formspec)`:
    * the formspec string will be added to every formspec shown to the user,
      except for those with a no_prepend[] tag.
    * This should be used to set style elements such as background[] and
      bgcolor[], any non-style elements (eg: label) may result in weird behavior.
    * Only affects formspecs shown after this is called.
]]
---@param formspec core.Formspec
function PlayerRef:set_formspec_prepend(formspec) end

--[[
* `get_formspec_prepend()`: returns a formspec string.
]]
---@nodiscard
---@return core.Formspec? formspec
function PlayerRef:get_formspec_prepend() end

-- ----------------------------- player control ----------------------------- --

--[[ PlayerRef:get_player_control() .. PlayerRef:get_player_control_bits() split off into ./player_control.lua ]]--

-- ------------------------- player physics override ------------------------ --

--[[ PlayerRef:set_physics_override() .. PlayerRef:get_physics_override() splits off into ./player_physics_override.lua ]]--

-- ------------------------------- player hud ------------------------------- --

--[[
* `hud_add(hud definition)`: add a HUD element described by HUD def, returns ID
   number on success
]]
---@nodiscard
---@param hud_definition core.HUDDef
---@return core.HUDID? id
function PlayerRef:hud_add(hud_definition) end

--[[
* `hud_remove(id)`: remove the HUD element of the specified id
]]
---@param id core.HUDID
function PlayerRef:hud_remove(id) end

--[[
* `hud_change(id, stat, value)`: change a value of a previously added HUD
  element.
    * `stat` supports the same keys as in the hud definition table except for
      `"type"` (or the deprecated `"hud_elem_type"`).
]]
---@param id core.HUDID
---@param stat core.HUDDef.keys
---@param value number|string|core.Texture|vec2.xy|vec?
function PlayerRef:hud_change(id, stat, value) end

--[[
* `hud_get(id)`: gets the HUD element definition structure of the specified ID
]]
---@nodiscard
---@param id core.HUDID
---@return core.HUDDef? hud_definition
function PlayerRef:hud_get(id) end

--[[
* `hud_get_all()`:
    * Returns a table in the form `{ [id] = HUD definition, [id] = ... }`.
    * A mod should keep track of its introduced IDs and only use this to access foreign elements.
    * It is discouraged to change foreign HUD elements.
]]
---@nodiscard
---@return table<core.HUDID, core.HUDDef>
function PlayerRef:hud_get_all() end

--[[ PlayerRef:hud_set_flags() .. PlayerRef:hud_get_flags() split off into ./player_hud_flags.lua ]]--

--[[
* `hud_set_hotbar_itemcount(count)`: sets number of items in builtin hotbar
    * `count`: number of items, must be between `1` and `32`
    * If `count` exceeds the `"main"` list size, the list size will be used instead.
]]
---@param count integer
function PlayerRef:hud_set_hotbar_itemcount(count) end

--[[
* `hud_get_hotbar_itemcount()`: returns number of visible items
    * This value is also clamped by the `"main"` list size.
]]
---@nodiscard
---@return integer count
function PlayerRef:hud_get_hotbar_itemcount() end

--[[
* `hud_set_hotbar_image(texturename)`
    * sets background image for hotbar
]]
---@param texturename core.Texture
function PlayerRef:hud_set_hotbar_image(texturename) end

--[[
* `hud_get_hotbar_image()`: returns texturename
]]
---@nodiscard
---@return core.Texture texturename
function PlayerRef:hud_get_hotbar_image() end

--[[
* `hud_set_hotbar_selected_image(texturename)`
    * sets image for selected item of hotbar
]]
---@param texturename core.Texture
function PlayerRef:hud_set_hotbar_selected_image(texturename) end

--[[
* `hud_get_hotbar_selected_image()`: returns texturename
]]
---@nodiscard
---@return core.Texture texturename
function PlayerRef:hud_get_hotbar_selected_image() end

-- ----------------------------- player minimap ----------------------------- --

--[[ PlayerRef:set_minimap_modes() split off into ./player_minimap.lua ]]--

-- ------------------------------- player sky ------------------------------- --

--[[ PlayerRef:set_sky() .. PlayerRef:get_sky_color() split off into ./player_skybox.lua ]]--
--[[ PlayerRef:set_sun() .. PlayerRef:get_sun() split off into ./player_sun.lua ]]--
--[[ PlayerRef:set_moon() .. PlayerRef:get_moon() split off into ./player_moon.lua ]]--
--[[ PlayerRef:set_stars() .. PlayerRef:get_stars() split off into ./player_stars.lua ]]--
--[[ PlayerRef:set_clouds() .. PlayerRef:get_clouds() split off into ./player_clouds.lua ]]--

--[[
* `override_day_night_ratio(ratio or nil)`
    * `0`...`1`: Overrides day-night ratio, controlling sunlight to a specific
      amount.
    * Passing no arguments disables override, defaulting to sunlight based on day-night cycle
    * See also `core.time_to_day_night_ratio`,
]]
---@param ratio number?
function PlayerRef:override_day_night_ratio(ratio) end

--[[
* `get_day_night_ratio()`: returns the ratio or nil if it isn't overridden
]]
---@nodiscard
---@return number? ratio
function PlayerRef:get_day_night_ratio() end

-- ---------------------------- player animation ---------------------------- --

--[[
* `set_local_animation(idle, walk, dig, walk_while_dig, frame_speed)`:
  set animation for player model in third person view.
    * Every animation equals to a `{x=starting frame, y=ending frame}` table.
    * `frame_speed` sets the animations frame speed. Default is 30.
]]
---@param idle vec2.xy
---@param walk vec2.xy
---@param dig vec2.xy
---@param walk_while_dig vec2.xy
---@param frame_speed number
function PlayerRef:set_local_animation(idle, walk, dig, walk_while_dig, frame_speed) end

--[[
* `get_local_animation()`: returns idle, walk, dig, walk_while_dig tables and
  `frame_speed`.
]]
---@nodiscard
---@return vec2.xy idle, vec2.xy walk, vec2.xy dig
function PlayerRef:get_local_animation() end

-- ------------------------------ player camera ----------------------------- --

--[[
* `set_eye_offset([firstperson, thirdperson_back, thirdperson_front])`: Sets camera offset vectors.
    * `firstperson`: Offset in first person view.
      Defaults to `vector.zero()` if unspecified.
    * `thirdperson_back`: Offset in third person back view.
      Clamped between `vector.new(-10, -10, -5)` and `vector.new(10, 15, 5)`.
      Defaults to `vector.zero()` if unspecified.
    * `thirdperson_front`: Offset in third person front view.
      Same limits as for `thirdperson_back` apply.
      Defaults to `thirdperson_back` if unspecified.
]]
---@param firstperson vector?
---@param thirdperson_back vector?
---@param thirdperson_front vector?
function PlayerRef:set_eye_offset(firstperson, thirdperson_back, thirdperson_front) end

--[[
* `get_eye_offset()`: Returns camera offset vectors as set via `set_eye_offset`.
]]
---@nodiscard
---@return  vec firstperson, vec thirdperson_back, vec thirdperson_front
function PlayerRef:get_eye_offset() end

--[[
WIPDOC
]]
---@alias core.PlayerCameraParams.mode
--- | "any"
--- | "first"
--- | "third"
--- | "third_front"

--[[
WIPDOC
]]
---@class core.PlayerCameraParams
--[[
WIPDOC
]]
---@field mode core.PlayerCameraParams.mode

--[[
* `set_camera(params)`: Sets camera parameters.
    * `mode`: Defines the camera mode used
      - `any`: free choice between all modes (default)
      - `first`: first-person camera
      - `third`: third-person camera
      - `third_front`: third-person camera, looking opposite of movement direction
    * Supported by client since 5.12.0.
]]
---@param params core.PlayerCameraParams
function PlayerRef:set_camera(params) end

--[[
* `get_camera()`: Returns the camera parameters as a table as above.
]]
---@nodiscard
---@return core.PlayerCameraParams params
function PlayerRef:get_camera() end

-- ---------------------- player mapblock and lighting ---------------------- --

--[[
* `send_mapblock(blockpos)`:
    * Sends an already loaded mapblock to the player.
    * Returns `false` if nothing was sent (note that this can also mean that
      the client already has the block)
    * Resource intensive - use sparsely
]]
---@nodiscard
---@param blockpos vector
---@return boolean?
function PlayerRef:send_mapblock(blockpos) end

--[[ PlayerRef:set_lighting() .. PlayerRef:get_lighting() split off into ./player_lighting.lua ]]--

-- ------------------------------- player misc ------------------------------ --

--[[
* `respawn()`: Respawns the player using the same mechanism as the death screen,
  including calling `on_respawnplayer` callbacks.
]]
function PlayerRef:respawn() end

--[[ PlayerRef:get_flags() .. PlayerRef:set_flags() split off into ./player_flags.lua ]]--