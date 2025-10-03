---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Schematics

-- ----------------------------- Schematic.flag ----------------------------- --

--[[
WIPDOC
]]
---@class core.Schematic.flags.tablefmt
--[[
WIPDOC
]]
---@field place_center_x boolean?
--[[
WIPDOC
]]
---@field noplace_center_x boolean?
--[[
WIPDOC
]]
---@field place_center_y boolean?
--[[
WIPDOC
]]
---@field noplace_center_y boolean?
--[[
WIPDOC
]]
---@field place_center_z boolean?
--[[
WIPDOC
]]
---@field noplace_center_z boolean?

--[[
WIPDOC
]]
---@alias core.Schematic.flags.stringfmt string

--[[
WIPDOC
]]
---@alias core.Schematic.flags
--- | core.Schematic.flags.tablefmt
--- | core.Schematic.flags.stringfmt

-- ------------------------ SchematicDef.yslice_prob ------------------------ --

--[[
WIPDOC
]]
---@class core.SchematicDef.yslice_prob
--[[
WIPDOC
]]
---@field  ypos integer
--[[
* A probability value of `0` or `1` means that node will never appear
  (0% chance).
* A probability value of `254` or `255` means the node will always appear
  (100% chance).
* If the probability value `p` is greater than `1`, then there is a
  `(p / 256 * 100)` percent chance that node will appear when the schematic is
  placed on the map.
]]
---@field  prob integer

-- ---------------------------- SchematicDef.node --------------------------- --

--[[
WIPDOC
]]
---@class core.SchematicDef.Node
--[[
    * `name`: the name of the map node to place (required)
]]
---@field  name string
--[[
    * `param2`: the raw param2 value of the node being placed onto the map
      (default: 0)
]]
---@field param2 core.Param2?
--[[
    * `force_place`: boolean representing if the node should forcibly overwrite
      any previous contents (default: false)
]]
---@field force_place boolean?
--[[
    * `prob` (alias `param1`): the probability of this node being placed
      (default: 255)
]]
---@field prob integer?
--[[
    * `prob` (alias `param1`): the probability of this node being placed
      (default: 255)

* @deprecated
]]
---@field param1 integer?

-- -------------------------------- Schematic ------------------------------- --

--[[
WIPDOC
]]
---@class core.SchematicID

--[[
A schematic specifier identifies a schematic by either a filename to a
Luanti Schematic file (`.mts`) or through raw data supplied through Lua,
in the form of a table.
]]
---@class core.SchematicDef
--[[
* The `size` field is a 3D vector containing the dimensions of the provided
  schematic. (required field)
]]
---@field  size ivector
--[[
* The `yslice_prob` field is a table of {ypos, prob} slice tables. A slice table
  sets the probability of a particular horizontal slice of the schematic being
  placed. (optional field)
  `ypos` = 0 for the lowest horizontal slice of a schematic.
  The default of `prob` is 255.
    * A probability value of `0` or `1` means that node will never appear
      (0% chance).
    * A probability value of `254` or `255` means the node will always appear
      (100% chance).
    * If the probability value `p` is greater than `1`, then there is a
      `(p / 256 * 100)` percent chance that node will appear when the schematic is
      placed on the map.
]]
---@field  yslice_prob core.SchematicDef.yslice_prob
--[=[
* The `data` field is a flat table of Node tables making up the schematic,
  in the order of `[z [y [x]]]`. (required field)
  Each Node table contains:
    * `name`: the name of the map node to place (required)
    * `prob` (alias `param1`): the probability of this node being placed
      (default: 255)
    * `param2`: the raw param2 value of the node being placed onto the map
      (default: 0)
    * `force_place`: boolean representing if the node should forcibly overwrite
      any previous contents (default: false)
]=]
---@field  data core.SchematicDef.Node[]

--[[
WIPDOC
]]
---@alias core.Schematic
--- | core.SchematicID
--- | core.Path
--- | core.SchematicDef