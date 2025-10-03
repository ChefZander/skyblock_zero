---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Helper functions

--[[
WIPDOC
]]
---@class core.DigParams.not_diggable
--[[
WIPDOC
]]
---@field diggable false

--[[
WIPDOC
]]
---@class core.DigParams.item.diggable
--[[
WIPDOC
]]
---@field diggable true
--[[
WIPDOC
]]
---@field time number

--[[
WIPDOC
]]
---@class core.DigParams.tool.diggable : core.DigParams.item.diggable
--[[
WIPDOC
]]
---@field wear core.Tool.wear

--[[
WIPDOC
]]
---@alias core.DigParams
--- | core.DigParams.not_diggable
--- | core.DigParams.item.diggable
--- | core.DigParams.tool.diggable

-- ---------------------------- core.* functions ---------------------------- --

--[[
WIPDOC
]]
---@nodiscard
---@param groups core.Groups.node
---@param tool_capabilities core.ToolCapabilities
---@param wear core.Tool.wear?
---@return core.DigParams
function core.get_dig_params(groups, tool_capabilities, wear) end