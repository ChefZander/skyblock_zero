---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- INTERPRETATION: EntityRef does not override ObjectRef, merely supplies
-- ObjectRef with exclusive entity methods. This is because of the relationship
-- where PlayerRef overrides ObjectRef's methods. This is seen in how some
-- ObjectRef methods assumes it's an entity and not a player.

--[[
WIPDOC
]]
---@class _.ObjectRef.__base
local ObjectRefBase = {}

--[[
WIPDOC
]]
---@alias core.ObjectRef
--- | core.PlayerRef
--- | core.EntityRef

-- -------------------------------- is valid -------------------------------- --

--[[
* `is_valid()`: returns whether the object is valid.
]]
---@nodiscard
---@return boolean
function ObjectRefBase:is_valid() end

-- -------------------------- position and movement ------------------------- --

--[[
* `get_pos()`: returns position as vector `{x=num, y=num, z=num}`
]]
---@nodiscard
---@return vec pos
function ObjectRefBase:get_pos() end

--[[
* `set_pos(pos)`:
    * Sets the position of the object.
    * No-op if object is attached.
    * `pos` is a vector `{x=num, y=num, z=num}`
]]
---@param pos vector
function ObjectRefBase:set_pos(pos) end

--[[
* `add_pos(pos)`:
    * Changes position by adding to the current position.
    * No-op if object is attached.
    * `pos` is a vector `{x=num, y=num, z=num}`.
    * In comparison to using `set_pos`, `add_pos` will avoid synchronization problems.
]]
---@param pos vector
function ObjectRefBase:add_pos(pos) end

--[[
* `get_velocity()`: returns the velocity, a vector.
]]
---@nodiscard
---@return vec vel
function ObjectRefBase:get_velocity() end

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
function ObjectRefBase:add_velocity(vel) end

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
function ObjectRefBase:move_to(pos, continuous) end

-- --------------------------------- actions -------------------------------- --

--[[
* `punch(puncher, time_from_last_punch, tool_capabilities, dir)`
    * punches the object, triggering all consequences a normal punch would have
    * Other arguments: See `on_punch` for entities
    * Arguments `time_from_last_punch`, `tool_capabilities`, and `dir`
      will be replaced with a default value when the caller sets them to `nil`.
]]
---@param puncher core.ObjectRef
---@param time_from_last_punch number
---@param tool_capabilities core.ToolCapabilities
---@param dir vector
---@return core.Tool.wear wear
function ObjectRefBase:punch(puncher, time_from_last_punch, tool_capabilities, dir) end

--[[
* `right_click(clicker)`:
    * simulates using the 'place/use' key on the object
    * triggers all consequences as if a real player had done this
    * `clicker` is another `ObjectRef` which has clicked
    * note: this is called `right_click` for historical reasons only
]]
---@param clicker core.ObjectRef
function ObjectRefBase:right_click(clicker) end

-- --------------------------------- health --------------------------------- --

--[[
* `get_hp()`: returns number of health points
]]
---@nodiscard
---@return integer hp
function ObjectRefBase:get_hp() end

--[[
* `set_hp(hp, reason)`: set number of health points
    * See reason in register_on_player_hpchange
    * Is limited to the range of 0 ... 65535 (2^16 - 1)
    * For players: HP are also limited by `hp_max` specified in object properties
]]
---@param hp integer
---@param reason core.PlayerHPChangeReason?
function ObjectRefBase:set_hp(hp, reason) end

-- ------------------------- inventory and wielding ------------------------- --

--[[
* `get_inventory()`: returns an `InvRef` for players, otherwise returns `nil`
]]
---@nodiscard
---@return nil
function ObjectRefBase:get_inventory() end

--[[
* `get_wield_list()`: returns the name of the inventory list the wielded item
   is in.
]]
---@nodiscard
---@return core.InventoryList
function ObjectRefBase:get_wield_list() end

--[[
* `get_wield_index()`: returns the wield list index of the wielded item (starting with 1)
]]
---@nodiscard
---@return integer
function ObjectRefBase:get_wield_index() end

--[[
* `get_wielded_item()`: returns a copy of the wielded item as an `ItemStack`
]]
---@nodiscard
---@return core.ItemStack item
function ObjectRefBase:get_wielded_item() end

--[[
* `set_wielded_item(item)`: replaces the wielded item, returns `true` if
  successful.
]]
---@param item core.Item
function ObjectRefBase:set_wielded_item(item) end

-- ---------------------------------- armor --------------------------------- --

--[[
* `get_armor_groups()`:
    * returns a table with all of the object's armor group ratings
    * syntax: the table keys are the armor group names,
      the table values are the corresponding group ratings
    * see section '`ObjectRef` armor groups' for details
]]
---@nodiscard
---@return core.Groups.armor groups
function ObjectRefBase:get_armor_groups() end

--[[
* `set_armor_groups({group1=rating, group2=rating, ...})`
    * sets the object's full list of armor groups
    * same table syntax as for `get_armor_groups`
    * note: all armor groups not in the table will be removed
]]
---@param groups core.Groups.armor
function ObjectRefBase:set_armor_groups(groups) end

-- -------------------------------- animation ------------------------------- --

--[[
* `set_animation(frame_range, frame_speed, frame_blend, frame_loop)`
    * Sets the object animation parameters and (re)starts the animation
    * Animations only work with a `"mesh"` visual
    * `frame_range`: Beginning and end frame (as specified in the mesh file).
       * Syntax: `{x=start_frame, y=end_frame}`
       * Animation interpolates towards the end frame but stops when it is reached
       * If looped, there is no interpolation back to the start frame
       * If looped, the model should look identical at start and end
       * default: `{x=1.0, y=1.0}`
    * `frame_speed`: How fast the animation plays, in frames per second (number)
       * default: `15.0`
    * `frame_blend`: number, default: `0.0`
    * `frame_loop`: If `true`, animation will loop. If false, it will play once
       * default: `true`
]]
---@param frame_range vec2.xy?
---@param frame_speed number?
---@param frame_blend number?
---@param frame_loop boolean?
function ObjectRefBase:set_animation(frame_range, frame_speed, frame_blend, frame_loop) end

--[[
* `get_animation()`: returns current animation parameters set by `set_animation`:
    * `frame_range`, `frame_speed`, `frame_blend`, `frame_loop`.
]]
---@nodiscard
---@return vec2.xy frame_range, number frame_speed, number frame_blend, boolean frame_loop
function ObjectRefBase:get_animation() end

--[[
* `set_animation_frame_speed(frame_speed)`
    * Sets the frame speed of the object's animation
    * Unlike `set_animation`, this will not restart the animation
    * `frame_speed`: See `set_animation`
]]
---@param frame_speed number
function ObjectRefBase:set_animation_frame_speed(frame_speed) end

-- ------------------------------- attachment ------------------------------- --

--[[
* `set_attach(parent[, bone, position, rotation, forced_visible])`
    * Attaches object to `parent`
    * See 'Attachments' section for details
    * `parent`: `ObjectRef` to attach to
    * `bone`: Bone to attach to. Default is `""` (the root bone)
    * `position`: relative position, default `{x=0, y=0, z=0}`
    * `rotation`: relative rotation in degrees, default `{x=0, y=0, z=0}`
    * `forced_visible`: Boolean to control whether the attached entity
       should appear in first person, default `false`.
    * This command may fail silently (do nothing) when it would result
      in circular attachments.
]]
---@param parent core.ObjectRef
---@param bone string?
---@param position vector?
---@param rotation vector?
---@param forced_visible boolean?
function ObjectRefBase:set_attach(parent, bone, position, rotation, forced_visible) end

--[[
* `get_attach()`:
    * returns current attachment parameters or nil if it isn't attached
    * If attached, returns `parent`, `bone`, `position`, `rotation`, `forced_visible`
]]
---@nodiscard
---@return core.ObjectRef? parent, string? bones, vector? positions, vector? rotation, boolean? forced_visible
function ObjectRefBase:get_attach() end

--[[
* `get_children()`: returns a list of ObjectRefs that are attached to the
    object.
]]
---@nodiscard
---@return core.ObjectRef[]
function ObjectRefBase:get_children() end

--[[
* `set_detach()`: Detaches object. No-op if object was not attached.]]
function ObjectRefBase:set_detach() end

-- ---------------------------------- bones --------------------------------- --

--[[ ObjectRef:set_bone_position() .. ObjectRef:get_bone_overrides() split off into ./bones.lua ]]--

-- ----------------------------- object property ---------------------------- --

--[[
* `set_properties(object property table)`
]]
---@param objprops core.ObjectProperties.set
function ObjectRefBase:set_properties(objprops) end

--[[
* `get_properties()`: returns a table of all object properties
]]
---@nodiscard
---@return core.ObjectProperties.get
function ObjectRefBase:get_properties() end

-- -------------------------------- observer -------------------------------- --

--[[
* `set_observers(observers)`: sets observers (players this object is sent to)
    * If `observers` is `nil`, the object's observers are "unmanaged":
      The object is sent to all players as governed by server settings. This is the default.
    * `observers` is a "set" of player names: `{name1 = true, name2 = true, ...}`
        * A set is a table where the keys are the elements of the set
          (in this case, *valid* player names) and the values are all `true`.
    * Attachments: The *effective observers* of an object are made up of
      all players who can observe the object *and* are also effective observers
      of its parent object (if there is one).
    * Players are automatically added to their own observer sets.
      Players **must** effectively observe themselves.
    * Object activation and deactivation are unaffected by observability.
    * Attached sounds do not work correctly and thus should not be used
      on objects with managed observers yet.
]]
---@param observers table<string, boolean>?
function ObjectRefBase:set_observers(observers) end

--[[
* `get_observers()`:
    * throws an error if the object is invalid
    * returns `nil` if the observers are unmanaged
    * returns a table with all observer names as keys and `true` values (a "set") otherwise
]]
---@nodiscard
---@return  table<string, boolean>? observers
function ObjectRefBase:get_observers() end

--[[
* `get_effective_observers()`:
    * Like `get_observers()`, but returns the "effective" observers, taking into account attachments
    * Time complexity: O(nm)
        * n: number of observers of the involved entities
        * m: number of ancestors along the attachment chain
]]
---@nodiscard
---@return  table<string, boolean>
function ObjectRefBase:get_effective_observers() end

-- -------------------------------- is player ------------------------------- --

--[[
* `is_player()`: returns true for players, false otherwise
]]
---@nodiscard
---@return false
function ObjectRefBase:is_player() end

-- --------------------------------- nametag -------------------------------- --

--[[ ObjectRef:get_nametag_attributes() .. ObjectRef:set_nametag_attributes() split off into ./nametag.lua ]]--

-- ---------------------------------- GUID ---------------------------------- --

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
function ObjectRefBase:get_guid() end