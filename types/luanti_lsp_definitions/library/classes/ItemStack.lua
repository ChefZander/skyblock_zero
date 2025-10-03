---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ItemStack`

-- ------------------------------- constructor ------------------------------ --

--[[
WIPDOC
]]
---@nodiscard
---@param any core.Item?
---@return core.ItemStack
function ItemStack(any) end

-- -------------------------------- ItemStack ------------------------------- --

--[[
WIPDOC
]]
---@class core.ItemStack
local ItemStack = {}

--[[
* `is_empty()`: returns `true` if stack is empty.
]]
---@nodiscard
---@return boolean
function ItemStack:is_empty() end

--[[
* `get_name()`: returns item name (e.g. `"default:stone"`).
]]
---@nodiscard
---@return core.Item.name item_name
function ItemStack:get_name() end

--[[
* `set_name(item_name)`: returns a boolean indicating whether the item was
  cleared.
]]
---@nodiscard
---@param item_name core.Item.name
---@return boolean
function ItemStack:set_name(item_name) end

--[[
* `get_count()`: Returns number of items on the stack.
]]
---@nodiscard
---@return integer count
function ItemStack:get_count() end

--[[
* `set_count(count)`: returns a boolean indicating whether the item was cleared
    * `count`: number, unsigned 16 bit integer
]]
---@nodiscard
---@param count integer
---@return boolean
function ItemStack:set_count(count) end

--[[
* `get_wear()`: returns tool wear (`0`-`65535`), `0` for non-tools.
]]
---@nodiscard
---@return core.Tool.wear wear
function ItemStack:get_wear() end

--[[
* `set_wear(wear)`: returns boolean indicating whether item was cleared
    * `wear`: number, unsigned 16 bit integer
]]
---@nodiscard
---@param wear core.Tool.wear
---@return boolean
function ItemStack:set_wear(wear) end

--[[
`get_meta()`: returns ItemStackMetaRef. See section for more details
]]
---@nodiscard
---@return core.ItemStackMetaRef
function ItemStack:get_meta() end

--[[
* `get_metadata()`: **Deprecated.** Returns metadata (a string attached to an item stack).
    * If you need to access this to maintain backwards compatibility,
      use `stack:get_meta():get_string("")` instead.
]]
---@deprecated
---@nodiscard
---@return string metadata
function ItemStack:get_metadata() end

--[[
* `set_metadata(metadata)`: **Deprecated.** Returns true.
    * If you need to set this to maintain backwards compatibility,
      use `stack:get_meta():set_string("", metadata)` instead.
]]
---@deprecated
---@param metadata string
---@return true
function ItemStack:set_metadata(metadata) end

--[[
* `get_description()`: returns the description shown in inventory list tooltips.
    * The engine uses this when showing item descriptions in tooltips.
    * Fields for finding the description, in order:
        * `description` in item metadata (See [Item Metadata].
        * `description` in item definition
        * item name
]]
---@nodiscard
---@return string
function ItemStack:get_description() end

--[[
* `get_short_description()`: returns the short description or nil.
    * Unlike the description, this does not include new lines.
    * Fields for finding the short description, in order:
        * `short_description` in item metadata (See [Item Metadata].
        * `short_description` in item definition
        * first line of the description (From item meta or def, see `get_description()`.
        * Returns nil if none of the above are set
]]
---@nodiscard
---@return string?
function ItemStack:get_short_description() end

--[[
* `clear()`: removes all items from the stack, making it empty.
]]
function ItemStack:clear() end

--[[
* `replace(item)`: replace the contents of this stack.
    * `item` can also be an itemstring or table.
]]
---@param item core.Item
function ItemStack:replace(item) end

--[[
* `to_string()`: returns the stack in itemstring form.
]]
---@nodiscard
---@return core.Item.stringfmt
function ItemStack:to_string() end

--[[
* `to_table()`: returns the stack in Lua table form.
]]
---@nodiscard
---@return core.Item.tablefmt
function ItemStack:to_table() end

--[[
* `get_stack_max()`: returns the maximum size of the stack (depends on the
  item).
]]
---@nodiscard
---@return integer
function ItemStack:get_stack_max() end

--[[
* `get_free_space()`: returns `get_stack_max() - get_count()`.
]]
---@nodiscard
---@return integer
function ItemStack:get_free_space() end

--[[
* `is_known()`: returns `true` if the item name refers to a defined item type.
]]
---@nodiscard
---@return boolean
function ItemStack:is_known() end

--[[
* `get_definition()`: returns the item definition table.
]]
---@nodiscard
---@return core.ItemDef
function ItemStack:get_definition() end

--[[
* `get_tool_capabilities()`: returns the digging properties of the item,
  or those of the hand if none are defined for this item type
]]
---@nodiscard
---@return core.ToolCapabilities
function ItemStack:get_tool_capabilities() end

--[[
* `add_wear(amount)`
    * Increases wear by `amount` if the item is a tool, otherwise does nothing
    * Valid `amount` range is [0,65536]
    * `amount`: number, integer
]]
---@param amount core.Tool.wear
function ItemStack:add_wear(amount) end

--[[
* `add_wear_by_uses(max_uses)`
    * Increases wear in such a way that, if only this function itself called,
      the item breaks after `max_uses` times
    * Valid `max_uses` range is [0,65536]
    * Does nothing if item is not a tool or if `max_uses` is 0
]]
---@param max_uses core.Tool.wear
function ItemStack:add_wear_by_uses(max_uses) end

--[[
* `get_wear_bar_params()`: returns the wear bar parameters of the item,
  or nil if none are defined for this item type or in the stack's meta
]]
---@nodiscard
---@return core.WearBarColor?
function ItemStack:get_wear_bar_params() end

--[[
* `add_item(item)`: returns leftover `ItemStack`
    * Put some item or stack onto this stack
]]
---@param item core.Item
function ItemStack:add_item(item) end

--[[
* `item_fits(item)`: returns `true` if item or stack can be fully added to
  this one.
]]
---@nodiscard
---@param item core.Item
---@return boolean
function ItemStack:item_fits(item) end

--[[
* `take_item(n)`: returns taken `ItemStack`
    * Take (and remove) up to `n` items from this stack
    * `n`: number, default: `1`
]]
---@nodiscard
---@param n integer?
---@return core.ItemStack
function ItemStack:take_item(n) end

--[[
* `peek_item(n)`: returns taken `ItemStack`
    * Copy (don't remove) up to `n` items from this stack
    * `n`: number, default: `1`
]]
---@nodiscard
---@param n integer?
---@return core.ItemStack
function ItemStack:peek_item(n) end

--[[
* `equals(other)`:
    * returns `true` if this stack is identical to `other`.
    * Note: `stack1:to_string() == stack2:to_string()` is not reliable,
      as stack metadata can be serialized in arbitrary order.
    * Note: if `other` is an itemstring or table representation of an
      ItemStack, this will always return false, even if it is
      "equivalent".
]]
---@nodiscard
---@param other core.ItemStack
---@return boolean
function ItemStack:equals(other) end
