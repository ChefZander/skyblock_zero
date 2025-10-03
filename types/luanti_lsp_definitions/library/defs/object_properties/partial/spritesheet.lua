---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Object properties

---@class _.ObjectProperties.spritesheet.set.__partial
--[[
Used with spritesheet textures for animation and/or frame selection
according to position relative to player.
Defines the number of columns and rows in the spritesheet:
{columns, rows}.
]]
---@field spritediv vec2i.xy?
--[[
Used with spritesheet textures.
Defines the {column, row} position of the initially used frame in the
spritesheet.
]]
---@field initial_sprite_basepos vec2i.xy?

---@class _.ObjectProperties.spritesheet.get.__partial
--[[
Used with spritesheet textures for animation and/or frame selection
according to position relative to player.
Defines the number of columns and rows in the spritesheet:
{columns, rows}.
]]
---@field spritediv vec2i.xy
--[[
Used with spritesheet textures.
Defines the {column, row} position of the initially used frame in the
spritesheet.
]]
---@field initial_sprite_basepos vec2i.xy
