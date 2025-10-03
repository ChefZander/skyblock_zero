---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Nodes
-- luanti/doc/lua_api.md: Nodes > Node paramtypes

--[[
WIPDOC
]]
---@alias core.Node.name
--- | "unknown"
--- | "air"
--- | "ignore"
--- | string

--[[
WIPDOC
]]
---@alias core.Node.namelike
--- | core.Groups.node
--- | core.Node.name

-- ------------------------------- Node.param1 ------------------------------ --

--[[
WIPDOC
]]
---@alias core.Light integer

--[[
WIPDOC
]]
---@alias core.Light.part integer

--[[
WIPDOC
]]
---@alias core.Light.source integer

--[[
WIPDOC
]]
---@alias core.Param1 integer

-- ------------------------------- Node.param2 ------------------------------ --

--[[
WIPDOC
]]
---@alias core.Param2.wallmounted integer

--[[
WIPDOC
]]
---@alias core.Param2.facedir integer

--[[
WIPDOC
]]
---@alias core.Param2.4dir integer

--[[
WIPDOC
]]
---@alias core.Param2.leveled integer

--[[
WIPDOC
]]
---@alias core.Param2.leveled.rooted_plantlike integer

--[[
WIPDOC
]]
---@alias core.Param2.degrotate integer

--[[
WIPDOC
]]
---@alias core.Param2.meshoptions.plantlike integer

--[[
WIPDOC
]]
---@alias core.Param2.facedir.color integer

--[[
WIPDOC
]]
---@alias core.Param2.4dir.color integer

--[[
WIPDOC
]]
---@alias core.Param2.wallmounted.color integer

--[[
WIPDOC
]]
---@alias core.Param2.glasslikeliquidlevel.liquid integer

--[[
WIPDOC
]]
---@alias core.Param2.glasslikeliquidlevel.frame integer

--[[
WIPDOC
]]
---@alias core.Param2.glasslikeliquidlevel integer

--[[
WIPDOC
]]
---@alias core.Param2.degrotate.color integer

--[[
WIPDOC
]]
---@alias core.Param2 integer

-- ---------------------------------- Node ---------------------------------- --

--[[
WIPDOC
]]
---@class core.Node.get
--[[
WIPDOC
]]
---@field name string
--[[
WIPDOC
]]
---@field param1 core.Param1
--[[
WIPDOC
]]
---@field param2 core.Param2

--[[
WIPDOC
]]
---@class core.Node.set
--[[
WIPDOC
]]
---@field name string
--[[
WIPDOC
]]
---@field param1 core.Param1?
--[[
WIPDOC
]]
---@field param2 core.Param2?
