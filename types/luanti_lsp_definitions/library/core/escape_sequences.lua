---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Colors
-- luanti/doc/lua_api.md: Escape sequences

--[[
The escape sequence sets the text color to color
(Unofficial note: this is mostly for formspec UI elements)
]]
---@nodiscard
---@param color core.ColorString
---@return string
function core.get_color_escape_sequence(color) end

--[[
Equivalent to: core.get_color_escape_sequence(color) .. message .. core.get_color_escape_sequence("#ffffff")
(Unofficial note: this is mostly for formspec UI elements)
]]
---@nodiscard
---@param color core.ColorString
---@param message string
---@return string
function core.colorize(color, message) end

--[[
The escape sequence sets the background of the whole text element to color. Only defined for item descriptions and tooltips.
]]
---@nodiscard
---@param color core.ColorString
---@return string
function core.get_background_escape_sequence(color) end

--[[
Removes foreground colors added by get_color_escape_sequence.
]]
---@nodiscard
---@param str string
---@return string
function core.strip_foreground_colors(str) end

--[[
Removes background colors added by get_background_escape_sequence.
]]
---@nodiscard
---@param str string
---@return string
function core.strip_background_colors(str) end

--[[
Removes all color escape sequences.
]]
---@nodiscard
---@param str string
---@return string
function core.strip_colors(str) end

--[[
* `core.strip_escapes(str)`
    * Removes all escape sequences, including client-side translations and
      any unknown or future escape sequences that Luanti might define.
    * You can use this to clean text before logging or handing to an external system.
]]
---@nodiscard
---@param str string
---@return string
function core.strip_escape(str) end