---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Object properties

-- ------------- ObjectProperties.upright_sprite.textures.strict ------------ --

--[[
WIPDOC
]]
---@class core.ObjectProperties.upright_sprite.textures.strict
--[[
WIPDOC
]]
---@field [1] number
--[[
WIPDOC
]]
---@field [2] number

--[[
WIPDOC
]]
---@alias core.ObjectProperties.upright_sprite.textures
--- | core.ObjectProperties.upright_sprite.textures.strict
--- | string[]

-- ------------------- ObjectProperties.upright_sprite.set ------------------ --

--[[
WIPDOC
]]
---@class core.ObjectProperties.upright_sprite.set : _.ObjectProperties.__base.set, _.ObjectProperties.upright_sprite.set.__partial

--[[
WIPDOC
]]
---@class core.ObjectProperties.upright_sprite.get : _.ObjectProperties.__base.get, _.ObjectProperties.upright_sprite.get.__partial

---@class _.ObjectProperties.upright_sprite.set.__partial : _.ObjectProperties.spritesheet.set.__partial, _.ObjectProperties.shaded.set.__partial
--[[
WIPDOC
]]
---@field visual "upright_sprite"
--[[
Number of required textures depends on visual:
"cube" uses 6 textures just like a node, but all 6 must be defined.
"sprite" uses 1 texture.
"upright_sprite" uses 2 textures: {front, back}.
"mesh" requires one texture for each mesh buffer/material (in order)
Deprecated usage of "wielditem" expects 'textures = {itemname}' (see 'visual' above).
Unofficial note: I *guessed* that it's string[] but i am not sure
]]
---@field textures core.ObjectProperties.upright_sprite.textures?

---@class _.ObjectProperties.upright_sprite.get.__partial : _.ObjectProperties.spritesheet.get.__partial, _.ObjectProperties.shaded.get.__partial
--[[
WIPDOC
]]
---@field visual "upright_sprite"
--[[
Number of required textures depends on visual:
"cube" uses 6 textures just like a node, but all 6 must be defined.
"sprite" uses 1 texture.
"upright_sprite" uses 2 textures: {front, back}.
"mesh" requires one texture for each mesh buffer/material (in order)
Deprecated usage of "wielditem" expects 'textures = {itemname}' (see 'visual' above).
Unofficial note: I *guessed* that it's string[] but i am not sure
]]
---@field textures core.ObjectProperties.upright_sprite.textures
