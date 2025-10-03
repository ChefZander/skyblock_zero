---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Particle definition
-- luanti/doc/lua_api.md: Definition tables > `ParticleSpawner` definition

-- --------------------------- ParticleDef.regular -------------------------- --

---@class core.ParticleDef.regular
--[[
WIPDOC
]]
---@field  pos vector
--[[
WIPDOC
]]
---@field  velocity vector?
--[[
WIPDOC
]]
---@field  acceleration vector?
--[[
WIPDOC
]]
---@field  expirationtime number
--[[
Scales the visual size of the particle texture.
If `node` is set, size can be set to 0 to spawn a randomly-sized
particle (just like actual node dig particles).
]]
---@field  size number?
--[[
If true collides with `walkable` nodes and, depending on the
`object_collision` field, objects too.
]]
---@field  collisiondetection boolean?
--[[
If true particle is removed when it collides.
Requires collisiondetection = true to have any effect.
]]
---@field  collision_removal boolean?
--[[
If true particle collides with objects that are defined as
`physical = true,` and `collide_with_objects = true,`.
Requires collisiondetection = true to have any effect.
]]
---@field  object_collision boolean?
--[[
If true faces player using y axis only
]]
---@field  vertical boolean?
--[[
The texture of the particle
v5.6.0 and later: also supports the table format described in the
following section, but due to a bug this did not take effect
(beyond the texture name).
v5.9.0 and later: fixes the bug.
Note: "texture.animation" is ignored here. Use "animation" below instead.
]]
---@field  texture core.ParticleTexture?
--[[
Optional, if specified spawns particle only on the player's client
]]
---@field  playername string?
--[[
Optional, specifies how to animate the particle texture
]]
---@field  animation core.TileAnimationDef?
--[[
Optional, specify particle self-luminescence in darkness.
Values 0-14.
]]
---@field  glow number?
--[[
v5.6.0 and later: Optional drag value, consult the following section
Note: Only a vector is supported here. Alternative forms like a single
number are not supported.
]]
---@field  drag vector?
--[[
v5.6.0 and later: Optional jitter range, consult the following section
]]
---@field  jitter core.ParticleSpawner.vec3_range?
--[[
v5.6.0 and later: Optional bounce range, consult the following section
]]
---@field  bounce core.ParticleSpawner.vec3_range?

-- ---------------------------- ParticleDef.node ---------------------------- --

--[[
WIPDOC
]]
---@class core.ParticleDef.node : core.ParticleDef.regular
--[[
Optional, if specified the particle will have the same appearance as
node dig particles for the given node.
`texture` and `animation` will be ignored if this is set.
]]
---@field  node core.Node.set?
--[[
Optional, only valid in combination with `node`
If set to a valid number 1-6, specifies the tile from which the
particle texture is picked.
Otherwise, the default behavior is used. (currently: any random tile)
]]
---@field  node_tile number?

-- ------------------------------- ParticleDef ------------------------------ --

--[[
WIPDOC
]]
---@alias core.ParticleDef
--- | core.ParticleDef.regular
--- | core.ParticleDef.node