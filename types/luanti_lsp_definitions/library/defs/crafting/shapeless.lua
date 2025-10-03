---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Groups > Groups in crafting recipes
-- luanti/doc/lua_api.md: Definition tables > Crafting recipes

--[[
WIPDOC
]]
---@class core.CraftingRecipeDef.shapeless.input
--[[
* `type = "shapeless"`: Mandatory
]]
---@field type "shapeless"
--[[
* `recipe`: List of item names
]]
---@field recipe core.Item.namelike[]
--[[
* `replacements`: (optional) Allows you to replace input items with some other items
      when something is crafted
    * Provided as a list of item pairs of the form `{ old_item, new_item }` where
      `old_item` is the input item to replace (same syntax as for a regular input
      slot; groups are allowed) and `new_item` is an itemstring for the item stack
      it will become
    * When the output is crafted, Luanti iterates through the list
      of input items if the crafting grid. For each input item stack, it checks if
      it matches with an `old_item` in the item pair list.
        * If it matches, the item will be replaced. Also, this item pair
          will *not* be applied again for the remaining items
        * If it does not match, the item is consumed (reduced by 1) normally
    * The `new_item` will appear in one of 3 places:
        * Crafting grid, if the input stack size was exactly 1
        * Player inventory, if input stack size was larger
        * Drops as item entity, if it fits neither in craft grid or inventory
]]
---@field replacements [core.Item.namelike, core.Item.name][]?

--[[
### Shapeless

Takes a list of input items (at least 1). The order or arrangement
of input items does not matter.

In order to craft the recipe, the players' crafting grid must have matching or
larger *count* of slots. The grid dimensions do not matter.
]]
---@class core.CraftingRecipeDef.shapeless : core.CraftingRecipeDef.shapeless.input, core.CraftingRecipeDef.output