---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Misc.

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group string
---@return integer
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "not_in_creative_inventory"
---@return integer
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "attached_node"
---@return core.Groups.special.attached_node
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "bouncy"
---@return integer
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "connect_to_raillike"
---@return integer
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "dig_immediate"
---@return core.Groups.special.dig_immediate
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "disable_jump"
---@return core.Groups.special.disable_jump
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "disable_descend"
---@return core.Groups.special.disable_descend
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "fall_damage_add_percent"
---@return integer
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "falling_node"
---@return core.Groups.special.falling_node
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "float"
---@return core.Groups.special.float
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "slippery"
---@return integer
function core.get_item_group(name, group) end

--[[
* `core.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
]]
---@nodiscard
---@param name core.Item.name
---@param group "level"
---@return integer
function core.get_item_group(name, group) end

-- NOTE: core.get_node_group don't get any completion. this is intentional

--[[
* `core.get_node_group(name, group)`: returns a rating
    * Deprecated: An alias for the former.
]]
---@deprecated
---@param name core.Item.name
---@param group string
---@return integer
function core.get_node_group(name, group) end