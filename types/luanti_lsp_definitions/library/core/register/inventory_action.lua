---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Global callback registration functions

-- ------------------------------ InventoryInfo ----------------------------- --

--[[
WIPDOC
]]
---@class core.InventoryInfo.move
--[[
WIPDOC
]]
---@field from_list core.InventoryList
--[[
WIPDOC
]]
---@field to_list core.InventoryList
--[[
WIPDOC
]]
---@field from_index integer
--[[
WIPDOC
]]
---@field to_index integer
--[[
WIPDOC
]]
---@field count integer


--[[
WIPDOC
]]
---@class core.InventoryInfo.put_or_take
--[[
WIPDOC
]]
---@field listname core.InventoryList
--[[
WIPDOC
]]
---@field index integer
--[[
WIPDOC
]]
---@field stack core.ItemStack

-- ---------------------------- core.* functions ---------------------------- --

--[[
WIPDOC
]]
---@alias core.fn.allow_player_inventory_action.move fun(player:core.PlayerRef, action:"move", inventory:core.InvRef, inventory_info:core.InventoryInfo.move):integer

--[[
WIPDOC
]]
---@alias core.fn.allow_player_inventory_action.put fun(player:core.PlayerRef, action:"put", inventory:core.InvRef, inventory_info:core.InventoryInfo.put_or_take):integer

--[[
WIPDOC
]]
---@alias core.fn.allow_player_inventory_action.take fun(player:core.PlayerRef, action:"take", inventory:core.InvRef, inventory_info:core.InventoryInfo.put_or_take):integer

--[[
WIPDOC
]]
---@alias core.fn.allow_player_inventory_action
--- | core.fn.allow_player_inventory_action.move
--- | core.fn.allow_player_inventory_action.put
--- | core.fn.allow_player_inventory_action.take

--[[
* `core.register_allow_player_inventory_action(function(player, action, inventory, inventory_info))`
    * Determines how much of a stack may be taken, put or moved to a
      player inventory.
    * Function arguments: see `core.register_on_player_inventory_action`
    * Return a numeric value to limit the amount of items to be taken, put or
      moved. A value of `-1` for `take` will make the source stack infinite.
]]
---@param f core.fn.allow_player_inventory_action
function core.register_allow_player_inventory_action(f) end

--[[
WIPDOC
]]
---@alias core.fn.on_player_inventory_action.move fun(player:core.PlayerRef, action:"move", inventory:core.InvRef, inventory_info:core.InventoryInfo.move)

--[[
WIPDOC
]]
---@alias core.fn.on_player_inventory_action.put fun(player:core.PlayerRef, action:"put", inventory:core.InvRef, inventory_info:core.InventoryInfo.put_or_take)

--[[
WIPDOC
]]
---@alias core.fn.on_player_inventory_action.take fun(player:core.PlayerRef, action:"take", inventory:core.InvRef, inventory_info:core.InventoryInfo.put_or_take)

--[[
WIPDOC
]]
---@alias core.fn.on_player_inventory_action
--- | core.fn.on_player_inventory_action.move
--- | core.fn.on_player_inventory_action.put
--- | core.fn.on_player_inventory_action.take


--[[
WIPDOC
]]
---@param f core.fn.on_player_inventory_action
function core.register_on_player_inventory_action(f) end