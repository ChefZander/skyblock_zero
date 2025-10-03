---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Item handling

--[[
WIPDOC
]]
---@class core.CraftRecipe.unknown
--[[
WIPDOC
]]
---@field method "unknown"
--[[
WIPDOC
]]
---@field width 0
--[[
WIPDOC
]]
---@field items nil

--[[
WIPDOC
]]
---@class core.CraftRecipe.normal.set
--[[
WIPDOC
]]
---@field method "normal"
--[[
WIPDOC
]]
---@field width integer?
--[[
WIPDOC
]]
---@field items core.ItemList

--[[
WIPDOC
]]
---@class core.CraftRecipe.normal.get
--[[
WIPDOC
]]
---@field method "normal"
--[[
WIPDOC
]]
---@field width integer
--[[
WIPDOC
]]
---@field items core.ItemList

--[[
WIPDOC
]]
---@class core.CraftRecipe.cooking
--[[
WIPDOC
]]
---@field method "cooking"
--[[
WIPDOC
]]
---@field items core.ItemList

--[[
WIPDOC
]]
---@class core.CraftRecipe.fuel
--[[
WIPDOC
]]
---@field method "fuel"
--[[
WIPDOC
]]
---@field items core.ItemList

--[[
WIPDOC
]]
---@alias core.CraftRecipe.set
--- | core.CraftRecipe.normal.set
--- | core.CraftRecipe.cooking
--- | core.CraftRecipe.fuel

--[[
WIPDOC
]]
---@alias core.CraftRecipe.get
--- | core.CraftRecipe.normal.get
--- | core.CraftRecipe.cooking
--- | core.CraftRecipe.fuel

-- ----------------------- CraftingRecipe.with_output ----------------------- --

---@class _.CraftRecipe.with_output
--[[
WIPDOC
]]
---@field output core.Item.stringfmt

--[[
WIPDOC
]]
---@class core.CraftRecipe.with_output.unknown : core.CraftRecipe.unknown, _.CraftRecipe.with_output

--[[
WIPDOC
]]
---@class core.CraftRecipe.with_output.normal : core.CraftRecipe.normal.get, _.CraftRecipe.with_output

--[[
WIPDOC
]]
---@class core.CraftRecipe.with_output.cooking : core.CraftRecipe.cooking, _.CraftRecipe.with_output

--[[
WIPDOC
]]
---@class core.CraftRecipe.with_output.fuel : core.CraftRecipe.fuel, _.CraftRecipe.with_output

--[[
WIPDOC
]]
---@alias core.CraftRecipe.with_output
--- | core.CraftRecipe.with_output.unknown
--- | core.CraftRecipe.with_output.normal
--- | core.CraftRecipe.with_output.cooking
--- | core.CraftRecipe.with_output.fuel

-- ------------------------------- CraftOutput ------------------------------ --

--[[
WIPDOC
]]
---@class core.CraftOutput.normal
--[[
WIPDOC
]]
---@field item core.ItemStack
--[[
WIPDOC
]]
---@field replacements SparseList<core.ItemStack>

--[[
WIPDOC
]]
---@class core.CraftOutput.cooking
--[[
WIPDOC
]]
---@field item core.ItemStack
--[[
WIPDOC
]]
---@field replacements SparseList<core.ItemStack>
--[[
WIPDOC
]]
---@field time number

--[[
WIPDOC
]]
---@class core.CraftOutput.fuel
--[[
WIPDOC
]]
---@field replacements SparseList<core.ItemStack>
--[[
WIPDOC
]]
---@field time number

--[[
WIPDOC
]]
---@alias core.CraftOutput
--- | core.CraftOutput.normal
--- | core.CraftOutput.cooking
--- | core.CraftOutput.fuel

-- ---------------------------- core.* functions ---------------------------- --

--[[
* `core.get_craft_result(input)`: returns `output, decremented_input`
    * `input.method` = `"normal"` or `"cooking"` or `"fuel"`
    * `input.width` = for example `3`
    * `input.items` = for example
      `{stack1, stack2, stack3, stack4, stack 5, stack 6, stack 7, stack 8, stack 9}`
    * `output.item` = `ItemStack`, if unsuccessful: empty `ItemStack`
    * `output.time` = a number, if unsuccessful: `0`
    * `output.replacements` = List of replacement `ItemStack`s that couldn't be
      placed in `decremented_input.items`. Replacements can be placed in
      `decremented_input` if the stack of the replaced item has a count of 1.
    * `decremented_input` = like `input`
]]
---@nodiscard
---@param input core.CraftRecipe.normal.set
---@return core.CraftOutput.normal, core.CraftRecipe.normal.get
function core.get_craft_result(input) end

--[[
* `core.get_craft_result(input)`: returns `output, decremented_input`
    * `input.method` = `"normal"` or `"cooking"` or `"fuel"`
    * `input.width` = for example `3`
    * `input.items` = for example
      `{stack1, stack2, stack3, stack4, stack 5, stack 6, stack 7, stack 8, stack 9}`
    * `output.item` = `ItemStack`, if unsuccessful: empty `ItemStack`
    * `output.time` = a number, if unsuccessful: `0`
    * `output.replacements` = List of replacement `ItemStack`s that couldn't be
      placed in `decremented_input.items`. Replacements can be placed in
      `decremented_input` if the stack of the replaced item has a count of 1.
    * `decremented_input` = like `input`
]]
---@nodiscard
---@param input core.CraftRecipe.cooking
---@return core.CraftOutput.cooking, core.CraftRecipe.cooking
function core.get_craft_result(input) end

--[[
* `core.get_craft_result(input)`: returns `output, decremented_input`
    * `input.method` = `"normal"` or `"cooking"` or `"fuel"`
    * `input.width` = for example `3`
    * `input.items` = for example
      `{stack1, stack2, stack3, stack4, stack 5, stack 6, stack 7, stack 8, stack 9}`
    * `output.item` = `ItemStack`, if unsuccessful: empty `ItemStack`
    * `output.time` = a number, if unsuccessful: `0`
    * `output.replacements` = List of replacement `ItemStack`s that couldn't be
      placed in `decremented_input.items`. Replacements can be placed in
      `decremented_input` if the stack of the replaced item has a count of 1.
    * `decremented_input` = like `input`
]]
---@nodiscard
---@param input core.CraftRecipe.fuel
---@return core.CraftOutput.fuel, core.CraftRecipe.fuel
function core.get_craft_result(input) end

--[[
* `core.get_craft_recipe(output)`: returns input
    * returns last registered recipe for output item (node)
    * `output` is a node or item type such as `"default:torch"`
    * `input.method` = `"normal"` or `"cooking"` or `"fuel"`
    * `input.width` = for example `3`
    * `input.items` = for example
      `{stack1, stack2, stack3, stack4, stack 5, stack 6, stack 7, stack 8, stack 9}`
        * `input.items` = `nil` if no recipe found
]]
---@nodiscard
---@param output core.Item.name
---@return core.CraftRecipe.get|core.CraftRecipe.unknown
function core.get_craft_recipe(output) end

--[[
* `core.get_all_craft_recipes(query item)`: returns a table or `nil`
    * returns indexed table with all registered recipes for query item (node)
      or `nil` if no recipe was found.
    * recipe entry table:
        * `method`: 'normal' or 'cooking' or 'fuel'
        * `width`: 0-3, 0 means shapeless recipe
        * `items`: indexed [1-9] table with recipe items
        * `output`: string with item name and quantity
    * Example result for `"default:gold_ingot"` with two recipes:
      ```lua
      {
          {
              method = "cooking", width = 3,
              output = "default:gold_ingot", items = {"default:gold_lump"}
          },
          {
              method = "normal", width = 1,
              output = "default:gold_ingot 9", items = {"default:goldblock"}
          }
      }
      ```
]]
---@nodiscard
---@param query_item core.Item.name
---@return core.CraftRecipe.with_output[]
function core.get_all_craft_recipes(query_item) end