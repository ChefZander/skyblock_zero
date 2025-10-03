---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: HUD
-- luanti/doc/lua_api.md: Definition tables > HUD Definition

--[[
WIPDOC
]]
---@alias core.HUDDef.text.style
--- | 0
--- | 1
--- | 2
--- | 3
--- | 4
--- | 5
--- | 6
--- | 7

--[[
WIPDOC
]]
---@class core.HUDDef.text : _.HUDDef.__base, _.HUDDef.position, _.HUDDef.alignment
--[[
WIPDOC
]]
---@field  type "text"
--[[
WIPDOC
]]
---@field scale vec2.xy
--[[
WIPDOC
]]
---@field text string
--[[
WIPDOC
]]
---@field number integer?
--[[
WIPDOC
]]
---@field size vec2.xy?
--[[
WIPDOC
]]
---@field style core.HUDDef.text.style?
