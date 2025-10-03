---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Flag Specifier Format
-- luanti/doc/lua_api.md: Decoration types
-- luanti/doc/lua_api.md: Mapgen objects
-- luanti/doc/lua_api.md: Definition tables > Decoration definition

--[[
WIPDOC
]]
---@class core.DecorationID : integer

-- ------------------------- DecorationDef partials ------------------------- --

---@class _.DecorationDef.fill_ratio.__partial
--[[
The value determines 'decorations per surface node'.
Used only if noise_params is not specified.
If >= 10.0 complete coverage is enabled and decoration placement uses
a different and much faster method.
]]
---@field fill_ratio number?

---@class _.DecorationDef.noise_params.__partial
--[[
NoiseParams structure describing the noise used for decoration
distribution.
A noise value is calculated for each square division and determines
'decorations per surface node' within each division.
If the noise value >= 10.0 complete coverage is enabled and
decoration placement uses a different and much faster method.
]]
---@field noise_params core.NoiseParams.3d?

-- -------------------------- DecorationDef.__base -------------------------- --

--[[
WIPDOC
]]
---@alias core.DecorationDef.check_offset
--- | -1
--- | 0
--- | 1

--[[
WIPDOC
]]
---@alias core.DecorationDef.biome
--- | string
--- | core.BiomeID
--- | core.BiomeDef

---@class _.DecorationDef.__base
--[[
Node (or list of nodes) that the decoration can be placed on
]]
---@field place_on OneOrMany<core.Node.name>
--[[
Size of the square (X / Z) divisions of the mapchunk being generated.
Determines the resolution of noise variation if used.
If the chunk size is not evenly divisible by sidelen, sidelen is made
equal to the chunk size.
]]
---@field sidelen integer
--[[
List of biomes in which this decoration occurs. Occurs in all biomes
if this is omitted, and ignored if the Mapgen being used does not
support biomes.
Can be a list of (or a single) biome names, IDs, or definitions.
]]
---@field biomes OneOrMany<core.DecorationDef.biome>?
--[[
*@default* `-31000`

Lower limit for decoration (inclusive).
Refer to the Y coordinate of the 'place_on' node.
]]
---@field y_min integer?
--[[
*@default* `31000`

Upper limit for decoration (inclusive).
Refer to the Y coordinate of the 'place_on' node.
]]
---@field y_max integer?
--[[
Node (or list of nodes) that the decoration only spawns next to.
Checks the 8 neighboring nodes on the same height,
and also the ones at the height plus the check_offset, excluding both center nodes.
]]
---@field spawn_by OneOrMany<core.Node.name>?
--[[
*@default* `0`

Specifies the offset that spawn_by should also check
The default value of -1 is useful to e.g check for water next to the base node.
0 disables additional checks, valid values: {-1, 0, 1}
]]
---@field check_offset core.DecorationDef.check_offset?
--[[
Number of spawn_by nodes that must be surrounding the decoration
position to occur.
If absent or -1, decorations occur next to any nodes.
]]
---@field num_spawn_by integer?
--[[
Flags for all decoration types.
- "liquid_surface": Find the highest liquid (not solid) surface under
   open air. Search stops and fails on the first solid node.
   Cannot be used with "all_floors" or "all_ceilings" below.
- "force_placement": Nodes other than "air" and "ignore" are replaced
   by the decoration.
- "all_floors", "all_ceilings": Instead of placement on the highest
   surface in a mapchunk the decoration is placed on all floor and/or
   ceiling surfaces, for example in caves and dungeons.
   Ceiling decorations act as an inversion of floor decorations so the
   effect of 'place_offset_y' is inverted.
   Y-slice probabilities do not function correctly for ceiling
   schematic decorations as the behavior is unchanged.
   If a single decoration registration has both flags the floor and
   ceiling decorations will be aligned vertically.
]]
---@field flags core.DecorationDef.flags?

-- -------------------------- DecorationDef.simple -------------------------- --

---@class _.DecorationDef.simple.fill_ratio : _.DecorationDef.__base, _.DecorationDef.fill_ratio.__partial, _.DecorationDef.simple.__partial
---@class _.DecorationDef.simple.noise_params : _.DecorationDef.__base, _.DecorationDef.noise_params.__partial, _.DecorationDef.simple.__partial

--[[
WIPDOC
]]
---@alias core.DecorationDef.simple
--- | _.DecorationDef.simple.fill_ratio
--- | _.DecorationDef.simple.noise_params

---@class _.DecorationDef.simple.__partial
--[[
Type. "simple", "schematic" or "lsystem" supported
]]
---@field deco_type "simple"
--[[
The node name used as the decoration.
If instead a list of strings, a randomly selected node from the list
is placed as the decoration.
]]
---@field decoration OneOrMany<core.Node.name>
--[[
*@default* `1`

Decoration height in nodes.
If height_max is not 0, this is the lower limit of a randomly
selected height.
]]
---@field height integer?
--[[
Upper limit of the randomly selected height.
If absent, the parameter 'height' is used as a constant.
]]
---@field height_max integer?
--[[
*@default* `0`

Param2 value of decoration nodes.
If param2_max is not 0, this is the lower limit of a randomly
selected param2.
]]
---@field param2 core.Param2?
--[[
*@default* `0`

Upper limit of the randomly selected param2.
If absent, the parameter 'param2' is used as a constant.
]]
---@field param2_max core.Param2?
--[[
Y offset of the decoration base node relative to the standard base
node position.
Can be positive or negative. Default is 0.
Effect is inverted for "all_ceilings" decorations.
Ignored by 'y_min', 'y_max' and 'spawn_by' checks, which always refer
to the 'place_on' node.
]]
---@field place_offset_y integer?

-- ------------------------- DecorationDef.schematic ------------------------ --

---@class _.DecorationDef.schematic.fill_ratio : _.DecorationDef.__base, _.DecorationDef.fill_ratio.__partial, _.DecorationDef.schematic.__partial
---@class _.DecorationDef.schematic.noise_params : _.DecorationDef.__base, _.DecorationDef.noise_params.__partial, _.DecorationDef.schematic.__partial

--[[
WIPDOC
]]
---@alias core.DecorationDef.schematic
--- | _.DecorationDef.schematic.fill_ratio
--- | _.DecorationDef.schematic.noise_params

---@class _.DecorationDef.schematic.__partial
--[[
Type. "simple", "schematic" or "lsystem" supported
]]
---@field deco_type "schematic"
--[[
If schematic is a string, it is the filepath relative to the current
working directory of the specified Luanti schematic file.
Could also be the ID of a previously registered schematic.
]]
---@field schematic core.Schematic
--[[
Map of node names to replace in the schematic after reading it.
]]
---@field replacements table<core.Node.name,core.Node.name>?
--[[
Rotation can be "0", "90", "180", "270", or "random"
]]
---@field rotation core.Schematic.rotation?
--[[
Y offset of the decoration base node relative to the standard base
node position.
Can be positive or negative. Default is 0.
Effect is inverted for "all_ceilings" decorations.
Ignored by 'y_min', 'y_max' and 'spawn_by' checks, which always refer
to the 'place_on' node.
]]
---@field place_offset_y integer?
--[[
WIPDOC
]]
---@field flags core.DecorationDef.schematic.flags

-- -------------------------- DecorationDef.lsystem ------------------------- --

---@class _.DecorationDef.lsystem.fill_ratio : _.DecorationDef.__base, _.DecorationDef.fill_ratio.__partial, _.DecorationDef.lsystem.__partial
---@class _.DecorationDef.lsystem.noise_params : _.DecorationDef.__base, _.DecorationDef.noise_params.__partial, _.DecorationDef.lsystem.__partial

--[[
WIPDOC
]]
---@alias core.DecorationDef.lsystem
--- | _.DecorationDef.lsystem.fill_ratio
--- | _.DecorationDef.lsystem.noise_params

---@class _.DecorationDef.lsystem.__partial
--[[
Type. "simple", "schematic" or "lsystem" supported
]]
---@field deco_type "lsystem"
--[[
Same as for `core.spawn_tree`.
See section [L-system trees] for more details.
]]
---@field treedef core.LSystemTreeDef

-- ------------------------------ DecorationDef ----------------------------- --

---@alias core.DecorationDef
--- | core.DecorationDef.simple
--- | core.DecorationDef.schematic
--- | core.DecorationDef.lsystem