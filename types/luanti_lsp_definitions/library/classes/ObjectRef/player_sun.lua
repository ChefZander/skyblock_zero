---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- --------------------------- PlayerSunParameters -------------------------- --

--[[
WIPDOC
]]
---@class core.PlayerSunParameters.set
--[[
WIPDOC
]]
---@field visible boolean?
--[[
WIPDOC
]]
---@field texture core.Texture?
--[[
WIPDOC
]]
---@field tonemap core.Texture?
--[[
WIPDOC
]]
---@field sunrise core.Texture?
--[[
WIPDOC
]]
---@field sunrise_visible boolean?
--[[
WIPDOC
]]
---@field scale number?

--[[
WIPDOC
]]
---@class core.PlayerSunParameters.get
--[[
WIPDOC
]]
---@field visible boolean
--[[
WIPDOC
]]
---@field texture core.Texture
--[[
WIPDOC
]]
---@field tonemap core.Texture
--[[
WIPDOC
]]
---@field sunrise core.Texture
--[[
WIPDOC
]]
---@field sunrise_visible boolean
--[[
WIPDOC
]]
---@field scale number

-- ---------------------------- PlayerRef methods --------------------------- --

---@class core.PlayerRef
local PlayerRef

--[[
WIPDOC
]]
---@param sun_parameters core.PlayerSunParameters.set
function PlayerRef:set_sun(sun_parameters) end

--[[
* `get_sun()`: returns a table with the current sun parameters as in
    `set_sun`.
]]
---@nodiscard
---@return core.PlayerSunParameters.get sun_parameters
function PlayerRef:get_sun() end