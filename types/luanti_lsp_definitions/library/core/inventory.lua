---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Inventory

-- ---------------------------- InventoryLocation --------------------------- --

--[[
WIPDOC
]]
---@class core.InventoryLocation.node
--[[
WIPDOC
]]
---@field type "node"
--[[
WIPDOC
]]
---@field pos ivec

--[[
WIPDOC
]]
---@class core.InventoryLocation.player
--[[
WIPDOC
]]
---@field type "player"
--[[
WIPDOC
]]
---@field name string

--[[
WIPDOC
]]
---@class core.InventoryLocation.detached
--[[
WIPDOC
]]
---@field type "detached"
--[[
WIPDOC
]]
---@field name string

--[[
WIPDOC
]]
---@alias core.InventoryLocation
--- | core.InventoryLocation.node
--- | core.InventoryLocation.player
--- | core.InventoryLocation.detached

--[[
WIPDOC
]]
---@class core.InventoryLocation.undefined
--[[
WIPDOC
]]
---@field type "undefined"

-- ---------------------------- core.* functions ---------------------------- --

--[[
`core.get_inventory(location)`: returns an `InvRef`

* `location` = e.g.
    * `{type="player", name="celeron55"}`
    * `{type="node", pos={x=, y=, z=}}`
    * `{type="detached", name="creative"}`
]]
---@param location core.InventoryLocation
---@return core.InvRef
function core.get_inventory(location) end

--[[
WIPDOC
]]
---@nodiscard
---@param name string
---@param callbacks core.DetachedInventoryCallbacks
---@param player_name string?
---@return core.InvRef
function core.create_detached_inventory(name, callbacks, player_name) end

--[[
WIPDOC
]]
---@nodiscard
---@param name string
---@return boolean
function core.remove_detached_inventory(name) end