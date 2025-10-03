---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Detached inventory callbacks

--[[
WIPDOC
]]
---@alias core.DetachedInventoryCallbacks.allow_move fun(inv:core.InvRef, from_list:core.InventoryList, from_index:integer, to_list:core.InventoryList, to_index:integer, count:integer, player:core.PlayerRef):integer?

--[[
WIPDOC
]]
---@alias core.DetachedInventoryCallbacks.allow_put fun(inv:core.InvRef, listname:core.InventoryList, index:integer, stack:core.ItemStack, player:core.PlayerRef):integer?

--[[
WIPDOC
]]
---@alias core.DetachedInventoryCallbacks.allow_take fun(inv:core.InvRef, listname:core.InventoryList, index:integer, stack:core.ItemStack, player:core.PlayerRef):integer?

--[[
WIPDOC
]]
---@alias core.DetachedInventoryCallbacks.on_move fun(inv:core.InvRef, from_list:core.InventoryList, from_index:integer, to_list:core.InventoryList, to_index:integer, count:integer, player:core.PlayerRef)

--[[
WIPDOC
]]
---@alias core.DetachedInventoryCallbacks.on_put fun(inv:core.InvRef, listname:core.InventoryList, index:integer, stack:core.ItemStack, player:core.PlayerRef)

--[[
WIPDOC
]]
---@alias core.DetachedInventoryCallbacks.on_take fun(inv:core.InvRef, listname:core.InventoryList, index:integer, stack:core.ItemStack, player:core.PlayerRef)

--[[
WIPDOC
]]
---@class core.DetachedInventoryCallbacks
--[[
WIPDOC
]]
---@field allow_move core.DetachedInventoryCallbacks.allow_move?
--[[
WIPDOC
]]
---@field allow_put core.DetachedInventoryCallbacks.allow_put?
--[[
WIPDOC
]]
---@field allow_take core.DetachedInventoryCallbacks.allow_take?
--[[
WIPDOC
]]
---@field on_move core.DetachedInventoryCallbacks.on_move?
--[[
WIPDOC
]]
---@field on_put core.DetachedInventoryCallbacks.on_put?
--[[
WIPDOC
]]
---@field on_take core.DetachedInventoryCallbacks.on_take?
