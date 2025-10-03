---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Storage API
-- luanti/doc/lua_api.md: Class reference > `StorageRef`

-- NOTE: changes are linked to MetaDataRef, ItemStackMetaRef, NodeMetaRef,
-- PlayerMetaRef and StorageRef

-- ------------------------------- constructor ------------------------------ --

--[[
* `core.get_mod_storage()`:
    * returns reference to mod private `StorageRef`
    * must be called during mod load time
]]
---@nodiscard
---@return core.StorageRef
function core.get_mod_storage() end

-- ------------------------------- StorageRef ------------------------------- --

--[[
`StorageRef`
------------

Mod metadata: per mod and world metadata, saved automatically.
Can be obtained via `core.get_mod_storage()` during load time.

WARNING: This storage backend is incapable of saving raw binary data due
to restrictions of JSON.

### Methods

* All methods in MetaDataRef

]]
---@class core.StorageRef : core.MetaDataRef
local StorageRef = {}

--[[
* `contains(key)`: Returns true if key present, otherwise false.
    * Returns `nil` when the MetaData is inexistent.
]]
---@nodiscard
---@param key core.MetadataTable.fields.storage.keys
---@return boolean?
function StorageRef:contains(key) end

--[[
* `get(key)`: Returns `nil` if key not present, else the stored string.
]]
---@nodiscard
---@param key core.MetadataTable.fields.storage.keys
---@return string? value
function StorageRef:get(key) end

--[[
* `set_string(key, value)`: Value of `""` will delete the key.
]]
---@nodiscard
---@param key core.MetadataTable.fields.storage.keys
---@param value string
function StorageRef:set_string(key, value) end

--[[
* `get_string(key)`: Returns `""` if key not present.
]]
---@nodiscard
---@param key core.MetadataTable.fields.storage.keys
---@return string value
function StorageRef:get_string(key) end

--[[
* `set_int(key, value)`
    * The range for the value is system-dependent (usually 32 bits).
      The value will be converted into a string when stored.
]]
---@param key core.MetadataTable.fields.storage.keys.integer
---@param value integer
function StorageRef:set_int(key, value) end

--[[
* `get_int(key)`: Returns `0` if key not present.
]]
---@nodiscard
---@param key core.MetadataTable.fields.storage.keys.integer
---@return integer value
function StorageRef:get_int(key) end

--[[
* `set_float(key, value)`
    * Store a number (a 64-bit float) exactly.
    * The value will be converted into a string when stored.
]]
---@param key core.MetadataTable.fields.storage.keys.number
---@param value number
function StorageRef:set_float(key, value) end

--[[
WIPDOC
]]
---@nodiscard
---@param key core.MetadataTable.fields.storage.keys.number
---@return number value
function StorageRef:get_float(key) end

--[[
WIPDOC
]]
---@return core.MetadataTable.fields.storage.keys[] keys
function StorageRef:get_keys() end

--[[
WIPDOC
]]
---@nodiscard
---@param data core.MetadataTable.storage
---@return boolean?
function StorageRef:from_table(data) end

--[[
WIPDOC
]]
---@nodiscard
---@return core.MetadataTable.storage
function StorageRef:to_table() end
