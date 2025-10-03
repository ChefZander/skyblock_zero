---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Flag Specifier Format
-- luanti/doc/lua_api.md: Decoration types
-- luanti/doc/lua_api.md: Mapgen objects
-- luanti/doc/lua_api.md: Definition tables > Decoration definition

-- --------------------------- DecorationDef.flags -------------------------- --

---@class _.DecorationDef.flags.tablefmt.__base
--[[
WIPDOC
]]
---@field force_placement boolean?
--[[
WIPDOC
]]
---@field noforce_placement boolean?

---@class _.DecorationDef.flags.tablefmt.liquid_surface : _.DecorationDef.flags.tablefmt.__base
--[[
WIPDOC
]]
---@field liquid_surface boolean?
--[[
WIPDOC
]]
---@field noliquid_surface boolean?

---@class _.DecorationDef.flags.tablefmt.all : _.DecorationDef.flags.tablefmt.__base
--[[
WIPDOC
]]
---@field all_floors boolean?
--[[
WIPDOC
]]
---@field noall_floors boolean?
--[[
WIPDOC
]]
---@field all_ceilings boolean?
--[[
WIPDOC
]]
---@field noall_ceilings boolean?

--[[
WIPDOC
]]
---@alias core.DecorationDef.flags.tablefmt
--- | _.DecorationDef.flags.tablefmt.liquid_surface
--- | _.DecorationDef.flags.tablefmt.all

--[[
WIPDOC
]]
---@alias core.DecorationDef.flags.stringfmt string

--[[
WIPDOC
]]
---@alias core.DecorationDef.flags
--- | core.DecorationDef.flags.tablefmt
--- | core.DecorationDef.flags.stringfmt

-- ------------------- core.DecorationDef.schematic.flags ------------------- --

--[[
WIPDOC
]]
---@class core.DecorationDef.schematic.flags.tablefmt.liquid_surface : _.DecorationDef.flags.tablefmt.liquid_surface, core.Schematic.flags.tablefmt

--[[
WIPDOC
]]
---@class core.DecorationDef.schematic.flags.tablefmt.all : _.DecorationDef.flags.tablefmt.all, core.Schematic.flags.tablefmt

--[[
WIPDOC
]]
---@alias core.DecorationDef.schematic.flags.tablefmt
--- | core.DecorationDef.schematic.flags.tablefmt.liquid_surface
--- | core.DecorationDef.schematic.flags.tablefmt.all

--[[
WIPDOC
]]
---@alias core.DecorationDef.schematic.flags.stringfmt string

--[[
WIPDOC
]]
---@alias core.DecorationDef.schematic.flags
--- | core.DecorationDef.schematic.flags.tablefmt
--- | core.DecorationDef.schematic.flags.stringfmt