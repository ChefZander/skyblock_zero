---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Object properties

-- ----------------- ObjectProperties.sprite.textures.strict ---------------- --

--[[
WIPDOC
]]
---@class core.ObjectProperties.sprite.textures.strict
--[[
WIPDOC
]]
---@field [1] number

--[[
WIPDOC
]]
---@alias core.ObjectProperties.sprite.textures
--- | core.ObjectProperties.sprite.textures.strict
--- | string[]

-- ------------------------- ObjectProperties.sprite ------------------------ --
--[[
WIPDOC
]]
---@class core.ObjectProperties.sprite.set : _.ObjectProperties.__base.set, _.ObjectProperties.sprite.set.__partial

--[[
WIPDOC
]]
---@class core.ObjectProperties.sprite.get : _.ObjectProperties.__base.get, _.ObjectProperties.sprite.get.__partial

---@class _.ObjectProperties.sprite.set.__partial : _.ObjectProperties.spritesheet.set.__partial, _.ObjectProperties.spritesheet.set.__partial
--[[
WIPDOC
]]
---@field visual "sprite"
--[[
Number of required textures depends on visual:
"cube" uses 6 textures just like a node, but all 6 must be defined.
"sprite" uses 1 texture.
"upright_sprite" uses 2 textures: {front, back}.
"mesh" requires one texture for each mesh buffer/material (in order)
Deprecated usage of "wielditem" expects 'textures = {itemname}' (see 'visual' above).
Unofficial note: I *guessed* that it's string[] but i am not sure
]]
---@field textures core.ObjectProperties.sprite.textures?

---@class _.ObjectProperties.sprite.get.__partial : _.ObjectProperties.spritesheet.get.__partial, _.ObjectProperties.spritesheet.get.__partial
--[[
WIPDOC
]]
---@field visual "sprite"
--[[
Number of required textures depends on visual:
"cube" uses 6 textures just like a node, but all 6 must be defined.
"sprite" uses 1 texture.
"upright_sprite" uses 2 textures: {front, back}.
"mesh" requires one texture for each mesh buffer/material (in order)
Deprecated usage of "wielditem" expects 'textures = {itemname}' (see 'visual' above).
Unofficial note: I *guessed* that it's string[] but i am not sure
]]
---@field textures core.ObjectProperties.sprite.textures
