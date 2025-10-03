---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Flag Specifier Format
-- luanti/doc/lua_api.md: Ores
-- luanti/doc/lua_api.md: Definition tables > Ore Definition

-- ---------------------------- OreDef.puff.flags --------------------------- --

--[[
WIPDOC
]]
---@class core.OreDef.puff.flags.tablefmt
--[[
WIPDOC
]]
---@field puff_cliffs boolean?
--[[
WIPDOC
]]
---@field nopuff_cliffs boolean?
--[[
WIPDOC
]]
---@field puff_additive_composition boolean?
--[[
WIPDOC
]]
---@field nopuff_additive_composition boolean?
--[[
WIPDOC
]]
---@alias core.OreDef.puff.flags.stringfmt string

--[[
WIPDOC
]]
---@alias core.OreDef.puff.flags
--- | core.OreDef.puff.flags.tablefmt
--- | core.OreDef.puff.flags.stringfmt

-- ------------------------------- OreDef.puff ------------------------------ --

--[[
WIPDOC
]]
---@class core.OreDef.puff : _.OreDef.__base
--[[
WIPDOC
]]
---@field  ore_type "puff"
--[[
WIPDOC
]]
---@field flags core.OreDef.puff.flags?
--[[
Ore has a 1 out of clust_scarcity chance of spawning in a node.
If the desired average distance between ores is 'd', set this to
d * d * d.
]]
---@field clust_scarcity integer?
--[[
Number of ores in a cluster
]]
---@field clust_num_ores integer?
--[[
Size of the bounding box of the cluster.
In this example, there is a 3 * 3 * 3 cluster where 8 out of the 27
nodes are coal ore.
]]
---@field clust_size integer?
--[[
If noise is above this threshold, ore is placed. Not needed for a
uniform distribution.
]]
---@field noise_threshold number?
--[[
NoiseParams structure describing one of the noises used for
ore distribution.
Needed by "sheet", "puff", "blob" and "vein" ores.
Omit from "scatter" ore for a uniform ore distribution.
Omit from "stratum" ore for a simple horizontal strata from y_min to
y_max.
]]
---@field noise_params core.NoiseParams.3d
--[[
"puff" type
]]
---@field np_puff_top core.NoiseParams.3d?
--[[
WIPDOC
]]
---@field np_puff_bottom core.NoiseParams.3d?