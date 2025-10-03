---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Tile definition
-- luanti/doc/lua_api.md: Definition tables > Tile animation definition

-- -------------------- TileAnimationDef.vertical_frames -------------------- --

--[[
WIPDOC
]]
---@class core.TileAnimationDef.vertical_frames
--[[
WIPDOC
]]
---@field type "vertical_frames"
--[[
WIPDOC
]]
---@field aspect_w integer
--[[
WIPDOC
]]
---@field aspect_h integer
--[[
WIPDOC
]]
---@field length number

-- ------------------------ TileAnimationDef.sheet_2d ----------------------- --

--[[
WIPDOC
]]
---@class core.TileAnimationDef.sheet_2d
--[[
WIPDOC
]]
---@field type "sheet_2d"
--[[
WIPDOC
]]
---@field frames_w integer
--[[
WIPDOC
]]
---@field frames_h integer
--[[
WIPDOC
]]
---@field frame_length number

-- ---------------------------- TileAnimationDef ---------------------------- --

--[[
WIPDOC
]]
---@alias core.TileAnimationDef
--- | core.TileAnimationDef.vertical_frames
--- | core.TileAnimationDef.sheet_2d

-- ----------------------------- TileDef.__base ----------------------------- --

---@class _.TileDef.__base
--[[
WIPDOC
]]
---@field name core.Texture
--[[
WIPDOC

* @deprecated 5.X
]]
---@field image string?

-- ---------------------------- TileDef.animation --------------------------- --

--[[
WIPDOC
]]
---@class core.TileDef.animation : _.TileDef.__base
--[[
WIPDOC
]]
---@field animation core.TileAnimationDef


-- ----------------------------- TileDef.regular ---------------------------- --

--[[
WIPDOC
]]
---@alias core.TileDef.align_style
--- | "node"
--- | "world"
--- | "user"

--[[
WIPDOC
]]
---@class core.TileDef.regular : _.TileDef.__base
--[[
WIPDOC
]]
---@field backface_culling boolean?
--[[
WIPDOC
]]
---@field align_style core.TileDef.align_style?
--[[
WIPDOC
]]
---@field scale integer?

-- ------------------------------ TileDef.color ----------------------------- --

--[[
WIPDOC
]]
---@class core.TileDef.color : _.TileDef.__base
--[[
WIPDOC
]]
---@field color core.ColorSpec

-- --------------------------------- TileDef -------------------------------- --

--[[
WIPDOC
]]
---@alias core.TileDef
--- | core.Texture
--- | core.TileDef.animation
--- | core.TileDef.regular
--- | core.TileDef.color