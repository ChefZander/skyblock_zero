---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- -------------------------- PlayerPhysicsOverride ------------------------- --

--[[
WIPDOC
]]
---@class core.PlayerPhysicsOverride.set
--[[
WIPDOC
]]
---@field speed number?
--[[
WIPDOC
]]
---@field speed_walk number?
--[[
WIPDOC
]]
---@field speed_climb number?
--[[
WIPDOC
]]
---@field speed_crouch number?
--[[
WIPDOC
]]
---@field speed_fast number?
--[[
WIPDOC
]]
---@field jump number?
--[[
WIPDOC
]]
---@field gravity number?
--[[
WIPDOC
]]
---@field liquid_fluidity number?
--[[
WIPDOC
]]
---@field liquid_fluidity_smooth number?
--[[
WIPDOC
]]
---@field liquid_sink number?
--[[
WIPDOC
]]
---@field acceleration_default number?
--[[
WIPDOC
]]
---@field acceleration_air number?
--[[
WIPDOC
]]
---@field acceleration_fast number?
--[[
WIPDOC
]]
---@field sneak number?
--[[
WIPDOC
]]
---@field sneak_glitch number?
--[[
WIPDOC
]]
---@field new_move number?

--[[
WIPDOC
]]
---@class core.PlayerPhysicsOverride.get
--[[
WIPDOC
]]
---@field speed number
--[[
WIPDOC
]]
---@field speed_walk number
--[[
WIPDOC
]]
---@field speed_climb number
--[[
WIPDOC
]]
---@field speed_crouch number
--[[
WIPDOC
]]
---@field speed_fast number
--[[
WIPDOC
]]
---@field jump number
--[[
WIPDOC
]]
---@field gravity number
--[[
WIPDOC
]]
---@field liquid_fluidity number
--[[
WIPDOC
]]
---@field liquid_fluidity_smooth number
--[[
WIPDOC
]]
---@field liquid_sink number
--[[
WIPDOC
]]
---@field acceleration_default number
--[[
WIPDOC
]]
---@field acceleration_air number
--[[
WIPDOC
]]
---@field acceleration_fast number
--[[
WIPDOC
]]
---@field sneak number
--[[
WIPDOC
]]
---@field sneak_glitch number
--[[
WIPDOC
]]
---@field new_move number


-- ---------------------------- PlayerRef methods --------------------------- --

---@class core.PlayerRef
local PlayerRef

--[[
WIPDOC
]]
---@param override_table core.PlayerPhysicsOverride.set
function PlayerRef:set_physics_override(override_table) end

--[[
* `get_physics_override()`: returns the table given to `set_physics_override`
]]
---@nodiscard
---@return core.PlayerPhysicsOverride.get override_table
function PlayerRef:get_physics_override() end