---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `PcgRandom`

-- ------------------------------- constructor ------------------------------ --

--[[
WIPDOC
]]
---@nodiscard
---@param seed integer
---@param seq integer[]?
---@return core.PcgRandom
function PcgRandom(seed, seq) end

-- -------------------------------- PcgRandom ------------------------------- --

--[[
WIPDOC
]]
---@class core.PcgRandom
PcgRandom = {}

--[[
* `next()`: return next integer random number [`-2147483648`...`2147483647`]
]]
---@nodiscard
---@return integer
function PcgRandom:next() end

--[[
* `next(min, max)`: return next integer random number [`min`...`max`]
]]
---@nodiscard
---@param min integer
---@param max integer
---@return integer
function PcgRandom:next(min, max) end

--[[
* `rand_normal_dist(min, max, num_trials=6)`: return normally distributed
  random number [`min`...`max`].
    * This is only a rough approximation of a normal distribution with:
    * `mean = (max - min) / 2`, and
    * `variance = (((max - min + 1) ^ 2) - 1) / (12 * num_trials)`
    * Increasing `num_trials` improves accuracy of the approximation
]]
---@nodiscard
---@param min integer
---@param max integer
---@param num_trials integer?
---@return integer
function PcgRandom:rand_normal_dist(min, max, num_trials) end

--[[
* `get_state()`: return generator state encoded in string
]]
---@nodiscard
---@return string state
function PcgRandom:get_state() end

--[[
* `set_state(state_string)`: restore generator state from encoded string
]]
---@param state string
function PcgRandom:set_state(state) end
