---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Ores
-- luanti/doc/lua_api.md: Definition tables > Ore Definition

--[[
WIPDOC
]]
---@class core.OreID : integer

-- ------------------------------ OreDef.__base ----------------------------- --

---@class _.OreDef.__base
--[[
WIPDOC
]]
---@field name string?
--[[
Ore node to place
]]
---@field  ore core.Node.name
--[[
Param2 to set for ore (e.g. facedir rotation)
]]
---@field ore_param2 core.Param2?
--[[
Node to place ore in. Multiple are possible by passing a list.
]]
---@field  wherein OneOrMany<core.Node.name>
--[[
WIPDOC
]]
---@field y_min integer?
--[[
WIPDOC
]]
---@field y_max integer?
--[[
List of biomes in which this ore occurs.
Occurs in all biomes if this is omitted, and ignored if the Mapgen
being used does not support biomes.
Can be a list of (or a single) biome names, IDs, or definitions.
]]
---@field biomes OneOrMany<string>?

-- --------------------------------- OreDef --------------------------------- --

--[[
WIPDOC
]]
---@alias core.OreDef
--- | core.OreDef.scatter.uniform
--- | core.OreDef.scatter.nonuniform
--- | core.OreDef.sheet
--- | core.OreDef.puff
--- | core.OreDef.blob
--- | core.OreDef.vein
--- | core.OreDef.stratum