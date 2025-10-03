---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Node definition

-- ------------------------------ NodeDef.tiles ----------------------------- --

--[[
WIPDOC
]]
---@class core.NodeDef.tiles.strict
--[[
WIPDOC
]]
---@field [1] core.TileDef?
--[[
WIPDOC
]]
---@field [2] core.TileDef?
--[[
WIPDOC
]]
---@field [3] core.TileDef?
--[[
WIPDOC
]]
---@field [4] core.TileDef?
--[[
WIPDOC
]]
---@field [5] core.TileDef?
--[[
WIPDOC
]]
---@field [6] core.TileDef?

--[[
WIPDOC
]]
---@alias core.NodeDef.tiles
--- | core.NodeDef.tiles.strict
--- | core.TileDef[]

-- -------------------------- NodeDef.special_tiles ------------------------- --

---@class core.NodeDef.special_tiles.strict
--[[
WIPDOC
]]
---@field [1] core.TileDef?
--[[
WIPDOC
]]
---@field [2] core.TileDef?

--[[
WIPDOC
]]
---@alias core.NodeDef.special_tiles
--- | core.NodeDef.special_tiles.strict
--- | core.TileDef[]

-- ----------------------------- NodeDef fields ----------------------------- --

---@class core.NodeDef
--[[
tiles = {tile definition 1, def2, def3, def4, def5, def6},
Textures of node; +Y, -Y, +X, -X, +Z, -Z
List can be shortened to needed length.
]]
---@field tiles core.NodeDef.tiles?
--[[
overlay_tiles = {tile definition 1, def2, def3, def4, def5, def6},
Same as `tiles`, but these textures are drawn on top of the base
tiles. You can use this to colorize only specific parts of your
texture. If the texture name is an empty string, that overlay is not
drawn. Since such tiles are drawn twice, it is not recommended to use
overlays on very common nodes.
]]
---@field overlay_tiles core.NodeDef.tiles?
--[[
special_tiles = {tile definition 1, Tile definition 2},
Special textures of node; used rarely.
List can be shortened to needed length.
]]
---@field special_tiles core.NodeDef.special_tiles?