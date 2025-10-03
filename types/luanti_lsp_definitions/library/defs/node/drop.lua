---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Node definition

-- --------------------------- NodeDef.drop.items --------------------------- --

--[[
WIPDOC
]]
---@class core.NodeDef.drop.item
--[[
WIPDOC
]]
---@field rarity integer?
--[[
WIPDOC
]]
---@field items core.Item.name[]?
--[[
WIPDOC
* @deprecated 5.X Use `tool_groups` instead
]]
---@field tools core.Tool.name[]?
--[[
WIPDOC
]]
---@field tool_groups OneOrMany<core.Groups.tool>[]?
--[[
WIPDOC
]]
---@field inherit_color boolean?

-- ------------------------------ NodeDef.drop ------------------------------ --

--[[
WIPDOC
]]
---@class core.NodeDef.drop.tablefmt
--[[
WIPDOC
]]
---@field max_items integer?
--[[
WIPDOC
]]
---@field items core.NodeDef.drop.item?

--[[
WIPDOC
]]
---@alias core.NodeDef.drop
--- | core.NodeDef.drop.tablefmt
--- | core.Item.stringfmt

-- ----------------------------- NodeDef fields ----------------------------- --

---@class core.NodeDef
--[[
WIPDOC
]]
---@field drop core.NodeDef.drop
