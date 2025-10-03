---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Object properties

--[[
WIPDOC
]]
---@class core.ObjectProperties.mesh.set : _.ObjectProperties.__base.set, _.ObjectProperties.mesh.set.__partial

--[[
WIPDOC
]]
---@class core.ObjectProperties.mesh.get : _.ObjectProperties.__base.get, _.ObjectProperties.mesh.get.__partial

---@class _.ObjectProperties.mesh.set.__partial : _.ObjectProperties.backface_culling.set.__partial, _.ObjectProperties.shaded.set.__partial
--[[
WIPDOC
]]
---@field visual "mesh"
--[[
File name of mesh when using "mesh" visual.
For legacy reasons, this uses a 10x scale for meshes: 10 units = 1 node.
]]
---@field mesh core.Path?
--[[
Number of required textures depends on visual:
"cube" uses 6 textures just like a node, but all 6 must be defined.
"sprite" uses 1 texture.
"upright_sprite" uses 2 textures: {front, back}.
"mesh" requires one texture for each mesh buffer/material (in order)
Deprecated usage of "wielditem" expects 'textures = {itemname}' (see 'visual' above).
Unofficial note: I *guessed* that it's string[] but i am not sure
]]
---@field textures core.Texture[]?

---@class _.ObjectProperties.mesh.get.__partial : _.ObjectProperties.backface_culling.get.__partial, _.ObjectProperties.shaded.get.__partial
--[[
WIPDOC
]]
---@field visual "mesh"
--[[
File name of mesh when using "mesh" visual.
For legacy reasons, this uses a 10x scale for meshes: 10 units = 1 node.
]]
---@field mesh core.Path
--[[
Number of required textures depends on visual:
"cube" uses 6 textures just like a node, but all 6 must be defined.
"sprite" uses 1 texture.
"upright_sprite" uses 2 textures: {front, back}.
"mesh" requires one texture for each mesh buffer/material (in order)
Deprecated usage of "wielditem" expects 'textures = {itemname}' (see 'visual' above).
Unofficial note: I *guessed* that it's string[] but i am not sure
]]
---@field textures core.Texture[]
