---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Groups > Groups in crafting recipes
-- luanti/doc/lua_api.md: Definition tables > Crafting recipes

--[[
WIPDOC
]]
---@class core.CraftingRecipeDef.shaped.input
--[[
* `type = "shaped"`: (optional) specifies recipe type as shaped
]]
---@field type "shaped"?
--[[
* `recipe`: A 2-dimensional matrix of items, with a width *w* and height *h*.
    * *w* and *h* are chosen by you, they don't have to be equal but must be at least 1

    * The inner tables are the rows. There must be *h* tables, specified from the top to the bottom row
    * Values inside of the inner table are the columns.
      Each inner table must contain a list of *w* items, specified from left to right
    * Empty slots *must* be filled with the empty string
]]
---@field recipe core.Item.namelike[][]
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
### Shaped

This is the default recipe type (when no `type` is specified).

A shaped recipe takes one or multiple items as input and has
a single item stack as output. The input items must be specified
in a 2-dimensional matrix (see parameters below) to specify the
exact arrangement (the "shape") in which the player must place them
in the crafting grid.

For example, for a 3x3 recipe, the `recipes` table must have
3 rows and 3 columns.

In order to craft the recipe, the players' crafting grid must
have equal or larger dimensions (both width and height).

Empty slots outside of the recipe's extents are ignored, e.g. a 3x3
recipe where only the bottom right 2x2 slots are filled is the same
as the corresponding 2x2 recipe without the empty slots.\
]]
---@class core.CraftingRecipeDef.shaped : core.CraftingRecipeDef.shaped.input, core.CraftingRecipeDef.output