---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: HUD
-- luanti/doc/lua_api.md: Definition tables > HUD Definition

--[[
WIPDOC
]]
---@alias core.HUDDef.compass.regular.direction
--- | 0
--- | 1

--[[
WIPDOC
]]
---@alias core.HUDDef.compass.scalable.direction
--- | 2
--- | 3

--[[
WIPDOC
]]
---@class core.HUDDef.compass.regular : _.HUDDef.__base, _.HUDDef.position, _.HUDDef.alignment
--[[
WIPDOC
]]
---@field  type "compass"
--[[
* `direction`: How the image is rotated/translated:
  * 0 - Rotate as heading direction
  * 1 - Rotate in reverse direction
  * 2 - Translate as landscape direction
  * 3 - Translate in reverse direction

If translation is chosen, texture is repeated horizontally to fill the whole element.
]]
---@field direction core.HUDDef.compass.regular.direction?
--[[
WIPDOC
]]
---@field text string
--[[
WIPDOC
]]
---@field size vec2.xy

--[[
WIPDOC
]]
---@class core.HUDDef.compass.scalable
--[[
WIPDOC
]]
---@field scale vec2.xy?
--[[
WIPDOC
]]
---@field direction core.HUDDef.compass.scalable.direction

--[[
WIPDOC
]]
---@alias core.HUDDef.compass
--- | core.HUDDef.compass.regular
--- | core.HUDDef.compass.scalable