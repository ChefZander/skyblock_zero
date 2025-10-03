---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- -------------------------- PlayerMoonParameters -------------------------- --

--[[
WIPDOC
]]
---@class core.PlayerMoonParameters.set
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
---@field scale number?

--[[
WIPDOC
]]
---@class core.PlayerMoonParameters.get
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
---@field scale number

-- ---------------------------- PlayerRef methods --------------------------- --

---@class core.PlayerRef
local PlayerRef

--[[
WIPDOC
]]
---@param moon_parameters core.PlayerMoonParameters.set
function PlayerRef:set_moon(moon_parameters) end

--[[
* `get_moon()`: returns a table with the current moon parameters as in
    `set_moon`.
]]
---@nodiscard
---@return core.PlayerMoonParameters.get moon_parameters
function PlayerRef:get_moon() end