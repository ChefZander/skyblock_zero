---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Tool Capabilities

-- ---------------------- ToolCapabilities.*.groupcaps ---------------------- --

--[[
WIPDOC
]]
---@class core.ToolCapabilities.item.groupcap
--[[
WIPDOC
]]
---@field times number[]?
--[[
WIPDOC
]]
---@field maxlevel integer?

--[[
WIPDOC
]]
---@alias core.ToolCapabilities.item.groupcaps table<core.Groups.node, core.ToolCapabilities.item.groupcap>

--[[
WIPDOC
]]
---@class core.ToolCapabilities.tool.groupcap : core.ToolCapabilities.item.groupcap
--[[
WIPDOC
]]
---@field uses integer?

--[[
WIPDOC
]]
---@alias core.ToolCapabilities.tool.groupcaps table<core.Groups.node, core.ToolCapabilities.tool.groupcap>

-- --------------------- ToolCapabilities.damage_groups --------------------- --

--[[
WIPDOC
]]
---@alias core.ToolCapabilities.damage_groups table<core.Groups.armor, integer>

-- -------------------------- ToolCapabilities.item ------------------------- --

--[[
WIPDOC
]]
---@class core.ToolCapabilities.item
--[[
WIPDOC
]]
---@field full_punch_interval number?
--[[
WIPDOC
]]
---@field max_drop_level integer?
--[[
WIPDOC
]]
---@field groupcaps core.ToolCapabilities.item.groupcaps?
--[[
WIPDOC
]]
---@field damage_groups core.ToolCapabilities.damage_groups?

-- -------------------------- ToolCapabilities.tool ------------------------- --

--[[
WIPDOC
]]
---@class core.ToolCapabilities.tool : core.ToolCapabilities.item
--[[
WIPDOC
]]
---@field groupcaps core.ToolCapabilities.item.groupcaps?
--[[
Amount of uses this tool has for attacking players and entities
by punching them (0 = infinite uses).
For compatibility, this is automatically set from the first
suitable groupcap using the formula "uses * 3^(maxlevel - 1)".
It is recommend to set this explicitly instead of relying on the
fallback behavior.
]]
---@field punch_attack_uses integer?

-- ---------------------------- ToolCapabilities ---------------------------- --

--[[
WIPDOC
]]
---@alias core.ToolCapabilities
--- | core.ToolCapabilities.item
--- | core.ToolCapabilities.tool