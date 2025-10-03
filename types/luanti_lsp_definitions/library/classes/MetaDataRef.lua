---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `MetaDataRef`

-- NOTE: changes are linked to MetaDataRef, ItemStackMetaRef, NodeMetaRef,
-- PlayerMetaRef and StorageRef

--[[
will return the value associated with key `k`. There is a low recursion limit.
]]
---@class core.MetaDataRef
local MetaDataRef = {}

--[[
* `contains(key)`: Returns true if key present, otherwise false.
    * Returns `nil` when the MetaData is inexistent.
]]
---@nodiscard
---@param key core.MetadataTable.fields.keys
---@return boolean?
function MetaDataRef:contains(key) end

--[[
* `get(key)`: Returns `nil` if key not present, else the stored string.
]]
---@nodiscard
---@param key core.MetadataTable.fields.keys
---@return string? value
function MetaDataRef:get(key) end

--[[
* `set_string(key, value)`: Value of `""` will delete the key.
]]
---@param key core.MetadataTable.fields.keys
---@param value string
function MetaDataRef:set_string(key, value) end

--[[
* `get_string(key)`: Returns `""` if key not present.
]]
---@nodiscard
---@param key core.MetadataTable.fields.keys
---@return string value
function MetaDataRef:get_string(key) end

--[[
* `set_int(key, value)`
    * The range for the value is system-dependent (usually 32 bits).
      The value will be converted into a string when stored.
]]
---@param key core.MetadataTable.fields.keys.integer
---@param value integer
function MetaDataRef:set_int(key, value) end

--[[
* `get_int(key)`: Returns `0` if key not present.
]]
---@nodiscard
---@param key core.MetadataTable.fields.keys.integer
---@return integer value
function MetaDataRef:get_int(key) end

--[[
* `set_float(key, value)`
    * Store a number (a 64-bit float) exactly.
    * The value will be converted into a string when stored.
]]
---@param key core.MetadataTable.fields.keys.number
---@param value number
function MetaDataRef:set_float(key, value) end

--[[
WIPDOC
]]
---@nodiscard
---@param key core.MetadataTable.fields.keys.number
---@return number value
function MetaDataRef:get_float(key) end

--[[
WIPDOC
]]
---@nodiscard
---@return core.MetadataTable.fields.keys[] keys
function MetaDataRef:get_keys() end

--[[
WIPDOC
]]
---@nodiscard
---@param data core.MetadataTable.set
---@return boolean?
function MetaDataRef:from_table(data) end

--[[
WIPDOC
]]
---@nodiscard
---@return core.MetadataTable.get
function MetaDataRef:to_table() end
