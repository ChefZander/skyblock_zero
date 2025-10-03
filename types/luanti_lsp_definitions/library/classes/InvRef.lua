---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `InvRef`

--[[
WIPDOC
]]
---@class core.InvRef
local InvRef = {}

--[[
* `is_empty(listname)`: return `true` if list is empty
]]
---@nodiscard
---@param listname core.InventoryList
---@return  boolean
function InvRef:is_empty(listname) end

--[[
* `get_size(listname)`: get size of a list
]]
---@nodiscard
---@param listname core.InventoryList
---@return integer size
function InvRef:get_size(listname) end

--[[
* `set_size(listname, size)`: set size of a list
    * If `listname` is not known, a new list will be created
    * Setting `size` to 0 deletes a list
    * returns `false` on error (e.g. invalid `listname` or `size`
]]
---@nodiscard
---@param listname core.InventoryList
---@param size integer
---@return boolean
function InvRef:set_size(listname, size) end

--[[
* `get_width(listname)`: get width of a list
]]
---@nodiscard
---@param listname core.InventoryList
---@return integer width
function InvRef:get_width(listname) end

--[[
* `set_width(listname, width)`: set width of list; currently used for crafting
    * returns `false` on error (e.g. invalid `listname` or `width`
]]
---@nodiscard
---@param listname core.InventoryList
---@param width integer
function InvRef:set_width(listname, width) end

--[[
* `get_stack(listname, i)`: get a copy of stack index `i` in list
]]
---@nodiscard
---@param listname core.InventoryList
---@param i integer
---@return core.ItemStack stack
function InvRef:get_stack(listname, i) end

--[[
* `set_stack(listname, i, stack)`: copy `stack` to index `i` in list
]]
---@param listname core.InventoryList
---@param i integer
---@param stack core.ItemStack
function InvRef:set_stack(listname, i, stack) end

--[[
* `get_list(listname)`: returns full list (list of `ItemStack`s
                        or `nil` if list doesn't exist (size 0
]]
---@nodiscard
---@param listname core.InventoryList
---@return core.ItemList list
function InvRef:get_list(listname) end

--[[
* `set_list(listname, list)`: set full list (size will not change
]]
---@param listname core.InventoryList
---@param list core.ItemList
function InvRef:set_list(listname, list) end

--[[
* `get_lists()`: returns table that maps listnames to inventory lists
]]
---@nodiscard
---@return core.InventoryTable lists
function InvRef:get_lists() end

--[[
* `set_lists(lists)`: sets inventory lists (size will not change
]]
---@param lists core.InventoryTable
function InvRef:set_lists(lists) end

--[[
* `add_item(listname, stack)`: add item somewhere in list, returns leftover
  `ItemStack`.
]]
---@param listname core.InventoryList
---@param stack core.Item
function InvRef:add_item(listname, stack) end

--[[
* `room_for_item(listname, stack):` returns `true` if the stack of items
  can be fully added to the list
]]
---@nodiscard
---@param listname core.InventoryList
---@param stack core.Item
---@return boolean
function InvRef:room_for_item(listname, stack) end

--[[
* `contains_item(listname, stack, [match_meta])`: returns `true` if
  the stack of items can be fully taken from the list.
    * If `match_meta` is `true`, item metadata is also considered when comparing
      items. Otherwise, only the items names are compared. Default: `false`
    * The method ignores wear.
]]
---@nodiscard
---@param listname core.InventoryList
---@param stack core.Item
---@param match_meta boolean?
---@return boolean
function InvRef:contains_item(listname, stack, match_meta) end

--[[
* `remove_item(listname, stack, [match_meta])`: take as many items as specified from the
  list, returns the items that were actually removed (as an `ItemStack`).
    * If `match_meta` is `true` (available since feature `remove_item_match_meta`),
      item metadata is also considered when comparing items. Otherwise, only the
      items names are compared. Default: `false`
    * The method ignores wear.
]]
---@nodiscard
---@param listname core.InventoryList
---@param stack core.Item
---@param match_meta boolean?
---@return core.ItemStack
function InvRef:remove_item(listname, stack, match_meta) end

--[[
* `get_location()`: returns a location compatible to
  `core.get_inventory(location)`.
    * returns `{type="undefined"}` in case location is not known
]]
---@nodiscard
---@return core.InventoryLocation|core.InventoryLocation.undefined
function InvRef:get_location() end
