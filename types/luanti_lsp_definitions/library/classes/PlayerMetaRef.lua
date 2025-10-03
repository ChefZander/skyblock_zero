---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `PlayerMetaRef`

-- NOTE: changes are linked to MetaDataRef, ItemStackMetaRef, NodeMetaRef,
-- PlayerMetaRef and StorageRef

--[[
WIPDOC
]]
---@class core.PlayerMetaRef: core.MetaDataRef
local PlayerMetaRef = {}

--[[
* `contains(key)`: Returns true if key present, otherwise false.
    * Returns `nil` when the MetaData is inexistent.
]]
---@nodiscard
---@param key core.MetadataTable.fields.player.keys
---@return boolean?
function PlayerMetaRef:contains(key) end

--[[
* `get(key)`: Returns `nil` if key not present, else the stored string.
]]
---@nodiscard
---@param key core.MetadataTable.fields.player.keys
---@return string? value
function PlayerMetaRef:get(key) end

--[[
* `set_string(key, value)`: Value of `""` will delete the key.
]]
---@param key core.MetadataTable.fields.player.keys
---@param value string
function PlayerMetaRef:set_string(key, value) end

--[[
* `get_string(key)`: Returns `""` if key not present.
]]
---@nodiscard
---@param key core.MetadataTable.fields.player.keys
---@return string value
function PlayerMetaRef:get_string(key) end

--[[
* `set_int(key, value)`
    * The range for the value is system-dependent (usually 32 bits).
      The value will be converted into a string when stored.
]]
---@param key core.MetadataTable.fields.player.keys.integer
---@param value integer
function PlayerMetaRef:set_int(key, value) end

--[[
* `get_int(key)`: Returns `0` if key not present.
]]
---@nodiscard
---@param key core.MetadataTable.fields.player.keys.integer
---@return integer value
function PlayerMetaRef:get_int(key) end

--[[
* `set_float(key, value)`
    * Store a number (a 64-bit float) exactly.
    * The value will be converted into a string when stored.
]]
---@param key core.MetadataTable.fields.player.keys.number
---@param value number
function PlayerMetaRef:set_float(key, value) end

--[[
WIPDOC
]]
---@nodiscard
---@param key core.MetadataTable.fields.player.keys.number
---@return number value
function PlayerMetaRef:get_float(key) end

--[[
WIPDOC
]]
---@nodiscard
---@return core.MetadataTable.fields.player.keys[] keys
function PlayerMetaRef:get_keys() end

--[[
WIPDOC
]]
---@nodiscard
---@param data core.MetadataTable.player
---@return boolean?
function PlayerMetaRef:from_table(data) end

--[[
WIPDOC
]]
---@nodiscard
---@return core.MetadataTable.player
function PlayerMetaRef:to_table() end
