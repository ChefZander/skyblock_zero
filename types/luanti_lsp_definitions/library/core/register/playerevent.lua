---@meta _
-- DRAFT 1 DONE
-- builtin/game/register.lua
-- src/script/cpp_api/s_env.cpp

-- ------------------------------- PlayerEvent ------------------------------ --

--[[
WIPDOC
]]
---@alias core.PlayerEvent
--- | "hud_changed"
--- | "properties_changed"
--- | "health_changed"
--- | "breath_changed"

-- ---------------------------- core.* functions ---------------------------- --

--[[
WIPDOC
]]
---@alias core.fn.playerevent fun(player:core.PlayerRef, event:core.PlayerEvent)

--[[
WIPDOC
]]
---@param f core.fn.playerevent
function core.register_playerevent(f) end