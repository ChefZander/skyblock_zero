---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Groups > Groups in crafting recipes
-- luanti/doc/lua_api.md: Definition tables > Crafting recipes

--[[
WIPDOC
]]
---@class core.CraftingRecipeDef.cooking.input
--[[
* `type = "cooking"`: Mandatory
]]
---@field type "cooking"
--[[
* `recipe`: An itemname of the single input item
]]
---@field recipe core.Item.namelike
--[[
* `cooktime`: (optional) Time it takes to cook this item, in seconds.
              A floating-point number. (default: 3.0)
Note: Games and mods are free to re-interpret the cooktime in special

]]
---@field cooktime number
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

Mods that utilize cooking recipes (e.g. for adding a furnace node) need to implement
replacements on their own
]]
---@field replacements  [core.Item.namelike, core.Item.name][]?

--[[
### Cooking

A cooking recipe has a single input item, a single output item stack
and a cooking time. It represents cooking/baking/smelting/etc. items in
an oven, furnace, or something similar; the exact meaning is up for games
to decide, if they choose to use cooking at all.

The engine does not implement anything specific to cooking recipes, but
the recipes can be retrieved later using `core.get_craft_result` to
have a consistent interface across different games/mods.
]]
---@class core.CraftingRecipeDef.cooking : core.CraftingRecipeDef.cooking.input, core.CraftingRecipeDef.output