---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Metadata
-- luanti/doc/lua_api.md: Class reference > `MetaDataRef`

-- ------------------- MetadataTable.*.item special fields ------------------ --
--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.item.keys.special
--- | "description"
--- | "short_description"
--- | "inventory_image"
--- | "inventory_overlay"
--- | "wield_image"
--- | "wield_overlay"
--- | "wield_scale"
--- | "color"
--- | "palette_index"
--- | "count_meta"
--- | "count_alignment"
--- | "range"

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.item.keys
--- | core.MetadataTable.fields.item.keys.special
--- | string

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.item.keys.integer.special
--- | "palette_index"
--- | "count_alignment"

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.item.keys.integer
--- | core.MetadataTable.fields.item.keys.integer.special
--- | string

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.item.keys.number.special
--- | "range"

--[[
WIPDOC
]]
---@alias core.MetadataTable.fields.item.keys.number
--- | core.MetadataTable.fields.item.keys.number.special
--- | string

-- --------------------------- MetadataTable.item --------------------------- --

--[[
WIPDOC
]]
---@class core.MetadataTable.fields.item : {[string]:string?}
--[[
WIPDOC
]]
---@field description string?
--[[
WIPDOC
]]
---@field short_description string?
--[[
WIPDOC
]]
---@field inventory_image core.Texture?
--[[
WIPDOC
]]
---@field inventory_overlay core.Texture?
--[[
WIPDOC
]]
---@field wield_image core.Texture?
--[[
WIPDOC
]]
---@field wield_overlay core.Texture?
--[[
WIPDOC
]]
---@field wield_scale core.MetadataTable.vector?
--[[
WIPDOC
]]
---@field color core.ColorString?
--[[
WIPDOC
]]
---@field palette_index integer?
--[[
WIPDOC
]]
---@field count_meta string?
--[[
WIPDOC
]]
---@field count_alignment integer?
--[[
WIPDOC
]]
---@field range number?

--[[
WIPDOC
]]
---@class core.MetadataTable.item
--[[
WIPDOC
]]
---@field fields core.MetadataTable.fields.item?