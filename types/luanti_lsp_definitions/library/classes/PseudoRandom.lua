---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `PseudoRandom`

-- ------------------------------- constructor ------------------------------ --

--[[
WIPDOC
]]
---@nodiscard
---@param seed integer
---@return core.PseudoRandom
function PseudoRandom(seed) end

-- ------------------------------ PseudoRandom ------------------------------ --

--[[
`PseudoRandom`
--------------

A 16-bit pseudorandom number generator.
Uses a well-known LCG algorithm introduced by K&R.

**Note**:
`PseudoRandom` is slower and has worse random distribution than `PcgRandom`.
Use `PseudoRandom` only if you need output to match the well-known LCG algorithm introduced by K&R.
Otherwise, use `PcgRandom`.

* constructor `PseudoRandom(seed)`
  * `seed`: 32-bit signed number
]]
---@class core.PseudoRandom
local PseudoRandom = {}

--[[
* `next()`: return next integer random number [`0`...`32767`]
]]
---@nodiscard
---@return integer
function PseudoRandom:next() end

--[[
* `next(min, max)`: return next integer random number [`min`...`max`]
    * Either `max - min == 32767` or `max - min <= 6553` must be true
      due to the simple implementation making a bad distribution otherwise.
]]
---@nodiscard
---@param min integer
---@param max integer
---@return integer
function PseudoRandom:next(min, max) end

--[[
* `get_state()`: return state of pseudorandom generator as number
    * use returned number as seed in PseudoRandom constructor to restore
]]
---@nodiscard
---@return integer
function PseudoRandom:get_state() end