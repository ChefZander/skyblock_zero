---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

--[[
WIPDOC
]]
---@class core.EntityRef : _.ObjectRef.__base
local EntityRef = {}

-- ----------------------------- entity lifetime ---------------------------- --

--[[
* `remove()`: remove object
    * The object is removed after returning from Lua. However the `ObjectRef`
      itself instantly becomes unusable with all further method calls having
      no effect and returning `nil`.
]]
function EntityRef:remove() end

-- ---------------------- entity position and movement ---------------------- --

--[[
* `set_velocity(vel)`
    * Sets the velocity
    * `vel` is a vector, e.g. `{x=0.0, y=2.3, z=1.0}`
]]
---@param vel vector
function EntityRef:set_velocity(vel) end

--[[
* `set_acceleration(acc)`
    * Sets the acceleration
    * `acc` is a vector
]]
---@param acc vector
function EntityRef:set_acceleration(acc) end

--[[
* `get_acceleration()`: returns the acceleration, a vector
]]
---@nodiscard
---@return vec? acc
function EntityRef:get_acceleration() end

-- --------------------- entity rotation and orientation -------------------- --

--[[
* `set_rotation(rot)`
    * Sets the rotation
    * `rot` is a vector (radians). X is pitch (elevation), Y is yaw (heading
      and Z is roll (bank).
    * Does not reset rotation incurred through `automatic_rotate`.
      Remove & re-add your objects to force a certain rotation.
]]
---@param rot vector
function EntityRef:set_rotation(rot) end

--[[
* `get_rotation()`: returns the rotation, a vector (radians)
]]
---@nodiscard
---@return vec? rot
function EntityRef:get_rotation() end

--[[
* `set_yaw(yaw)`: sets the yaw in radians (heading).
]]
---@param yaw number
function EntityRef:set_yaw(yaw) end

--[[
* `get_yaw()`: returns number in radians
]]
---@nodiscard
---@return number yaw
function EntityRef:get_yaw() end

-- ----------------------------- entity texture ----------------------------- --

--[[
* `set_texture_mod(mod)`
    * Set a texture modifier to the base texture, for sprites and meshes.
    * When calling `set_texture_mod` again, the previous one is discarded.
    * `mod` the texture modifier. See [Texture modifiers].
]]
---@param mod core.Texture
function EntityRef:set_texture_mod(mod) end

--[[
* `get_texture_mod()` returns current texture modifier
]]
---@nodiscard
---@return core.Texture? mod
function EntityRef:get_texture_mod() end

--[[
WIPDOC
]]
---@class core.EntityRef.select_x_by_camera.strict
--[[
WIPDOC
]]
---@field [1] integer
--[[
WIPDOC
]]
---@field [2] integer
--[[
WIPDOC
]]
---@field [3] integer
--[[
WIPDOC
]]
---@field [4] integer
--[[
WIPDOC
]]
---@field [5] integer
--[[
WIPDOC
]]
---@field [6] integer

--[[
WIPDOC
]]
---@alias core.EntityRef.select_x_by_camera
--- | core.EntityRef.select_x_by_camera.strict
--- | string[]

--[[
* `set_sprite(start_frame, num_frames, framelength, select_x_by_camera)`
    * Specifies and starts a sprite animation
    * Only used by `sprite` and `upright_sprite` visuals
    * Animations iterate along the frame `y` position.
    * `start_frame`: {x=column number, y=row number}, the coordinate of the
      first frame, default: `{x=0, y=0}`
    * `num_frames`: Total frames in the texture, default: `1`
    * `framelength`: Time per animated frame in seconds, default: `0.2`
    * `select_x_by_camera`: Only for visual = `sprite`. Changes the frame `x`
      position according to the view direction. default: `false`.
        * First column:  subject facing the camera
        * Second column: subject looking to the left
        * Third column:  subject backing the camera
        * Fourth column: subject looking to the right
        * Fifth column:  subject viewed from above
        * Sixth column:  subject viewed from below
]]
---@param start_frame vec2.xy?
---@param num_frames integer?
---@param framelength number?
---@param select_x_by_camera core.EntityRef.select_x_by_camera|boolean?
function EntityRef:set_sprite(start_frame, num_frames, framelength, select_x_by_camera) end

-- ------------------------------- entity misc ------------------------------ --

--[[
* `get_luaentity()`:
    * Returns the object's associated luaentity table, if there is one
    * Otherwise returns `nil` (e.g. for players
]]
---@nodiscard
---@return core.Entity
function EntityRef:get_luaentity() end

--[[
* `get_entity_name()`:
    * **Deprecated**: Will be removed in a future version,
      use `:get_luaentity().name` instead.
]]
---@nodiscard
---@deprecated
---@return core.Entity.name
function EntityRef:get_entity_name() end
