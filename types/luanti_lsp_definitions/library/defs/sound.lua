---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Sounds

--[[
WIPDOC
]]
---@class core.SimpleSoundSpec.tablefmt
--[[
WIPDOC
]]
---@field name string
--[[
WIPDOC
]]
---@field gain number?
--[[
WIPDOC
]]
---@field pitch number?
--[[
WIPDOC
]]
---@field fade number?

--[[
WIPDOC
]]
---@alias core.SimpleSoundSpec.stringfmt string

--[[
WIPDOC
]]
---@alias core.SimpleSoundSpec
--- | core.SimpleSoundSpec.tablefmt
--- | core.SimpleSoundSpec.stringfmt

--[[
WIPDOC
]]
---@class core.SoundParamter
--[[
WIPDOC
]]
---@field gain number?
--[[
WIPDOC
]]
---@field pitch number?
--[[
WIPDOC
]]
---@field fade number?
--[[
WIPDOC
]]
---@field start_time number?
--[[
WIPDOC
]]
---@field loop boolean?
--[[
WIPDOC
]]
---@field pos vector?
--[[
WIPDOC
]]
---@field object core.ObjectRef?
--[[
WIPDOC
]]
---@field to_player string?
--[[
WIPDOC
]]
---@field exclude_player string?
--[[
WIPDOC
]]
---@field max_hear_distance number?