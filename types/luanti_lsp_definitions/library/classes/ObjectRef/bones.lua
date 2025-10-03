---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- -------------------------- BoneOverride.property ------------------------- --

--[[
WIPDOC
]]
---@class core.BoneOverride.property.set
--[[
WIPDOC
]]
---@field vec vector?
--[[
WIPDOC
]]
---@field interpolation number?
--[[
WIPDOC
]]
---@field absolute boolean?

--[[
WIPDOC
]]
---@class core.BoneOverride.property.get
--[[
WIPDOC
]]
---@field vec vector
--[[
WIPDOC
]]
---@field interpolation number
--[[
WIPDOC
]]
---@field absolute boolean


-- ------------------------------ BoneOverride ------------------------------ --

--[[
WIPDOC
]]
---@class core.BoneOverride.set
--[[
WIPDOC
]]
---@field position core.BoneOverride.property.set?
--[[
WIPDOC
]]
---@field rotation core.BoneOverride.property.set?
--[[
WIPDOC
]]
---@field scale core.BoneOverride.property.set?

--[[
WIPDOC
]]
---@class core.BoneOverride.get
--[[
WIPDOC
]]
---@field position core.BoneOverride.property.get
--[[
WIPDOC
]]
---@field rotation core.BoneOverride.property.get
--[[
WIPDOC
]]
---@field scale core.BoneOverride.property.get


-- ---------------------------- ObjectRef methods --------------------------- --

---@class _.ObjectRef.__base
local ObjectRefBase

--[[
* `set_bone_position([bone, position, rotation])`
    * Sets absolute bone overrides, e.g. it is equivalent to
      ```lua
      obj:set_bone_override(bone, {
          position = {vec = position, absolute = true},
      ```
    * **Note:** Rotation is in degrees, not radians.
    * **Deprecated:** Use `set_bone_override` instead.
]]
---@deprecated
---@param bone string
---@param position vector
---@param rotation vector
function ObjectRefBase:set_bone_position(bone, position, rotation) end

--[[
* `get_bone_position(bone)`: returns the previously set position and rotation of the bone
    * Shorthand for `get_bone_override(bone).position.vec, get_bone_override(bone).rotation.vec:apply(math.deg)`.
    * **Note:** Returned rotation is in degrees, not radians.
    * **Deprecated:** Use `get_bone_override` instead.
]]
---@nodiscard
---@deprecated
---@param bone string
---@return  vec position, vec rotation
function ObjectRefBase:get_bone_position(bone) end

--[[
* `set_bone_override(bone, override)`
    * `bone`: string
    * `override`: `{ position = property, rotation = property, scale = property }` or `nil`
    * `override = nil` (including omission) is shorthand for `override = {}` which clears the override
    * Each `property` is a table of the form
      `{ vec = vector, interpolation = 0, absolute = false }` or `nil`
        * `vec` is in the same coordinate system as the model, and in radians for rotation.
          It defaults to `vector.zero()` for translation and rotation and `vector.new(1, 1, 1)` for scale.
        * `interpolation`: The old and new overrides are interpolated over this timeframe (in seconds).
        * `absolute`: If set to `false` (which is the default),
          the override will be relative to the animated property:
            * Translation in the case of `position`;
            * Composition in the case of `rotation`;
            * Per-axis multiplication in the case of `scale`
    * `property = nil` is equivalent to no override on that property
    * **Note:** Unlike `set_bone_position`, the rotation is in radians, not degrees.
    * Compatibility note: Clients prior to 5.9.0 only support absolute position and rotation.
      All values are treated as absolute and are set immediately (no interpolation).
]]
---@param bone string
---@param override core.BoneOverride.set?
function ObjectRefBase:set_bone_override(bone, override) end

--[[
* `get_bone_override(bone)`: returns `override` in the above format
    * **Note:** Unlike `get_bone_position`, the returned rotation is in radians, not degrees.
]]
---@nodiscard
---@param bone string
---@return core.BoneOverride.get
function ObjectRefBase:get_bone_override(bone) end

--[[
* `get_bone_overrides()`: returns all bone overrides as table `{[bonename] = override, ...}`
]]
---@nodiscard
---@return table<string, core.BoneOverride.get>
function ObjectRefBase:get_bone_overrides() end