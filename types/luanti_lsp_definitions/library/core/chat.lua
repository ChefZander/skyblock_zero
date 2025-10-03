---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Chat

--[[
WIPDOC
]]
---@param text string
function core.chat_send_all(text) end

--[[
WIPDOC
]]
---@param name string
---@param text string
function core.chat_send_player(name, text) end

--[[
* `core.format_chat_message(name, message)`
    * Used by the server to format a chat message, based on the setting `chat_message_format`.
      Refer to the documentation of the setting for a list of valid placeholders.
    * Takes player name and message, and returns the formatted string to be sent to players.
    * Can be redefined by mods if required, for things like colored names or messages.
    * **Only** the first occurrence of each placeholder will be replaced.
]]
---@nodiscard
---@param name string
---@param message string
---@return string
function core.format_chat_message(name, message) end
