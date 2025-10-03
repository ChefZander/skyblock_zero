---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Ores
-- luanti/doc/lua_api.md: Definition tables > Ore Definition

--[[
WIPDOC
]]
---@class core.OreDef.sheet : _.OreDef.__base
--[[
WIPDOC
]]
---@field  ore_type "sheet"
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
"sheet" type
]]
---@field column_height_min integer?
--[[
"sheet" type
]]
---@field column_height_max integer?
--[[
"sheet" type
]]
---@field column_midpoint_factor number?