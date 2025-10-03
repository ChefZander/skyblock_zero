---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Defaults for the `on_place` and `on_drop` item definition functions
-- luanti/doc/lua_api.md: 'core' namespace reference > Defaults for the `on_punch` and `on_dig` node definition callbacks

--[[
* `core.item_place_node(itemstack, placer, pointed_thing[, param2, prevent_after_place])`
    * Place item as a node
    * `param2` overrides `facedir` and wallmounted `param2`
    * `prevent_after_place`: if set to `true`, `after_place_node` is not called
      for the newly placed node to prevent a callback and placement loop
    * returns `itemstack, position`
      * `position`: the location the node was placed to. `nil` if nothing was placed.
]]
---@nodiscard
---@param itemstack core.ItemStack
---@param placer core.ObjectRef
---@param pointed_thing core.PointedThing
---@param param2 core.Param2?
---@param prevent_after_place boolean?
---@return core.ItemStack, ivec?
function core.item_place_node(itemstack, placer, pointed_thing, param2, prevent_after_place) end

--[[
* `core.item_place_object(itemstack, placer, pointed_thing)`
    * Place item as-is
    * returns the leftover itemstack
    * **Note**: This function is deprecated and will never be called.
]]
---@deprecated
---@nodiscard
---@param itemstack core.ItemStack
---@param placer core.ObjectRef
---@param pointed_thing core.PointedThing
---@return core.ItemStack
function core.item_place_object(itemstack, placer, pointed_thing) end

--[[
* `core.item_place(itemstack, placer, pointed_thing[, param2])`
    * Wrapper that calls `core.item_place_node` if appropriate
    * Calls `on_rightclick` of `pointed_thing.under` if defined instead
    * **Note**: is not called when wielded item overrides `on_place`
    * `param2` overrides facedir and wallmounted `param2`
    * returns `itemstack, position`
      * `position`: the location the node was placed to. `nil` if nothing was placed.
]]
---@nodiscard
---@param itemstack core.ItemStack
---@param placer core.ObjectRef
---@param pointed_thing core.PointedThing
---@param param2 core.Param2?
---@return core.ItemStack, vec?
function core.item_place(itemstack, placer, pointed_thing, param2) end

--[[
* `core.item_pickup(itemstack, picker, pointed_thing, time_from_last_punch, ...)`
    * Runs callbacks registered by `core.register_on_item_pickup` and adds
      the item to the picker's `"main"` inventory list.
    * Parameters and return value are the same as `on_pickup`.
    * **Note**: is not called when wielded item overrides `on_pickup`
]]
---@nodiscard
---@param itemstack core.ItemStack
---@param picker core.ObjectRef
---@param pointed_thing core.PointedThing
---@param time_from_last_punch number
---@param tool_capabilities core.ToolCapabilities?
---@param dir vector
---@param damage integer?
---@return core.ItemStack
function core.item_pickup(itemstack, picker, pointed_thing, time_from_last_punch, tool_capabilities, dir, damage) end

--[[
* `core.item_secondary_use(itemstack, user)`
    * Global secondary use callback. Does nothing.
    * Parameters and return value are the same as `on_secondary_use`.
    * **Note**: is not called when wielded item overrides `on_secondary_use`
]]
---@nodiscard
---@param itemstack core.ItemStack
---@param user core.ObjectRef?
---@return core.ItemStack?
function core.item_secondary_use(itemstack, user) end

--[[
* `core.item_drop(itemstack, dropper, pos)`
    * Converts `itemstack` to an in-world Lua entity.
    * `itemstack` (`ItemStack`) is modified (cleared) on success.
      * In versions < 5.12.0, `itemstack` was cleared in all cases.
    * `dropper` (`ObjectRef`) is optional.
    * Returned values on success:
      1. leftover itemstack
      2. `ObjectRef` of the spawned object (provided since 5.12.0)
]]
---@nodiscard
---@param itemstack core.ItemStack
---@param dropper core.ObjectRef?
---@param pos vector
---@return core.ItemStack, core.ObjectRef
function core.item_drop(itemstack, dropper, pos) end

--[[
* `core.item_drop(itemstack, dropper, pos)`
    * Converts `itemstack` to an in-world Lua entity.
    * `itemstack` (`ItemStack`) is modified (cleared) on success.
      * In versions < 5.12.0, `itemstack` was cleared in all cases.
    * `dropper` (`ObjectRef`) is optional.
    * Returned values on success:
      1. leftover itemstack
      2. `ObjectRef` of the spawned object (provided since 5.12.0)
]]
---@nodiscard
---@param itemstack core.ItemStack
---@param dropper core.ObjectRef?
---@param pos vector
---@return nil
function core.item_drop(itemstack, dropper, pos) end

--[[
WIPDOC
]]
---@alias core.fn.item_eat fun(itemstack:core.ItemStack, user:core.ObjectRef, pointed_thing:core.PointedThing):core.ItemStack?

--[[
* `core.item_eat(hp_change[, replace_with_item])`
    * Returns `function(itemstack, user, pointed_thing)` as a
      function wrapper for `core.do_item_eat`.
    * `replace_with_item` is the itemstring which is added to the inventory.
      If the player is eating a stack and `replace_with_item` doesn't fit onto
      the eaten stack, then the remaining go to a different spot, or are dropped.
]]
---@nodiscard
---@param hp_change integer
---@param replace_with_item core.Item.stringfmt?
---@return core.fn.item_eat
function core.item_eat(hp_change, replace_with_item) end

--[[
* `core.node_punch(pos, node, puncher, pointed_thing)`
    * Calls functions registered by `core.register_on_punchnode()`
]]
---@param pos ivector
---@param node core.Node.set
---@param puncher core.ObjectRef
---@param pointed_thing core.PointedThing
function core.node_punch(pos, node, puncher, pointed_thing) end

--[[
* `core.node_dig(pos, node, digger)`
    * Checks if node can be dug, puts item into inventory, removes node
    * Calls functions registered by `core.register_on_dignodes()`
]]
---@param pos ivector
---@param node core.Node.set
---@param digger core.ObjectRef
function core.node_dig(pos, node, digger) end