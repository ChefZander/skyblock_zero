---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- ------------------------------- PlayerFlags ------------------------------ --

--[[
WIPDOC
]]
---@class core.PlayerFlags.get
--[[
WIPDOC
]]
---@field breathing boolean
--[[
WIPDOC
]]
---@field drowning boolean
--[[
WIPDOC
]]
---@field node_damage boolean

--[[
WIPDOC
]]
---@class core.PlayerFlags.set
--[[
WIPDOC
]]
---@field breathing boolean?
--[[
WIPDOC
]]
---@field drowning boolean?
--[[
WIPDOC
]]
---@field node_damage boolean?


-- ---------------------------- PlayerRef methods --------------------------- --

---@class core.PlayerRef
local PlayerRef

--[[
* `get_flags()`: returns a table of player flags (the following boolean fields):
  * `breathing`: Whether breathing (regaining air) is enabled, default `true`.
  * `drowning`: Whether drowning (losing air) is enabled, default `true`.
  * `node_damage`: Whether the player takes damage from nodes, default `true`.
]]
---@nodiscard
---@return core.PlayerFlags.get flags
function PlayerRef:get_flags() end

--[[
* `set_flags(flags)`: sets flags
  * takes a table in the same format as returned by `get_flags`
  * absent fields are left unchanged
]]
---@param flags core.PlayerFlags.set
function PlayerRef:set_flags(flags) end