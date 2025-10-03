---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > `ParticleSpawner` definition

-- -------------------------- ParticleSpawner.vec2 -------------------------- --

--[[
WIPDOC
]]
---@alias core.ParticleSpawner.vec2
--- | vec2.xy
--- | number

-- -------------------------- ParticleSpawner.vec3 -------------------------- --

---@alias core.ParticleSpawner.vec3
--- | vector
--- | number

-- ----------------------- ParticleSpawner.float_range ---------------------- --

---@class _.ParticleSpawner.float_range
--[[
WIPDOC
]]
---@field min number
--[[
WIPDOC
]]
---@field max number

--[[
WIPDOC
]]
---@alias core.ParticleSpawner.float_range
--- | _.ParticleSpawner.float_range
--- | number

-- ----------------------- ParticleSpawner.vec2_range ----------------------- --

---@class _.ParticleSpawner.vec2_range
--[[
WIPDOC
]]
---@field min vec2.xy
--[[
WIPDOC
]]
---@field max vec2.xy
--[[
WIPDOC
]]
---@field bias number?

--[[
WIPDOC
]]
---@alias core.ParticleSpawner.vec2_range
--- | _.ParticleSpawner.vec2_range
--- | core.ParticleSpawner.vec2

-- ----------------------- ParticleSpawner.vec3_range ----------------------- --

---@class _.ParticleSpawner.vec3_range
--[[
WIPDOC
]]
---@field min vector
--[[
WIPDOC
]]
---@field max vector
--[[
WIPDOC
]]
---@field bias number?

--[[
WIPDOC
]]
---@alias core.ParticleSpawner.vec3_range
--- | _.ParticleSpawner.vec3_range
--- | core.ParticleSpawner.vec3

-- -------------------------- ParticleSpawner.tween ------------------------- --

--[[
WIPDOC
]]
---@alias core.ParticleSpawner.tween.style
--- | "fwd"
--- | "rev"
--- | "pulse"
--- | "flicker"

---@class _.ParticleSpawner.tween.__base
--[[
WIPDOC
]]
---@field  style core.ParticleSpawner.tween.style?
--[[
WIPDOC
]]
---@field  reps number?
--[[
WIPDOC
]]
---@field  start number?

--[[
WIPDOC
]]
---@class core.ParticleSpawner.tween.float : {[integer]:number}, _.ParticleSpawner.tween.__base

--[[
WIPDOC
]]
---@class core.ParticleSpawner.tween.vec2 : {[integer]:core.ParticleSpawner.vec2}, _.ParticleSpawner.tween.__base

--[[
WIPDOC
]]
---@class core.ParticleSpawner.tween.vec3 : {[integer]:core.ParticleSpawner.vec3}, _.ParticleSpawner.tween.__base

--[[
WIPDOC
]]
---@class core.ParticleSpawner.tween.float_range : {[integer]:core.ParticleSpawner.float_range},  _.ParticleSpawner.tween.__base

--[[
WIPDOC
]]
---@class core.ParticleSpawner.tween.vec3_range : {[integer]:core.ParticleSpawner.vec3_range}, _.ParticleSpawner.tween.__base