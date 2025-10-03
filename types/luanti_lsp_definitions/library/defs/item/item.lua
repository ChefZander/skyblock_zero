---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Items

--[[
WIPDOC
]]
---@alias core.Tool.name
--- | string

--[[
WIPDOC
]]
---@alias core.Item.name
--- | ""
--- | core.Tool.name
--- | core.Node.name

--[[
WIPDOC
]]
---@alias core.Item.namelike
--- | core.Groups.item
--- | core.Groups.tool
--- | core.Item.name

--[[
WIPDOC
]]
---@alias core.Tool.wear integer

--[[
WIPDOC
]]
---@class core.Item.tablefmt
--[[
WIPDOC
]]
---@field name core.Item.name
--[[
WIPDOC
]]
---@field count integer?
--[[
WIPDOC
]]
---@field wear core.Tool.wear?
--[[
WIPDOC
]]
---@field metadata string?

--[[
WIPDOC
]]
---@alias core.Item.stringfmt string

--[[
WIPDOC
]]
---@alias core.Item.simple
--- | core.Item.tablefmt
--- | core.Item.stringfmt

--[[
WIPDOC
]]
---@alias core.Item
--- | core.Item.simple
--- | core.ItemStack