---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > `ParticleSpawner` definition

-- NOTE: only the modern ParticleSpawner definition is annotated. However,
-- interested contributors seeking to additionally annotate the legacy
-- ParticleSpawner definition is welcome to submit a complete PR/patch

--[[
WIPDOC
]]
---@class core.ParticleSpawnerID : integer

-- ----------------------- ParticleSpawnerDef.regular ----------------------- --

--[[
WIPDOC
]]
---@class core.ParticleSpawnerDef.regular
--[[
Number of particles spawned over the time period `time`.
]]
---@field  amount integer
--[[
Lifespan of spawner in seconds.
If time is 0 spawner has infinite lifespan and spawns the `amount` on
a per-second basis.
]]
---@field  time number
--[[
If true collide with `walkable` nodes and, depending on the
`object_collision` field, objects too.
]]
---@field  collisiondetection boolean?
--[[
If true particles are removed when they collide.
Requires collisiondetection = true to have any effect.
]]
---@field  collision_removal boolean?
--[[
If true particles collide with objects that are defined as
`physical = true,` and `collide_with_objects = true,`.
Requires collisiondetection = true to have any effect.
]]
---@field  object_collision boolean?
--[[
If defined, particle positions, velocities and accelerations are
relative to this object's position and yaw
]]
---@field attached core.ObjectRef?
--[[
If true face player using y axis only
]]
---@field  vertical boolean?
--[[
The texture of the particle
v5.6.0 and later: also supports the table format described in the
following section.
]]
---@field  texture core.ParticleTexture?
--[[
TODO separate both fields
Optional, if specified spawns particles only for this player
Can't be used together with `exclude_player`.
]]
---@field  playername string?
--[[
TODO separate both fields
Optional, if specified spawns particles not for this player
Added in v5.14.0. Can't be used together with `playername`.
]]
---@field  exclude_player string?
--[[
Optional, specifies how to animate the particles' texture
v5.6.0 and later: set length to -1 to synchronize the length
of the animation with the expiration time of individual particles.
(-2 causes the animation to be played twice, and so on)
]]
---@field  animation core.TileAnimationDef?
--[[
Optional, specify particle self-luminescence in darkness.
Values 0-14.
]]
---@field  glow core.Light.source?

-- -------------------- modern ParticleSpawner properties ------------------- --

---@class core.ParticleSpawnerDef.regular
--[[
WIPDOC
]]
---@field  pos core.ParticleSpawner.vec3_range?
--[[
WIPDOC
]]
---@field  pos_tween core.ParticleSpawner.tween.vec3_range?
--[[
WIPDOC
]]
---@field  vel core.ParticleSpawner.vec3_range?
--[[
WIPDOC
]]
---@field  vel_tween core.ParticleSpawner.tween.vec3_range?
--[[
WIPDOC
]]
---@field  acc core.ParticleSpawner.vec3_range?
--[[
WIPDOC
]]
---@field  acc_tween core.ParticleSpawner.vec3_range?
--[[
WIPDOC
]]
---@field  size core.ParticleSpawner.float_range?
--[[
WIPDOC
]]
---@field  size_tween core.ParticleSpawner.tween.float_range?
--[[
WIPDOC
]]
---@field  jitter core.ParticleSpawner.vec3_range?
--[[
WIPDOC
]]
---@field  jitter_tween core.ParticleSpawner.tween.vec3_range?
--[[
WIPDOC
]]
---@field  drag core.ParticleSpawner.vec3_range?
--[[
WIPDOC
]]
---@field  drag_tween core.ParticleSpawner.tween.vec3_range?
--[[
WIPDOC
]]
---@field  bounce core.ParticleSpawner.float_range?
--[[
WIPDOC
]]
---@field  bounce_tween core.ParticleSpawner.tween.float_range?
--[[
WIPDOC
]]
---@field  exptime core.ParticleSpawner.float_range?
--[[
WIPDOC
]]
---@field  exptime_tween core.ParticleSpawner.tween.float_range?
--[[
WIPDOC
]]
---@field  attract core.ParticleSpawner.attract?
--[[
WIPDOC
]]
---@field  radius core.ParticleSpawner.vec3_range?
--[[
WIPDOC
]]
---@field  radius_tween core.ParticleSpawner.tween.vec3_range?
--[[
WIPDOC
]]
---@field texpool core.ParticleTexture?

-- ------------------------- ParticleSpawnerDef.node ------------------------ --

--[[
WIPDOC
]]
---@class core.ParticleSpawnerDef.node
--[[
Optional, if specified the particles will have the same appearance as
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
---@field  node_tile integer?

-- ----------------------------- ParticleSpawner ---------------------------- --

--[[
WIPDOC
]]
---@alias core.ParticleSpawnerDef
--- | core.ParticleSpawnerDef.regular
--- | core.ParticleSpawnerDef.node