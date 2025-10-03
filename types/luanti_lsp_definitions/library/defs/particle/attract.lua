---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > `ParticleSpawner` definition

--[[
WIPDOC
]]
---@alias core.ParticleSpawner.kind
--- | "none"
--- | "point"
--- | "line"
--- | "plane"

--[[
WIPDOC
]]
---@class core.ParticleSpawner.attract
--[[
WIPDOC
]]
---@field  kind core.ParticleSpawner.kind
--[[
WIPDOC
]]
---@field  strength core.ParticleSpawner.float_range
--[[
WIPDOC
]]
---@field  strength_tween core.ParticleSpawner.tween.float_range?
--[[
WIPDOC
]]
---@field  origin core.ParticleSpawner.vec3?
--[[
WIPDOC
]]
---@field  origin_tween core.ParticleSpawner.tween.vec3?
--[[
WIPDOC
]]
---@field  direction core.ParticleSpawner.vec3?
--[[
WIPDOC
]]
---@field  direction_tween core.ParticleSpawner.tween.vec3?
--[[
WIPDOC
]]
---@field  origin_attached core.ObjectRef?
--[[
WIPDOC
]]
---@field  direction_attached core.ObjectRef?
--[[
WIPDOC
]]
---@field  die_on_contact boolean?