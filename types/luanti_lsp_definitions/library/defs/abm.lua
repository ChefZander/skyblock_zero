---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > ABM (ActiveBlockModifier) definition

--[[
WIPDOC
]]
---@alias core.ABMDef.action fun(pos:ivec, node:core.Node.get, active_object_count:integer, active_object_count_wider:integer)

--[[
ABM (ActiveBlockModifier) definition
------------------------------------

Used by `core.register_abm`.

An active block modifier (ABM) is used to define a function that is continuously
and randomly called for specific nodes (defined by `nodenames` and other conditions)
in active mapblocks.
]]
---@class core.ABMDef
--[[
Descriptive label for profiling purposes (optional).
Definitions with identical labels will be listed as one.
]]
---@field   label string
--[[
Apply `action` function to these nodes.
`group:groupname` can also be used here.
]]
---@field  nodenames OneOrMany<core.Node.namelike>
--[[
Only apply `action` to nodes that have one of, or any
combination of, these neighbors.
If left out or empty, any neighbor will do.
`group:groupname` can also be used here.
]]
---@field neighbors OneOrMany<core.Node.namelike>?
--[[
Only apply `action` to nodes that have no one of these neighbors.
If left out or empty, it has no effect.
`group:groupname` can also be used here.
]]
---@field without_neighbors OneOrMany<core.Node.namelike>?
--[[
Operation interval in seconds
]]
---@field  interval number?
--[[
Probability of triggering `action` per-node per-interval is 1.0 / chance (integers only)
]]
---@field  chance integer?
--[[
WIPDOC
]]
---@field min_y integer?
--[[
WIPDOC
]]
---@field max_y integer?
--[[
If true, catch-up behavior is enabled: The `chance` value is
temporarily reduced when returning to an area to simulate time lost
by the area being unattended. Note that the `chance` value can often
be reduced to 1.
]]
---@field catch_up boolean?
--[[
Function triggered for each qualifying node.
`active_object_count` is number of active objects in the node's
mapblock.
`active_object_count_wider` is number of active objects in the node's
mapblock plus all 26 neighboring mapblocks. If any neighboring
mapblocks are unloaded an estimate is calculated for them based on
loaded mapblocks.
]]
---@field action core.ABMDef.action
