---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Metadata
-- luanti/doc/lua_api.md: Class reference > `MetaDataRef`

-- ----------------- MetadataTable.*.storage special fields ----------------- --

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.storage.keys.special
--- | string

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.storage.keys
--- | core.MetadataTable.fields.storage.keys.special
--- | string

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.storage.keys.integer.special
--- | string

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.storage.keys.integer
--- | core.MetadataTable.fields.storage.keys.integer.special
--- | string

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.storage.keys.number.special
--- | string

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.storage.keys.number
--- | core.MetadataTable.fields.storage.keys.number.special
--- | string

-- -------------------------- MetadataTable.storage ------------------------- --

--[[
WIPDOC
]]
---@class core.MetadataTable.fields.storage : {[string]:string?}

--[[
WIPDOC
]]
---@class core.MetadataTable.storage
--[[
WIPDOC
]]
---@field fields core.MetadataTable.fields.storage?