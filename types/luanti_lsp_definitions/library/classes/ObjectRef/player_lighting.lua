---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- -------------------------- PlayerLightDef.shadow ------------------------- --

--[[
WIPDOC
]]
---@class core.PlayerLightDef.shadow.set
--[[
WIPDOC
]]
---@field intensity number?
--[[
WIPDOC
]]
---@field tint core.ColorSpec?

--[[
WIPDOC
]]
---@class core.PlayerLightDef.shadow.get
--[[
WIPDOC
]]
---@field intensity number?
--[[
WIPDOC
]]
---@field tint core.ColorSpec?

-- ------------------------- PlayerLightDef.exposure ------------------------ --

--[[
WIPDOC
]]
---@class core.PlayerLightDef.exposure.set
--[[
WIPDOC
]]
---@field luminescence_min number?
--[[
WIPDOC
]]
---@field luminescence_max number?
--[[
WIPDOC
]]
---@field exposure_correction number?
--[[
WIPDOC
]]
---@field speed_dark_bright number?
--[[
WIPDOC
]]
---@field speed_bright_dark number?
--[[
WIPDOC
]]
---@field center_weight_power number?

--[[
WIPDOC
]]
---@class core.PlayerLightDef.exposure.get
--[[
WIPDOC
]]
---@field luminescence_min number
--[[
WIPDOC
]]
---@field luminescence_max number
--[[
WIPDOC
]]
---@field exposure_correction number
--[[
WIPDOC
]]
---@field speed_dark_bright number
--[[
WIPDOC
]]
---@field speed_bright_dark number
--[[
WIPDOC
]]
---@field center_weight_power number

-- -------------------------- PlayerLightDef.bloom -------------------------- --

--[[
WIPDOC
]]
---@class core.PlayerLightDef.bloom.set
--[[
WIPDOC
]]
---@field intensity number?
--[[
WIPDOC
]]
---@field strength_factor number?
--[[
WIPDOC
]]
---@field radius number?

--[[
WIPDOC
]]
---@class core.PlayerLightDef.bloom.get
--[[
WIPDOC
]]
---@field intensity number
--[[
WIPDOC
]]
---@field strength_factor number
--[[
WIPDOC
]]
---@field radius number

-- --------------------- PlayerLightDef.volumetric_light -------------------- --

--[[
WIPDOC
]]
---@class core.PlayerLightDef.volumetric_light.set
--[[
WIPDOC
]]
---@field strength number?

--[[
WIPDOC
]]
---@class core.PlayerLightDef.volumetric_light.get
--[[
WIPDOC
]]
---@field strength number


-- ----------------------------- PlayerLightDef ----------------------------- --

--[[
WIPDOC
]]
---@class core.PlayerLightDef.set
--[[
WIPDOC
]]
---@field saturation number?
--[[
WIPDOC
]]
---@field shadows core.PlayerLightDef.shadow.set?
--[[
WIPDOC
]]
---@field exposure core.PlayerLightDef.exposure.set?
--[[
WIPDOC
]]
---@field bloom core.PlayerLightDef.bloom.set?
--[[
WIPDOC
]]
---@field volumetric_light core.PlayerLightDef.volumetric_light.set?

--[[
WIPDOC
]]
---@class core.PlayerLightDef.get
--[[
WIPDOC
]]
---@field saturation number
--[[
WIPDOC
]]
---@field shadows core.PlayerLightDef.shadow.get
--[[
WIPDOC
]]
---@field exposure core.PlayerLightDef.exposure.get
--[[
WIPDOC
]]
---@field bloom core.PlayerLightDef.bloom.get
--[[
WIPDOC
]]
---@field volumetric_light core.PlayerLightDef.volumetric_light.get

-- ---------------------------- PlayerRef methods --------------------------- --

---@class core.PlayerRef
local PlayerRef

--[[
WIPDOC
]]
---@param light_definition core.PlayerLightDef.set
function PlayerRef:set_lighting(light_definition) end

--[[
* `get_lighting()`: returns the current state of lighting for the player.
    * Result is a table with the same fields as `light_definition` in `set_lighting`.
]]
---@nodiscard
---@return core.PlayerLightDef.get light_definition
function PlayerRef:get_lighting() end