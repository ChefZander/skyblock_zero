---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Server

--[[
* `core.request_shutdown([message],[reconnect],[delay])`: request for
  server shutdown. Will display `message` to clients.
    * `reconnect` == true displays a reconnect button
    * `delay` adds an optional delay (in seconds) before shutdown.
      Negative delay cancels the current active shutdown.
      Zero delay triggers an immediate shutdown.
]]
---@param message string?
---@param reconnect boolean?
---@param delay number?
function core.request_shutdown(message, reconnect, delay) end

--[[
* `core.cancel_shutdown_requests()`: cancel current delayed shutdown
]]
function core.cancel_shutdown_requests() end

--[[
Unofficial note: This is really cool i didn't know this
* `core.get_server_status(name, joined)`
    * Returns the server status string when a player joins or when the command
      `/status` is called. Returns `nil` or an empty string when the message is
      disabled.
    * `joined`: Boolean value, indicates whether the function was called when
      a player joined.
    * This function may be overwritten by mods to customize the status message.
]]
---@nodiscard
---@param name string
---@param joined boolean
---@return string?
function core.get_server_status(name, joined) end

--[[
* `core.get_server_uptime()`: returns the server uptime in seconds
]]
---@nodiscard
---@return number
function core.get_server_uptime() end

--[[
* `core.get_server_max_lag()`: returns the current maximum lag
  of the server in seconds or nil if server is not fully loaded yet
]]
---@nodiscard
---@return number?
function core.get_server_max_lag() end

--[[
* `core.remove_player(name)`: remove player from database (if they are not
  connected).
    * As auth data is not removed, `core.player_exists` will continue to
      return true. Call the below method as well if you want to remove auth
      data too.
    * Returns a code (0: successful, 1: no such player, 2: player is connected)
]]
---@nodiscard
---@param name string
---@return 0|1|2
function core.remove_player(name) end

--[[
* `core.remove_player_auth(name)`: remove player authentication data
    * Returns boolean indicating success (false if player nonexistent)
]]
---@nodiscard
---@param name string
---@return boolean success
function core.remove_player_auth(name) end

--[[ core.dynamic_add_media() split off into dynamic_media.lua ]]--