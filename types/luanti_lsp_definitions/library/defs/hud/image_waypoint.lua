---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: HUD
-- luanti/doc/lua_api.md: Definition tables > HUD Definition

-- NOTE: while it *might* look like image_waypoint should derive from waypoint,
-- that is false. It's instead derived from image

--[[
WIPDOC
]]
---@class core.HUDDef.image_waypoint : _.HUDDef.__base, _.HUDDef.alignment, _.HUDDef.world_pos
--[[
WIPDOC
]]
---@field  type "image_waypoint"
--[[
WIPDOC
]]
---@field scale vec2.xy?
--[[
WIPDOC
]]
---@field text string
