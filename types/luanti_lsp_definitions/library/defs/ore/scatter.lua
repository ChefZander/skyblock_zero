---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Ores


-- ------------------------ OreDef.scatter.__partial ------------------------ --

---@class _.OreDef.scatter.__partial
--[[
WIPDOC
]]
---@field  ore_type "scatter"
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

-- ----------------------------- OreDef.scatter ----------------------------- --


--[[
WIPDOC
]]
---@class core.OreDef.scatter.uniform : _.OreDef.__base, _.OreDef.scatter.__partial

--[[
WIPDOC
]]
---@class core.OreDef.scatter.nonuniform : _.OreDef.__base, _.OreDef.scatter.__partial
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
