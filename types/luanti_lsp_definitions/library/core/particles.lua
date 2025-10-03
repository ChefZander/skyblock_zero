---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Particles

--[[
* `core.add_particle(particle definition)`
    * Spawn a single particle
    * Deprecated: `core.add_particle(pos, velocity, acceleration,
      expirationtime, size, collisiondetection, texture, playername)`
]]
---@deprecated
---@param pos vector
---@param velocity vector
---@param acceleration vector
---@param expirationtime number
---@param size number
---@param collisiondetection boolean
---@param texture core.Texture
---@param playername string
function core.add_particle(pos, velocity, acceleration,
      expirationtime, size, collisiondetection, texture, playername) end

--[[
Unofficial note: Prefer not doing 100 000 particles in a single globalstep
Because that will make the network scream, with no way to debug it
Instead, invest time into particlespawners, invest time into creating an issue on luanti github, invest time into creating a client side mod
]]
---@param particle_def core.ParticleDef.regular
function core.add_particle(particle_def) end

--[[
WIPDOC
]]
---@deprecated
---@nodiscard
---@param amount integer
---@param time number
---@param minpos vector
---@param maxpos vector
---@param minvel vector
---@param maxvel vector
---@param minacc vector
---@param maxacc vector
---@param minexptime number
---@param maxexptime number
---@param minsize number
---@param maxsize number
---@param collisiondetection boolean
---@param texture core.Texture
---@param playername string
---@return core.ParticleSpawnerID
function core.add_particlespawner(amount, time, minpos, maxpos, minvel, maxvel, minacc, maxacc, minexptime, maxexptime, minsize, maxsize, collisiondetection, texture, playername) end
--[[
* Add a `ParticleSpawner`, an object that spawns an amount of particles
  over `time` seconds.
* Returns an `id`, and -1 if adding didn't succeed
]]
---@nodiscard
---@param particlespawner_def core.ParticleSpawnerDef
---@return core.ParticleSpawnerID
function core.add_particlespawner(particlespawner_def) end

--[[
* `core.delete_particlespawner(id, player)`
    * Delete `ParticleSpawner` with `id` (return value from
      `core.add_particlespawner`).
    * If playername is specified, only deletes on the player's client,
      otherwise on all clients.
]]
---@param id core.ParticleSpawnerID
---@param player string?
function core.delete_particlespawner(id, player) end