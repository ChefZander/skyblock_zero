---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Inventory
-- luanti/doc/lua_api.md: Class reference > `InvRef`
-- luanti/doc/lua_api.md: Class reference > `MetaDataRef`

-- ------------------------------ InventoryList ----------------------------- --

--[[
WIPDOC
]]
---@alias core.InventoryList
--- | "main"
--- | "craft"
--- | "craftpreview"
--- | "craftresult"
--- | "hand"
--- | string

-- -------------------------------- InventoryTable -------------------------------- --

--[[
WIPDOC
]]
---@alias core.ItemList.stringfmt SparseList<core.Item.stringfmt>

--[[
WIPDOC
]]
---@class core.InventoryTable.stringfmt : {[core.InventoryList]:core.ItemList.stringfmt?}
--[[
WIPDOC
]]
---@field main core.ItemList.stringfmt?
--[[
WIPDOC
]]
---@field craft core.ItemList.stringfmt?
--[[
WIPDOC
]]
---@field craftpreview core.ItemList.stringfmt?
--[[
WIPDOC
]]
---@field craftresult core.ItemList.stringfmt?
--[[
WIPDOC
]]
---@field hand core.ItemList.stringfmt?

--[[
WIPDOC
]]
---@alias core.ItemList SparseList<core.Item>

--[[
* inventory table keys are inventory list names
* inventory table values are item tables
* item table keys are slot IDs (starting with 1)
* item table values are ItemStacks
]]
---@class core.InventoryTable : {[core.InventoryList]:core.ItemList}
--[[
WIPDOC
]]
---@field main core.ItemList?
--[[
WIPDOC
]]
---@field craft core.ItemList?
--[[
WIPDOC
]]
---@field craftpreview core.ItemList?
--[[
WIPDOC
]]
---@field craftresult core.ItemList?
--[[
WIPDOC
]]
---@field hand core.ItemList?