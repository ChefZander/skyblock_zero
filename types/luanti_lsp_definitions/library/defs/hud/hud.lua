---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: HUD
-- luanti/doc/lua_api.md: Definition tables > HUD Definition

--[[
WIPDOC
]]
---@class core.HUDID : integer

--[[
WIPDOC
]]
---@alias core.HUDDef.keys
--- | "position"
--- | "name"
--- | "scale"
--- | "text"
--- | "text2"
--- | "number"
--- | "item"
--- | "direction"
--- | "alignment"
--- | "offset"
--- | "world_pos"
--- | "size"
--- | "z_index"
--- | "style"
--- | "precision"

-- ------------------------------ HUDDef.__base ----------------------------- --

---@class _.HUDDef.__base
--[[
WIPDOC
]]
---@field  type "image"
--[[
WIPDOC
]]
---@field  name string
--[[
WIPDOC
]]
---@field offset vec2.xy?
--[[
WIPDOC
]]
---@field  z_index integer

-- ----------------------------- HUDDef partials ---------------------------- --

---@class _.HUDDef.position
--[[
Top left corner position of element
]]
---@field position vec2.xy

--[[
WIPDOC
]]
---@alias core.HUDDef.direction
--- | 0
--- | 1
--- | 2
--- | 3

---@class _.HUDDef.direction
--[[
WIPDOC
]]
---@field direction core.HUDDef.direction?

---@class _.HUDDef.alignment
--[[
WIPDOC
]]
---@field alignment vec2.xy?

---@class _.HUDDef.world_pos
--[[
WIPDOC
]]
---@field world_pos vec?

-- --------------------------------- HUDDef --------------------------------- --

--[[
WIPDOC
]]
---@alias core.HUDDef
--- | core.HUDDef.image
--- | core.HUDDef.text
--- | core.HUDDef.statbar
--- | core.HUDDef.inventory
--- | core.HUDDef.hotbar
--- | core.HUDDef.waypoint
--- | core.HUDDef.image_waypoint
--- | core.HUDDef.compass
--- | core.HUDDef.minimap