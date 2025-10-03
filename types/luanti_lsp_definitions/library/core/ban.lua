---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Bans

--[[
* `core.get_ban_list()`: returns a list of all bans formatted as string
]]
---@nodiscard
---@return string
function core.get_ban_list() end

--[[
* `core.get_ban_description(ip_or_name)`: returns list of bans matching
  IP address or name formatted as string
]]
---@nodiscard
---@param ip_or_name string
---@return string
function core.get_ban_description(ip_or_name) end

--[[
* `core.ban_player(name)`: ban the IP of a currently connected player
    * Returns boolean indicating success
]]
---@nodiscard
---@param name string
---@return boolean success
function core.ban_player(name) end

--[[
* `core.unban_player_or_ip(ip_or_name)`: remove ban record matching
  IP address or name
]]
---@param ip_or_name string
function core.unban_player_or_ip(ip_or_name) end

--[=[
* `core.kick_player(name[, reason[, reconnect]])`: disconnect a player with an optional
  reason.
    * Returns boolean indicating success (false if player nonexistent)
    * If `reconnect` is true, allow the user to reconnect.
]=]
---@nodiscard
---@param name string
---@param reason string?
---@param reconnect boolean?
---@return boolean success
function core.kick_player(name, reason, reconnect) end

--[=[
* `core.disconnect_player(name[, reason[, reconnect]])`: disconnect a player with an
  optional reason, this will not prefix with 'Kicked: ' like kick_player.
  If no reason is given, it will default to 'Disconnected.'
    * Returns boolean indicating success (false if player nonexistent)
]=]
---@nodiscard
---@param name string
---@param reason string?
---@param reconnect boolean?
---@return boolean
function core.disconnect_player(name, reason, reconnect) end