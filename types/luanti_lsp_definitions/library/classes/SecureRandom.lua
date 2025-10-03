---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `SecureRandom`

-- ------------------------------- constructor ------------------------------ --

--[[
WIPDOC
]]
---@nodiscard
---@return core.SecureRandom
function SecureRandom() end

-- ------------------------------ SecureRandom ------------------------------ --

--[[
`SecureRandom`
--------------

Interface for the operating system's crypto-secure PRNG.

It can be created via `SecureRandom()`.  The constructor throws an error if a
secure random device cannot be found on the system.

### Methods

* `next_bytes([count])`: return next `count` (default 1, capped at 2048) many
  random bytes, as a string.
]]
---@class core.SecureRandom
SecureRandom = {}

--[[
* `next_bytes([count])`: return next `count` (default 1, capped at 2048) many
  random bytes, as a string.
]]
---@nodiscard
---@param count integer
---@return string
function SecureRandom:next_bytes(count) end
