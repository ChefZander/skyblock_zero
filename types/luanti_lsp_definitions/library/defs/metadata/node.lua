---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Metadata
-- luanti/doc/lua_api.md: Class reference > `MetaDataRef`

-- ------------------- MetadataTable.*.node special fields ------------------ --

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.node.keys.special
--- | "formpsec"
--- | "infotext"

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.node.keys
--- | core.MetadataTable.fields.node.keys.special
--- | string

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.node.keys.integer.special
--- | string

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.node.keys.integer
--- | core.MetadataTable.fields.node.keys.integer.special
--- | string

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.node.keys.number.special
--- | string

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.node.keys.number
--- | core.MetadataTable.fields.node.keys.number.special
--- | string

-- --------------------------- MetadataTable.node --------------------------- --

--[[
WIPDOC
]]
---@class core.MetadataTable.fields.node : {[string]:string?}
--[[
WIPDOC
]]
---@field formspec core.Formspec?
--[[
WIPDOC
]]
---@field infotext string?

--[[
WIPDOC
]]
---@class core.MetadataTable.node.set
--[[
WIPDOC
]]
---@field fields core.MetadataTable.fields.node?
--[[
WIPDOC
]]
---@field inventory core.InventoryTable?

--[[
WIPDOC
]]
---@class core.MetadataTable.node.get
--[[
WIPDOC
]]
---@field fields core.MetadataTable.fields.node?
--[[
WIPDOC
]]
---@field inventory core.InventoryTable.stringfmt?