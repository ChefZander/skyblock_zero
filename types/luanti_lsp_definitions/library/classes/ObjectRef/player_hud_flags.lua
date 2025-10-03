---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- ----------------------------- PlayerHudFlags ----------------------------- --

--[[
WIPDOC
]]
---@class core.PlayerHudFlags.set
--[[
WIPDOC
]]
---@field hotbar boolean?
--[[
WIPDOC
]]
---@field healthbar boolean?
--[[
WIPDOC
]]
---@field crosshair boolean?
--[[
WIPDOC
]]
---@field wielditem boolean?
--[[
WIPDOC
]]
---@field breathbar boolean?
--[[
WIPDOC
]]
---@field minimap boolean?
--[[
WIPDOC
]]
---@field minimap_radar boolean?
--[[
WIPDOC
]]
---@field basic_debug boolean?

--[[
WIPDOC
]]
---@class core.PlayerHudFlags.get
--[[
WIPDOC
]]
---@field hotbar boolean
--[[
WIPDOC
]]
---@field healthbar boolean
--[[
WIPDOC
]]
---@field crosshair boolean
--[[
WIPDOC
]]
---@field wielditem boolean
--[[
WIPDOC
]]
---@field breathbar boolean
--[[
WIPDOC
]]
---@field minimap boolean
--[[
WIPDOC
]]
---@field minimap_radar boolean
--[[
WIPDOC
]]
---@field basic_debug boolean


-- ---------------------------- PlayerRef methods --------------------------- --

---@class core.PlayerRef
local PlayerRef

--[[
* `hud_set_flags(flags)`: sets specified HUD flags of player.
    * `flags`: A table with the following fields set to boolean values
        * `hotbar`
        * `healthbar`
        * `crosshair`
        * `wielditem`
        * `breathbar`
        * `minimap`: Modifies the client's permission to view the minimap.
          The client may locally elect to not view the minimap.
        * `minimap_radar`: is only usable when `minimap` is true
        * `basic_debug`: Allow showing basic debug info that might give a gameplay advantage.
          This includes map seed, player position, look direction, the pointed node and block bounds.
          Does not affect players with the `debug` privilege.
    * If a flag equals `nil`, the flag is not modified
]]
---@param flags core.PlayerHudFlags.set
function PlayerRef:hud_set_flags(flags) end

--[[
* `hud_get_flags()`: returns a table of player HUD flags with boolean values.
    * See `hud_set_flags` for a list of flags that can be toggled.
]]
---@nodiscard
---@return core.PlayerHudFlags.get flags
function PlayerRef:hud_get_flags() end