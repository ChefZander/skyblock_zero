---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > LBM (LoadingBlockModifier) definition

-- ------------------------------ LBMDef.__base ----------------------------- --

--[[
LBM (LoadingBlockModifier) definition
-------------------------------------

Used by `core.register_lbm`.

A loading block modifier (LBM) is used to define a function that is called for
specific nodes (defined by `nodenames`) when a mapblock which contains such nodes
gets **activated** (**not loaded!**).

*Note*: LBMs operate on a "snapshot" of node positions taken once before they are triggered.
That means if an LBM callback adds a node, it won't be taken into account.
However the engine guarantees that at the point in time when the callback is called
that all given positions contain a matching node.

For `run_at_every_load = false` to work, both mapblocks and LBMs have timestamps
associated with them:

* Each mapblock has a "last active" timestamp. It is also updated when the
  mapblock is generated.
* For each LBM, an introduction timestamp is stored in the world data, identified
  by the LBM's `name` field. If an LBM disappears, the corresponding timestamp
  is cleared.

When a mapblock is activated, only LBMs whose introduction timestamp is newer
than the mapblock's timestamp are run.

*Note*: For maps generated in 5.11.0 or older, many newly generated mapblocks
did not get a timestamp set. This means LBMs introduced between generation time
and time of first activation will never run.
Currently the only workaround is to use `run_at_every_load = true`.
]]
---@class _.LBMDef.__base
--[[
Descriptive label for profiling purposes (optional).
Definitions with identical labels will be listed as one.
]]
---@field label string?
--[[
Identifier of the LBM, should follow the modname:<whatever> convention
]]
---@field name string?
--[[
List of node names to trigger the LBM on.
]]
---@field nodenames core.Node.namelike[]?
--[[
If `false`: The LBM only runs on mapblocks the first time they are
activated after the LBM was introduced.
It never runs on mapblocks generated after the LBM's introduction.
See above for details.

If `true`: The LBM runs every time a mapblock is activated.
]]
---@field run_at_every_load boolean?

-- --------------------------------- LBMDef --------------------------------- --

--[[
WIPDOC
]]
---@alias core.LBMDef.action.fn fun(pos:ivec, node:core.Node.get, dtime_s:number)

---@class core.LBMDef.action : _.LBMDef.__base
--[[
Function triggered for each qualifying node.

`dtime_s` is the in-game time (in seconds) elapsed since the mapblock
was last active (available since 5.7.0).
]]
---@field action core.LBMDef.action.fn

--[[
WIPDOC
]]
---@alias core.LBMDef.bulk_action.fn fun(pos_list:ivec[], dtime_s:number)

---@class core.LBMDef.bulk_action : _.LBMDef.__base
--[[
Function triggered with a list of all applicable node positions at once.

This can be provided as an alternative to `action` (not both).
Available since `core.features.bulk_lbms` (5.10.0)
`dtime_s`: as above
]]
---@field bulk_action core.LBMDef.bulk_action.fn

---@alias core.LBMDef
--- | core.LBMDef.action
--- | core.LBMDef.bulk_action