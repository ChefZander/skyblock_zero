---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `NodeMetaRef`

-- NOTE: changes are linked to MetaDataRef, ItemStackMetaRef, NodeMetaRef,
-- PlayerMetaRef and StorageRef

--[[
WIPDOC
]]
---@class core.NodeMetaRef : core.MetaDataRef
local NodeMetaRef = {}

--[[
* `contains(key)`: Returns true if key present, otherwise false.
    * Returns `nil` when the MetaData is inexistent.
]]
---@nodiscard
---@param key core.MetadataTable.fields.node.keys
---@return boolean?
function NodeMetaRef:contains(key) end

--[[
* `get(key)`: Returns `nil` if key not present, else the stored string.
]]
---@nodiscard
---@param key core.MetadataTable.fields.node.keys
---@return string? value
function NodeMetaRef:get(key) end

--[[
* `set_string(key, value)`: Value of `""` will delete the key.
]]
---@param key core.MetadataTable.fields.node.keys
---@param value string
function NodeMetaRef:set_string(key, value) end

--[[
* `get_string(key)`: Returns `""` if key not present.
]]
---@nodiscard
---@param key core.MetadataTable.fields.node.keys
---@return string value
function NodeMetaRef:get_string(key) end

--[[
* `set_int(key, value)`
    * The range for the value is system-dependent (usually 32 bits).
      The value will be converted into a string when stored.
]]
---@param key core.MetadataTable.fields.node.keys.integer
---@param value integer
function NodeMetaRef:set_int(key, value) end

--[[
* `get_int(key)`: Returns `0` if key not present.
]]
---@nodiscard
---@param key core.MetadataTable.fields.node.keys.integer
---@return integer value
function NodeMetaRef:get_int(key) end

--[[
* `set_float(key, value)`
    * Store a number (a 64-bit float) exactly.
    * The value will be converted into a string when stored.
]]
---@param key core.MetadataTable.fields.node.keys.number
---@param value number
function NodeMetaRef:set_float(key, value) end

--[[
WIPDOC
]]
---@nodiscard
---@param key core.MetadataTable.fields.node.keys.number
---@return number value
function NodeMetaRef:get_float(key) end

--[[
WIPDOC
]]
---@nodiscard
---@return core.MetadataTable.fields.node.keys[] keys
function NodeMetaRef:get_keys() end

--[[
WIPDOC
]]
---@nodiscard
---@param data core.MetadataTable.node.set
---@return boolean?
function NodeMetaRef:from_table(data) end

--[[
WIPDOC
]]
---@nodiscard
---@return core.MetadataTable.node.get
function NodeMetaRef:to_table() end


--[[
WIPDOC
]]
---@nodiscard
---@return core.InvRef
function NodeMetaRef:get_inventory() end

--[[
* `mark_as_private(name or {name1, name2, ...})`: Mark specific vars as private
  This will prevent them from being sent to the client. Note that the "private"
  status will only be remembered if an associated key-value pair exists,
  meaning it's best to call this when initializing all other meta (e.g.
  `on_construct`).
]]
---@param fields OneOrMany<core.MetadataTable.fields.node.keys>
function NodeMetaRef:mark_as_private(fields) end
