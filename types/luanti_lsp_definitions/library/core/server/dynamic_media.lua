---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Server

-- --------------------------- DynamicMediaOptions -------------------------- --

--[[
WIPDOC
]]
---@class _.DynamicMediaOptions.__base
--[[
WIPDOC
]]
---@field to_player string?
--[[
WIPDOC
]]
---@field ephemeral boolean?
--[[
WIPDOC
]]
---@field client_cache boolean?

--[[
WIPDOC
]]
---@class core.DynamicMediaOptions.filepath : _.DynamicMediaOptions.__base
--[[
WIPDOC
]]
---@field filename string?
--[[
WIPDOC
]]
---@field filepath core.Path

--[[
WIPDOC
]]
---@class core.DynamicMediaOptions.filedata : _.DynamicMediaOptions.__base
--[[
WIPDOC
]]
---@field filename string
--[[
WIPDOC
]]
---@field filedata string

--[[
WIPDOC
]]
---@alias core.DynamicMediaOptions
--- | core.DynamicMediaOptions.filepath
--- | core.DynamicMediaOptions.filedata

-- ---------------------------- core.* functions ---------------------------- --

--[[
WIPDOC
]]
---@alias core.fn.dynamic_add_media fun(name:string):boolean

--[[
WIPDOC
]]
---@param options core.DynamicMediaOptions
---@param callback core.fn.dynamic_add_media
function core.dynamic_add_media(options, callback) end