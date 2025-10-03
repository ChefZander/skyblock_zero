---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Object properties

-- --------------- ObjectProperties.wielditem.textures.strict --------------- --

--[[
WIPDOC
]]
---@class core.ObjectProperties.wielditem.textures.strict
--[[
WIPDOC
]]
---@field [1] number

--[[
WIPDOC
]]
---@alias core.ObjectProperties.wielditem.textures
--- | core.ObjectProperties.wielditem.textures.strict
--- | string[]

-- ----------------------- ObjectProperties.wielditem ----------------------- --

--[[
WIPDOC
]]
---@class core.ObjectProperties.wielditem.set : _.ObjectProperties.__base.set, _.ObjectProperties.wielditem.set.__partial

--[[
WIPDOC
]]
---@class core.ObjectProperties.wielditem.get : _.ObjectProperties.__base.get, _.ObjectProperties.wielditem.get.__partial

---@class _.ObjectProperties.wielditem.set.__partial
--[[
WIPDOC
]]
---@field visual "wielditem"
--[[
WIPDOC
]]
---@field wield_item core.Item.name
--[[
WIPDOC

* @deprecated
]]
---@field textures core.ObjectProperties.wielditem.textures?

---@class _.ObjectProperties.wielditem.get.__partial
--[[
WIPDOC
]]
---@field visual "wielditem"
--[[
WIPDOC
]]
---@field wield_item core.Item.name
--[[
WIPDOC

* @deprecated 5.X
]]
---@field textures core.ObjectProperties.wielditem.textures

