---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Object properties

-- ------------------ ObjectProperties.cube.textures.strict ----------------- --

--[[
WIPDOC
]]
---@class core.ObjectProperties.cube.textures.strict
--[[
WIPDOC
]]
---@field [1] core.Texture
--[[
WIPDOC
]]
---@field [2] core.Texture
--[[
WIPDOC
]]
---@field [3] core.Texture
--[[
WIPDOC
]]
---@field [4] core.Texture
--[[
WIPDOC
]]
---@field [5] core.Texture
--[[
WIPDOC
]]
---@field [6] core.Texture

--[[
WIPDOC
]]
---@alias core.ObjectProperties.cube.textures
--- | core.ObjectProperties.cube.textures.strict
--- | string[]

-- -------------------------- ObjectProperties.cube ------------------------- --

--[[
WIPDOC
]]
---@class core.ObjectProperties.cube.set : _.ObjectProperties.__base.set, _.ObjectProperties.cube.set.__partial

--[[
WIPDOC
]]
---@class core.ObjectProperties.cube.get : _.ObjectProperties.__base.get, _.ObjectProperties.cube.get.__partial

---@class _.ObjectProperties.cube.set.__partial : _.ObjectProperties.backface_culling.set.__partial, _.ObjectProperties.shaded.set.__partial
--[[
WIPDOC
]]
---@field visual "cube"
--[[
Number of required textures depends on visual:
"cube" uses 6 textures just like a node, but all 6 must be defined.
"sprite" uses 1 texture.
"upright_sprite" uses 2 textures: {front, back}.
"mesh" requires one texture for each mesh buffer/material (in order)
Deprecated usage of "wielditem" expects 'textures = {itemname}' (see 'visual' above).
Unofficial note: I *guessed* that it's string[] but i am not sure
]]
---@field textures core.ObjectProperties.cube.textures?

---@class _.ObjectProperties.cube.get.__partial : _.ObjectProperties.backface_culling.get.__partial, _.ObjectProperties.shaded.get.__partial
--[[
WIPDOC
]]
---@field visual "cube"
--[[
Number of required textures depends on visual:
"cube" uses 6 textures just like a node, but all 6 must be defined.
"sprite" uses 1 texture.
"upright_sprite" uses 2 textures: {front, back}.
"mesh" requires one texture for each mesh buffer/material (in order)
Deprecated usage of "wielditem" expects 'textures = {itemname}' (see 'visual' above).
Unofficial note: I *guessed* that it's string[] but i am not sure
]]
---@field textures core.ObjectProperties.cube.textures
