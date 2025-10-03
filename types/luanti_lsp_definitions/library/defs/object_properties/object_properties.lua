---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Entity damage mechanism
-- luanti/doc/lua_api.md: Definition tables > Object properties

-- Default values are injected, so nil value does not persist -> .set and .get

-- INTERPRETATION: follow the same interpretation in ObjectRef. ObjectProperties
-- assumes it's an entity, and its fields overridden by PlayerProperties. If
-- there were any entity exclusive fields, EntityProperties would exist

--[[
WIPDOC
]]
core.PLAYER_MAX_HP_DEFAULT = 20

--[[
WIPDOC
]]
core.PLAYER_MAX_BREATH_DEFAULT = 10

-- ------------------------- ObjectProperties.__base ------------------------ --

---@class _.ObjectProperties.__base.set
--[[
Defines the maximum and default HP of the object.
For Lua entities, the maximum is not enforced.
For players, this defaults to `core.PLAYER_MAX_HP_DEFAULT` (20).
For Lua entities, the default is 10.
]]
---@field hp_max integer?

---@class _.ObjectProperties.__base.get
--[[
Defines the maximum and default HP of the object.
For Lua entities, the maximum is not enforced.
For players, this defaults to `core.PLAYER_MAX_HP_DEFAULT` (20).
For Lua entities, the default is 10.
]]
---@field hp_max integer

-- -------------------------------- collision ------------------------------- --

---@class _.ObjectProperties.__base.set
--[[
Collide with `walkable` nodes.
]]
---@field physical boolean?
--[[
Collide with other objects if physical = true
]]
---@field collide_with_objects boolean?


---@class _.ObjectProperties.__base.get
--[[
Collide with `walkable` nodes.
]]
---@field physical boolean
--[[
Collide with other objects if physical = true
]]
---@field collide_with_objects boolean

--[[ ObjectPropertiesBaseSet.collisionbox .. ObjectPropertiesBaseGet.selectionbox split off into box.lua ]]--

-- -------------------------------------------------------------------------- --

---@class _.ObjectProperties.__base.set
--[[
Can be `true` if it is pointable, `false` if it can be pointed through,
or `"blocking"` if it is pointable but not selectable.
Clients older than 5.9.0 interpret `pointable = "blocking"` as `pointable = true`.
Can be overridden by the `pointabilities` of the held item.
]]
---@field pointable "blocking"|boolean?
--[[
Multipliers for the visual size. If `z` is not specified, `x` will be used
to scale the entity along both horizontal axes.
]]
---@field visual_size vector?
--[[
Currently unused.
]]
---@field colors {}?
--[[
If false, object is invisible and can't be pointed.
]]
---@field is_visible boolean?
--[[
If true, object is able to make footstep sounds of nodes
(see node sound definition for details).
]]
---@field makes_footstep_sound boolean?
--[[
Set constant rotation in radians per second, positive or negative.
Object rotates along the local Y-axis, and works with set_rotation.
Set to 0 to disable constant rotation.
]]
---@field automatic_rotate number?
--[[
If positive number, object will climb upwards when it moves
horizontally against a `walkable` node, if the height difference
is within `stepheight` and if the object current max Y in the world
is greater or equal than the node min Y.
]]
---@field stepheight number?
--[[
Automatically set yaw to movement direction, offset in degrees.
'false' to disable.
]]
---@field automatic_face_movement_dir number|false?
--[[
Limit automatic rotation to this value in degrees per second.
No limit if value <= 0.
]]
---@field automatic_face_movement_max_rotation_per_sec number?
--[[
Add this much extra lighting when calculating texture color.
Value < 0 disables light's effect on texture color.
For faking self-lighting, UI style entities, or programmatic coloring
in mods.
]]
---@field glow core.Light.source?

---@class _.ObjectProperties.__base.get
--[[
Can be `true` if it is pointable, `false` if it can be pointed through,
or `"blocking"` if it is pointable but not selectable.
Clients older than 5.9.0 interpret `pointable = "blocking"` as `pointable = true`.
Can be overridden by the `pointabilities` of the held item.
]]
---@field pointable "blocking"|boolean
--[[
Multipliers for the visual size. If `z` is not specified, `x` will be used
to scale the entity along both horizontal axes.
]]
---@field visual_size vector
--[[
Currently unused.
]]
---@field colors {}
--[[
If false, object is invisible and can't be pointed.
]]
---@field is_visible boolean
--[[
If true, object is able to make footstep sounds of nodes
(see node sound definition for details).
]]
---@field makes_footstep_sound boolean
--[[
Set constant rotation in radians per second, positive or negative.
Object rotates along the local Y-axis, and works with set_rotation.
Set to 0 to disable constant rotation.
]]
---@field automatic_rotate number
--[[
If positive number, object will climb upwards when it moves
horizontally against a `walkable` node, if the height difference
is within `stepheight` and if the object current max Y in the world
is greater or equal than the node min Y.
]]
---@field stepheight number
--[[
Automatically set yaw to movement direction, offset in degrees.
'false' to disable.
]]
---@field automatic_face_movement_dir number|false
--[[
Limit automatic rotation to this value in degrees per second.
No limit if value <= 0.
]]
---@field automatic_face_movement_max_rotation_per_sec number
--[[
Add this much extra lighting when calculating texture color.
Value < 0 disables light's effect on texture color.
For faking self-lighting, UI style entities, or programmatic coloring
in mods.
]]
---@field glow core.Light.source

-- --------------------------------- nametag -------------------------------- --

---@class _.ObjectProperties.__base.set
--[[
The name to display on the head of the object. By default empty.
If the object is a player, a nil or empty nametag is replaced by the player's name.
For all other objects, a nil or empty string removes the nametag.
To hide a nametag, set its color alpha to zero. That will disable it entirely.
]]
---@field nametag string?
--[[
Sets text color of nametag
]]
---@field nametag_color core.ColorSpec?
--[[
Sets background color of nametag
`false` will cause the background to be set automatically based on user settings.
Default: false
]]
---@field nametag_bgcolor core.ColorSpec?
--[[
Sets the font size of the nametag in pixels.
`false` will cause the size to be set automatically based on user settings.
Default: false
]]
---@field nametag_fontsize integer|false?
--[[
Sets the font size of the nametag in pixels.
`false` will cause the size to be set automatically based on user settings.
Default: false
]]
---@field nametag_scale_z boolean?

---@class _.ObjectProperties.__base.get
--[[
The name to display on the head of the object. By default empty.
If the object is a player, a nil or empty nametag is replaced by the player's name.
For all other objects, a nil or empty string removes the nametag.
To hide a nametag, set its color alpha to zero. That will disable it entirely.
]]
---@field nametag string
--[[
Sets text color of nametag
]]
---@field nametag_color core.ColorSpec
--[[
Sets background color of nametag
`false` will cause the background to be set automatically based on user settings.
Default: false
]]
---@field nametag_bgcolor core.ColorSpec


-- -------------------------------------------------------------------------- --

---@class _.ObjectProperties.__base.set
--[[
Same as infotext for nodes. Empty by default
]]
---@field infotext string?
--[[
If false, never save this object statically. It will simply be
deleted when the block gets unloaded.
The get_staticdata() callback is never called then.
Defaults to 'true'.
]]
---@field static_save boolean?
--[[
Texture modifier to be applied for a short duration when object is hit
]]
---@field damage_texture_modifier core.Texture?
--[[
Defaults to true for players, false for other entities.
If set to true the entity will show as a marker on the minimap.
]]
---@field show_on_minimap boolean?

---@class _.ObjectProperties.__base.get
--[[
Same as infotext for nodes. Empty by default
]]
---@field infotext string
--[[
If false, never save this object statically. It will simply be
deleted when the block gets unloaded.
The get_staticdata() callback is never called then.
Defaults to 'true'.
]]
---@field static_save boolean
--[[
Texture modifier to be applied for a short duration when object is hit
]]
---@field damage_texture_modifier core.Texture
--[[
Defaults to true for players, false for other entities.
If set to true the entity will show as a marker on the minimap.
]]
---@field show_on_minimap boolean

-- ---------------------------- ObjectProperties ---------------------------- --

---@alias core.ObjectProperties.set
--- | core.ObjectProperties.cube.set
--- | core.ObjectProperties.sprite.set
--- | core.ObjectProperties.upright_sprite.set
--- | core.ObjectProperties.mesh.set
--- | core.ObjectProperties.wielditem.set
--- | core.ObjectProperties.item.set
--- | core.ObjectProperties.node.set

---@alias core.ObjectProperties.get
--- | core.ObjectProperties.cube.get
--- | core.ObjectProperties.sprite.get
--- | core.ObjectProperties.upright_sprite.get
--- | core.ObjectProperties.mesh.get
--- | core.ObjectProperties.wielditem.get
--- | core.ObjectProperties.item.get
--- | core.ObjectProperties.node.get