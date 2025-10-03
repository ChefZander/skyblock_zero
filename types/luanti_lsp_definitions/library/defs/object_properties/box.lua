---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Object properties

-- ------------------ ObjectProperties.collisionbox.strict ------------------ --

--[[
WIPDOC
]]
---@class core.ObjectProperties.collisionbox.strict
--[[
WIPDOC
]]
---@field [1] number
--[[
WIPDOC
]]
---@field [2] number
--[[
WIPDOC
]]
---@field [3] number
--[[
WIPDOC
]]
---@field [4] number
--[[
WIPDOC
]]
---@field [5] number
--[[
WIPDOC
]]
---@field [6] number

--[[
WIPDOC
]]
---@alias core.ObjectProperties.collisionbox
--- | core.ObjectProperties.collisionbox.strict
--- | number[]

-- ------------------ ObjectProperties.selectionbox.strict ------------------ --

--[[
WIPDOC
--]]
---@class core.ObjectProperties.selectionbox.strict.set : core.ObjectProperties.collisionbox.strict
--[[
WIPDOC
]]
---@field rotate boolean?

--[[
WIPDOC
--]]
---@class core.ObjectProperties.selectionbox.strict.get : core.ObjectProperties.collisionbox.strict
--[[
WIPDOC
]]
---@field rotate boolean

--[[
WIPDOC
]]
---@alias core.ObjectProperties.selectionbox.set
--- | core.ObjectProperties.selectionbox.strict.set
--- | number[]

--[[
WIPDOC
]]
---@alias core.ObjectProperties.selectionbox.get
--- | core.ObjectProperties.selectionbox.strict.get
--- | number[]

-- ----------------------- ObjectPropertiesBase fields ---------------------- --

---@class _.ObjectProperties.__base.set
--[[
{ xmin, ymin, zmin, xmax, ymax, zmax } in nodes from object position.
Collision boxes cannot rotate, setting `rotate = true` on it has no effect.
If not set, the selection box copies the collision box, and will also not rotate.
]]
---@field collisionbox core.ObjectProperties.collisionbox?
--[[
If `rotate = false`, the selection box will not rotate with the object itself, remaining fixed to the axes.
If `rotate = true`, it will match the object's rotation and any attachment rotations.
Raycasts use the selection box and object's rotation, but do *not* obey attachment rotations.
For server-side raycasts to work correctly,
the selection box should extend at most 5 units in each direction.
]]
---@field selectionbox core.ObjectProperties.selectionbox.set?

---@class _.ObjectProperties.__base.get
--[[
{ xmin, ymin, zmin, xmax, ymax, zmax } in nodes from object position.
Collision boxes cannot rotate, setting `rotate = true` on it has no effect.
If not set, the selection box copies the collision box, and will also not rotate.
]]
---@field collisionbox core.ObjectProperties.collisionbox
--[[
If `rotate = false`, the selection box will not rotate with the object itself, remaining fixed to the axes.
If `rotate = true`, it will match the object's rotation and any attachment rotations.
Raycasts use the selection box and object's rotation, but do *not* obey attachment rotations.
For server-side raycasts to work correctly,
the selection box should extend at most 5 units in each direction.
]]
---@field selectionbox core.ObjectProperties.selectionbox.get
