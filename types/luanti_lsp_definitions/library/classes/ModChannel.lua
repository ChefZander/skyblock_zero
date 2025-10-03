---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ModChannel`

--[[
WIPDOC
]]
---@class core.ModChannel
local ModChannel = {}

--[[
* `leave()`: leave the mod channel.
    * Server leaves channel `channel_name`.
    * No more incoming or outgoing messages can be sent to this channel from
      server mods.
    * This invalidate all future object usage.
    * Ensure you set ModChannel to nil after that to free Lua resources.
]]
function ModChannel:leave() end

--[[
* `is_writeable()`: returns true if channel is writeable and mod can send over
  it.
]]
---@nodiscard
---@return boolean
function ModChannel:is_writeable() end

--[[
* `send_all(message)`: Send `message` though the mod channel.
    * If mod channel is not writeable or invalid, message will be dropped.
    * Message size is limited to 65535 characters by protocol.
]]
---@param message string
function ModChannel:send_all(message) end
