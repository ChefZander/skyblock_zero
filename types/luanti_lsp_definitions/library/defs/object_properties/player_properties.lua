---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Object properties

-- ------------------------- PlayerProperties.__base ------------------------ --

--[[
WIPDOC
]]
---@class _.PlayerProperties.__base.set : _.ObjectProperties.__base.set
--[[
For players only. Defines the maximum amount of "breath" for the player.
Defaults to `core.PLAYER_MAX_BREATH_DEFAULT` (10).
]]
---@field breath_max integer?
--[[
For players only. Zoom FOV in degrees.
Note that zoom loads and/or generates world beyond the server's
maximum send and generate distances, so acts like a telescope.
Smaller zoom_fov values increase the distance loaded/generated.
Defaults to 15 in creative mode, 0 in survival mode.
zoom_fov = 0 disables zooming for the player.
]]
---@field zoom_fov number?
--[[
For players only. Camera height above feet position in nodes.
]]
---@field eye_height number?
--[[
The name to display on the head of the object. By default empty.
If the object is a player, a nil or empty nametag is replaced by the player's name.
For all other objects, a nil or empty string removes the nametag.
To hide a nametag, set its color alpha to zero. That will disable it entirely.
]]
---@field nametag string?
--[[
Defaults to true for players, false for other entities.
If set to true the entity will show as a marker on the minimap.
]]
---@field show_on_minimap boolean?

--[[
WIPDOC
]]
---@class _.PlayerProperties.__base.get : _.ObjectProperties.__base.get
--[[
For players only. Defines the maximum amount of "breath" for the player.
Defaults to `core.PLAYER_MAX_BREATH_DEFAULT` (10).
]]
---@field breath_max integer
--[[
For players only. Zoom FOV in degrees.
Note that zoom loads and/or generates world beyond the server's
maximum send and generate distances, so acts like a telescope.
Smaller zoom_fov values increase the distance loaded/generated.
Defaults to 15 in creative mode, 0 in survival mode.
zoom_fov = 0 disables zooming for the player.
]]
---@field zoom_fov number
--[[
For players only. Camera height above feet position in nodes.
]]
---@field eye_height number
--[[
The name to display on the head of the object. By default empty.
If the object is a player, a nil or empty nametag is replaced by the player's name.
For all other objects, a nil or empty string removes the nametag.
To hide a nametag, get its color alpha to zero. That will disable it entirely.
]]
---@field nametag string
--[[
Defaults to true for players, false for other entities.
If get to true the entity will show as a marker on the minimap.
]]
---@field show_on_minimap boolean

-- ---------------------------- PlayerProperties ---------------------------- --

---@class core.PlayerProperties.cube.set : _.PlayerProperties.__base.set, _.ObjectProperties.cube.set.__partial
---@class core.PlayerProperties.sprite.set : _.PlayerProperties.__base.set, _.ObjectProperties.sprite.set.__partial
---@class core.PlayerProperties.upright_sprite.set : _.PlayerProperties.__base.set, _.ObjectProperties.upright_sprite.set.__partial
---@class core.PlayerProperties.mesh.set : _.PlayerProperties.__base.set, _.ObjectProperties.mesh.set.__partial
---@class core.PlayerProperties.wielditem.set : _.PlayerProperties.__base.set, _.ObjectProperties.wielditem.set.__partial
---@class core.PlayerProperties.item.set : _.PlayerProperties.__base.set, _.ObjectProperties.item.__partial
---@class core.PlayerProperties.node.set : _.PlayerProperties.__base.set, _.ObjectProperties.node.set.__partial

---@alias core.PlayerProperties.set
--- | core.PlayerProperties.cube.set
--- | core.PlayerProperties.sprite.set
--- | core.PlayerProperties.upright_sprite.set
--- | core.PlayerProperties.mesh.set
--- | core.PlayerProperties.wielditem.set
--- | core.PlayerProperties.item.set
--- | core.PlayerProperties.node.set

---@class core.PlayerProperties.cube.get : _.PlayerProperties.__base.get, _.ObjectProperties.cube.get.__partial
---@class core.PlayerProperties.sprite.get : _.PlayerProperties.__base.get, _.ObjectProperties.sprite.get.__partial
---@class core.PlayerProperties.upright_sprite.get : _.PlayerProperties.__base.get, _.ObjectProperties.upright_sprite.get.__partial
---@class core.PlayerProperties.mesh.get : _.PlayerProperties.__base.get, _.ObjectProperties.mesh.get.__partial
---@class core.PlayerProperties.wielditem.get : _.PlayerProperties.__base.get, _.ObjectProperties.wielditem.get.__partial
---@class core.PlayerProperties.item.get : _.PlayerProperties.__base.get, _.ObjectProperties.item.__partial
---@class core.PlayerProperties.node.get : _.PlayerProperties.__base.get, _.ObjectProperties.node.get.__partial

---@alias core.PlayerProperties.get
--- | core.PlayerProperties.cube.get
--- | core.PlayerProperties.sprite.get
--- | core.PlayerProperties.upright_sprite.get
--- | core.PlayerProperties.mesh.get
--- | core.PlayerProperties.wielditem.get
--- | core.PlayerProperties.item.get
--- | core.PlayerProperties.node.get