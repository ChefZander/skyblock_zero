---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Groups > Groups in crafting recipes
-- luanti/doc/lua_api.md: Definition tables > Crafting recipes

--[[
### Fuel

A fuel recipe is an item associated with a "burning time" and an optional
item replacement. There is no output. This is usually used as fuel for
furnaces, ovens, stoves, etc.

Like with cooking recipes, the engine does not do anything specific with
fuel recipes and it's up to games and mods to use them by retrieving
them via `core.get_craft_result`.
]]
---@class core.CraftingRecipeDef.fuel
--[[
* `type = "fuel"`: Mandatory
]]
---@field type "fuel"
--[[
* `recipe`: Itemname of the item to be used as fuel
]]
---@field recipe core.Item.namelike
--[[
* `burntime`: (optional) Burning time this item provides, in seconds.
              A floating-point number. (default: 1.0)
Note: Games and mods are free to re-interpret the burntime in special
cases, e.g. for an efficient furnace in which fuels burn twice as
long.
]]
---@field burntime number
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

Mods that utilize fuels need to implement replacements on their own
]]
---@field replacements  [core.Item.namelike, core.Item.name][]?