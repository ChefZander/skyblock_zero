---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Groups > Groups in crafting recipes
-- luanti/doc/lua_api.md: 'core' namespace reference > Registration functions > Gameplay
-- luanti/doc/lua_api.md: Definition tables > Crafting recipes

--[[
WIPDOC
]]
---@class core.CraftingRecipeDef.output
--[[
* `output`: Itemstring of output itemstack (item counts >= 1 are allowed)
]]
---@field output core.Item.stringfmt

--[[
WIPDOC
]]
---@alias core.CraftingRecipeDef.clear
--- | core.CraftingRecipeDef.shaped.input
--- | core.CraftingRecipeDef.shapeless.input
--- | core.CraftingRecipeDef.toolrepair
--- | core.CraftingRecipeDef.cooking.input
--- | core.CraftingRecipeDef.fuel
--- | core.CraftingRecipeDef.output

-- ---------------------------- CraftingRecipeDef --------------------------- --

--[[
Crafting recipes
----------------

Crafting converts one or more inputs to one output itemstack of arbitrary
count (except for fuels, which don't have an output). The conversion reduces
each input ItemStack by 1.

Craft recipes are registered by `core.register_craft` and use a
table format. The accepted parameters are listed below.

Recipe input items can either be specified by item name (item count = 1)
or by group (see "Groups in crafting recipes" for details).
Only the item name (and groups) matter for matching a recipe, i.e. meta and count
are ignored.

If multiple recipes match the input of a craft grid, one of them is chosen by the
following priority rules:

* Shaped recipes are preferred over shapeless recipes, which in turn are preferred
  over tool repair.
* Otherwise, recipes without groups are preferred over recipes with groups.
* Otherwise, earlier registered recipes are preferred.
]]
---@alias core.CraftingRecipeDef
--- | core.CraftingRecipeDef.shaped
--- | core.CraftingRecipeDef.shapeless
--- | core.CraftingRecipeDef.toolrepair
--- | core.CraftingRecipeDef.cooking
--- | core.CraftingRecipeDef.fuel
