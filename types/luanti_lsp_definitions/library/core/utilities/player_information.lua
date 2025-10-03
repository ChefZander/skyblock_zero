---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Utilities

-- ----------------------------- core.PlayerInfo ---------------------------- --

--[[
WIPDOC
]]
---@class core.PlayerInfo
--[[
IP address of client
]]
---@field address  string
--[[
IPv4 / IPv6
]]
---@field ip_version  4|6
--[[
seconds since client connected
]]
---@field connection_uptime  number
--[[
protocol version used by client
]]
---@field protocol_version  core.Protocol
--[[
supported formspec version
]]
---@field formspec_version  integer
--[[
Language code used for translation
]]
---@field lang_code  core.LuantiSettings.enums.language
--[[
minimum round trip time
]]
---@field min_rtt  number?
--[[
maximum round trip time
]]
---@field max_rtt  number?
--[[
average round trip time
]]
---@field avg_rtt  number?
--[[
minimum packet time jitter
]]
---@field min_jitter  number?
--[[
maximum packet time jitter
]]
---@field max_jitter  number?
--[[
average packet time jitter
]]
---@field avg_jitter  number?
--[[
The version information is provided by the client and may be spoofed
or inconsistent in engine forks. You must not use this for checking
feature availability of clients. Instead, do use the fields
`protocol_version` and `formspec_version` where it matters.
Use `core.protocol_versions` to map Luanti versions to protocol versions.
This version string is only suitable for analysis purposes.
full version string
]]
---@field version_string  string

-- ---------------------------- PlayerWindowInfo ---------------------------- --

--[[
Unofficial note: You can compute the pixel size from this, if you are crazy you can make a library based on this or something
Will only be present if the client sent this information (requires v5.7+)

Note that none of these things are constant, they are likely to change during a client
connection as the player resizes the window and moves it between monitors

real_gui_scaling and real_hud_scaling can be used instead of DPI.
OSes don't necessarily give the physical DPI, as they may allow user configuration.
real_*_scaling is just OS DPI / 96 but with another level of user configuration.
]]
---@class core.PlayerWindowInfo
--[[
Current size of the in-game render target (pixels).

This is usually the window size, but may be smaller in certain situations,
such as side-by-side mode.
]]
---@field size  vec2i.xy
--[[
Estimated maximum formspec size before Luanti will start shrinking the
formspec to fit. For a fullscreen formspec, use the size returned by
this table  and `padding[0,0]`. `bgcolor[;true]` is also recommended.
]]
---@field max_formspec_size  vec2i.xy
--[[
GUI Scaling multiplier
Equal to the setting `gui_scaling` multiplied by `dpi / 96`
]]
---@field real_gui_scaling  number
--[[
HUD Scaling multiplier
Equal to the setting `hud_scaling` multiplied by `dpi / 96`
]]
---@field real_hud_scaling  number
--[[
Whether the touchscreen controls are enabled.
Usually (but not always) `true` on Android.
Requires at least version 5.9.0 on the client. For older clients, it
is always set to `false`.
]]
---@field touch_controls  boolean

-- ---------------------------- core.* functions ---------------------------- --

--[[
WIPDOC
]]
---@nodiscard
---@param player_name string
---@return core.PlayerInfo
function core.get_player_information(player_name) end

--[[
WIPDOC
]]
---@nodiscard
---@param player_name string
---@return core.PlayerWindowInfo? # Client must have version 5.7+
function core.get_player_window_information(player_name) end