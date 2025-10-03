---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Item definition

-- ------------------------- ItemDef.pointabilities ------------------------- --

--[[
WIPDOC
]]
---@alias core.ItemDef.pointabilities.value
--- | boolean
--- | "blocking"

--[[
WIPDOC
]]
---@class core.ItemDef.pointabilities
--[[
WIPDOC
]]
---@field nodes table<core.Node.namelike, core.ItemDef.pointabilities.value>
--[[
WIPDOC
]]
---@field objects table<core.Entity.namelike, core.ItemDef.pointabilities.value>>


-- ----------------------------- ItemDef fields ----------------------------- --

---@class core.ItemDef
--[[
Contains lists to override the `pointable` property of nodes and objects.
The index can be a node/entity name or a group with the prefix `"group:"`.
(For objects `armor_groups` are used and for players the entity name is irrelevant.)
If multiple fields fit, the following priority order is applied:
1. value of matching node/entity name
2. `true` for any group
3. `false` for any group
4. `"blocking"` for any group
5. `liquids_pointable` if it is a liquid node
6. `pointable` property of the node or object
]]
---@field pointabilities core.ItemDef.pointabilities?
