---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: L-system trees

--[[
## Key for special L-System symbols

* `G`: move forward one unit with the pen up
* `F`: move forward one unit with the pen down drawing trunks and branches
* `f`: move forward one unit with the pen down drawing leaves (100% chance)
* `T`: move forward one unit with the pen down drawing trunks only
* `R`: move forward one unit with the pen down placing fruit
* `A`: replace with rules set A
* `B`: replace with rules set B
* `C`: replace with rules set C
* `D`: replace with rules set D
* `a`: replace with rules set A, chance 90%
* `b`: replace with rules set B, chance 80%
* `c`: replace with rules set C, chance 70%
* `d`: replace with rules set D, chance 60%
* `+`: yaw the turtle right by `angle` parameter
* `-`: yaw the turtle left by `angle` parameter
* `&`: pitch the turtle down by `angle` parameter
* `^`: pitch the turtle up by `angle` parameter
* `/`: roll the turtle to the right by `angle` parameter
* `*`: roll the turtle to the left by `angle` parameter
* `[`: save in stack current state info
* `]`: recover from stack state info

[L-System Trees on docs.luanti.org](https://docs.luanti.org/for-creators/l-system-trees/)
]]
---@alias core.LsystemTreeDef.rules string

--[[
WIPDOC
]]
---@alias core.LSystemTreeDef.trunk_type
--- | "single"
--- | "double"
--- | "crossed"

--[[
**LIBDEF REVISION**

L-system trees in Luanti are procedurally generated trees defined by a set of
rules rather than fixed shapes. They use an axiom (starting string) and
recursive replacement rules based on L-systems. One way to interpret is to
compare it to turtle graphics. This allows complex, natural-looking trees with
branching, leaves, and fruit to be created from relatively small definitions.

[L-System Trees on docs.luanti.org](https://docs.luanti.org/for-creators/l-system-trees/)
]]
---@class core.LSystemTreeDef
--[[
Initial tree axiom
]]
---@field axiom core.LsystemTreeDef.rules
--[[
Rules set A
]]
---@field rules_a core.LsystemTreeDef.rules?
--[[
Rules set B
]]
---@field rules_b core.LsystemTreeDef.rules?
--[[
Rules set C
]]
---@field rules_c core.LsystemTreeDef.rules?
--[[
Rules set D
]]
---@field rules_d core.LsystemTreeDef.rules?
--[[
Trunk node name (default: `"ignore"`)
]]
---@field trunk core.Node.name?
--[[
Leaves node name (default: `"ignore"`)
]]
---@field leaves core.Node.name?
--[[
Secondary leaves node name (default: `"ignore"`)
]]
---@field leaves2 core.Node.name?
--[[
Chance (0-100) to replace leaves with leaves2 (default: 0)
]]
---@field leaves2_chance integer?
--[[
Angle in deg (default: 0)
]]
---@field angle integer?
--[[
Max # of iterations, usually 2 -5 (default 0)
]]
---@field iterations integer?
--[[
Factor to lower number of iterations, usually 0 - 3 (default: 0)
]]
---@field random_level integer?
--[[
**LIBDEF REVISION**

Type of trunk:
- `"single"` (default): 1 node
- `"double"`: 2x2 nodes
- `"crossed"`: 3x3 in cross shape
]]
---@field trunk_type core.LSystemTreeDef.trunk_type?
--[[
Whether to use thin (1 node) branches (default: `false`)
]]
---@field thin_branches boolean?
--[[
Fruit node name. (default: `"air"`)
]]
---@field fruit core.Node.name?
--[[
Chance (0-100) to replace leaves with fruit node (default: 0)
]]
---@field fruit_chance integer?
--[[
Random seed, if no seed is provided, the engine will create one.
]]
---@field seed integer