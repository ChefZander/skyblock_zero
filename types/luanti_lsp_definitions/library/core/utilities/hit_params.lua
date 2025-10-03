---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Helper functions

--[[
WIPDOC
]]
---@class core.HitParams.item
--[[
WIPDOC
]]
---@field hp integer

--[[
WIPDOC
]]
---@class core.HitParams.tool : core.HitParams.item
--[[
WIPDOC
]]
---@field wear core.Tool.wear

--[[
WIPDOC
]]
---@alias core.HitParams
--- | core.HitParams.item
--- | core.HitParams.tool

-- ---------------------------- core.* functions ---------------------------- --

--[[
WIPDOC
]]
---@nodiscard
---@param groups core.Groups.armor
---@param tool_capabilities core.ToolCapabilities
---@param time_from_last_punch number?
---@param wear core.Tool.wear?
---@return core.HitParams
function core.get_hit_params(groups, tool_capabilities, time_from_last_punch, wear) end