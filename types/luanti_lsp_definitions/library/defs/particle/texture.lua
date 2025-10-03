---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > `ParticleSpawner` definition

--[[
WIPDOC
]]
---@alias core.ParticleTexture.blend
--- | "alpha"
--- | "clip"
--- | "add"
--- | "screen"
--- | "sub"

--[[
WIPDOC
]]
---@class core.ParticleTexture.tablefmt
--[[
WIPDOC
]]
---@field  name core.Texture
--[[
WIPDOC
]]
---@field  alpha number?
--[[
WIPDOC
]]
---@field  alpha_tween core.ParticleSpawner.tween.float?
--[[
WIPDOC
]]
---@field  scale core.ParticleSpawner.vec2?
--[[
WIPDOC
]]
---@field  scale_tween core.ParticleSpawner.tween.vec2?
--[[
WIPDOC
]]
---@field  blend core.ParticleTexture.blend?
--[[
WIPDOC
]]
---@field  animation core.TileAnimationDef?

--[[
WIPDOC
]]
---@class core.ParticleTexture.stringfmt

--[[
WIPDOC
]]
---@alias core.ParticleTexture
--- | core.ParticleTexture.tablefmt
--- | core.ParticleTexture.stringfmt