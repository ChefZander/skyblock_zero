---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ItemStackMetaRef`

-- NOTE: changes are linked to MetaDataRef, ItemStackMetaRef, NodeMetaRef,
-- PlayerMetaRef and StorageRef

--[[
WIPDOC
]]
---@class core.ItemStackMetaRef: core.MetaDataRef
local ItemStackMetaRef = {}

--[[
* `contains(key)`: Returns true if key present, otherwise false.
    * Returns `nil` when the MetaData is inexistent.
]]
---@nodiscard
---@param key core.MetadataTable.fields.item.keys
---@return boolean?
function ItemStackMetaRef:contains(key) end

--[[
* `get(key)`: Returns `nil` if key not present, else the stored string.
]]
---@nodiscard
---@param key core.MetadataTable.fields.item.keys
---@return string? value
function ItemStackMetaRef:get(key) end

--[[
* `set_string(key, value)`: Value of `""` will delete the key.
]]
---@param key core.MetadataTable.fields.item.keys
---@param value string
function ItemStackMetaRef:set_string(key, value) end

--[[
* `get_string(key)`: Returns `""` if key not present.
]]
---@nodiscard
---@param key core.MetadataTable.fields.item.keys
---@return string value
function ItemStackMetaRef:get_string(key) end

--[[
* `set_int(key, value)`
    * The range for the value is system-dependent (usually 32 bits).
      The value will be converted into a string when stored.
]]
---@param key core.MetadataTable.fields.item.keys.integer
---@param value integer
function ItemStackMetaRef:set_int(key, value) end

--[[
* `get_int(key)`: Returns `0` if key not present.
]]
---@nodiscard
---@param key core.MetadataTable.fields.item.keys.integer
---@return integer value
function ItemStackMetaRef:get_int(key) end

--[[
* `set_float(key, value)`
    * Store a number (a 64-bit float) exactly.
    * The value will be converted into a string when stored.
]]
---@param key core.MetadataTable.fields.item.keys.number
---@param value number
function ItemStackMetaRef:set_float(key, value) end

--[[
WIPDOC
]]
---@nodiscard
---@param key core.MetadataTable.fields.item.keys.number
---@return number value
function ItemStackMetaRef:get_float(key) end

--[[
WIPDOC
]]
---@nodiscard
---@return core.MetadataTable.fields.item.keys[] keys
function ItemStackMetaRef:get_keys() end

--[[
WIPDOC
]]
---@nodiscard
---@param data core.MetadataTable.item
---@return boolean?
function ItemStackMetaRef:from_table(data) end

--[[
WIPDOC
]]
---@nodiscard
---@return core.MetadataTable.item
function ItemStackMetaRef:to_table() end


--[[
WIPDOC
]]
---@param tool_capabilities core.ToolCapabilities?
function ItemStackMetaRef:set_tool_capabilities(tool_capabilities) end

--[[
WIPDOC
]]
---@param wear_bar_params core.WearBarColor?
function ItemStackMetaRef:set_wear_bar_params(wear_bar_params) end
