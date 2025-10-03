---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Groups > Groups in crafting recipes
-- luanti/doc/lua_api.md: Definition tables > Crafting recipes

--[[
### Tool repair

Syntax:

    {
        type = "toolrepair",
        additional_wear = -0.02, -- multiplier of 65536
    }

Adds a shapeless recipe for *every* tool that doesn't have the `disable_repair=1`
group. If this recipe is used, repairing is possible with any crafting grid
with at least 2 slots.
The player can put 2 equal tools in the craft grid to get one "repaired" tool
back.
The wear of the output is determined by the wear of both tools, plus a
'repair bonus' given by `additional_wear`. To reduce the wear (i.e. 'repair'),
you want `additional_wear` to be negative.

The formula used to calculate the resulting wear is:

    65536 * (1 - ( (1 - tool_1_wear) + (1 - tool_2_wear) + additional_wear))

The result is rounded and can't be lower than 0. If the result is 65536 or higher,
no crafting is possible.
]]
---@class core.CraftingRecipeDef.toolrepair
--[[
* `type = "toolrepair"`: Mandatory
]]
---@field type "toolrepair"
--[[
**AMENDMENT**
* `additional_wear`: multiplier of 65536. When repairing by getting a
  repaired tool from 2 same tools in the craft grid, the resulting wear is a
  combination of the 2 tools and a repair bonus from `additional_wear`. More
  precisely, the pseudocode determining the result is:

```lua
result = 65536 * (1 - ( (1 - tool_1_wear) + (1 - tool_2_wear) + additional_wear ) )
result = max(0, round(result)) -- rounded and can't be lower than 0
if result >= 65536 then
    -- craft made not possible
end
```
]]
---@field additional_wear core.Tool.wear