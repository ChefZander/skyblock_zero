---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `NodeTimerRef`

--[[
WIPDOC
]]
---@class core.NodeTimerRef
local NodeTimerRef = {}

--[[
* `set(timeout,elapsed)`
    * set a timer's state
    * `timeout` is in seconds, and supports fractional values (0.1 etc)
    * `elapsed` is in seconds, and supports fractional values (0.1 etc)
    * will trigger the node's `on_timer` function after `(timeout - elapsed)`
      seconds.
]]
---@param timeout number
---@param elapsed number
function NodeTimerRef:set(timeout, elapsed) end

--[[
WIPDOC
]]
---@param timeout number
function NodeTimerRef:start(timeout) end

--[[
WIPDOC
]]
function NodeTimerRef:stop() end

--[[
WIPDOC
]]
---@nodiscard
---@return number
function NodeTimerRef:get_timeout() end

--[[
WIPDOC
]]
---@nodiscard
---@return number
function NodeTimerRef:get_elapsed() end

--[[
WIPDOC
]]
---@nodiscard
---@return boolean
function NodeTimerRef:is_started() end