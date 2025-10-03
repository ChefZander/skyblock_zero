---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Registered entities
-- luanti/doc/lua_api.md: Definition tables > Entity definition

--[[
WIPDOC
]]
---@alias core.Entity.name string

--[[
WIPDOC
]]
---@alias core.Entity.namelike
--- | core.Groups.armor
--- | core.Entity.name

-- -------------------------------- EntityDef ------------------------------- --

--[[
WIPDOC
]]
---@alias core.EntityDef.on_activate fun(self:core.Entity, staticdata:string, dtime_s:number)

--[[
WIPDOC
]]
---@alias core.EntityDef.on_deactivate fun(self:core.Entity, removal:boolean)

--[[
WIPDOC
]]
---@alias core.EntityDef.on_step fun(self:core.Entity, dtime:number, moveresult:core.Entity.moveresult?)

--[[
WIPDOC
]]
---@alias core.EntityDef.on_punch fun(self:core.Entity, puncher:core.EntityRef?, ime_from_last_punch:number?, tool_capabilities:core.ToolCapabilities?, dir:vector, damage:integer):boolean

--[[
WIPDOC
]]
---@alias core.EntityDef.on_death fun(self:core.Entity, killer:core.EntityRef?)

--[[
WIPDOC
]]
---@alias core.EntityDef.on_rightclick fun(self:core.Entity, clicker:core.EntityRef)

--[[
WIPDOC
]]
---@alias core.EntityDef.on_attach_child fun(self:core.Entity, child:core.EntityRef)

--[[
WIPDOC
]]
---@alias core.EntityDef.on_detach_child fun(self:core.Entity, child:core.EntityRef)

--[[
WIPDOC
]]
---@alias core.EntityDef.on_detach fun(self:core.Entity, parent:core.EntityRef)

--[[
WIPDOC
]]
---@alias core.EntityDef.get_staticdata fun(self:core.Entity):string

--[[
WIPDOC
]]
---@class core.EntityDef
--[[
WIPDOC
]]
---@field initial_properties core.ObjectProperties.set
--[[
WIPDOC
]]
---@field on_activate core.EntityDef.on_activate?
--[[
WIPDOC
]]
---@field on_deactivate core.EntityDef.on_deactivate?
--[[
WIPDOC
]]
---@field on_step core.EntityDef.on_step?
--[[
WIPDOC
]]
---@field on_punch core.EntityDef.on_punch?
--[[
WIPDOC
]]
---@field on_death core.EntityDef.on_death?
--[[
WIPDOC
]]
---@field on_rightclick core.EntityDef.on_rightclick?
--[[
WIPDOC
]]
---@field on_attach_child core.EntityDef.on_attach_child?
--[[
WIPDOC
]]
---@field on_detach_child core.EntityDef.on_detach_child?
--[[
WIPDOC
]]
---@field on_detach core.EntityDef.on_detach?
--[[
WIPDOC
]]
---@field get_staticdata core.EntityDef.get_staticdata?

-- --------------------------------- Entity --------------------------------- --

--[[
Functions receive a "luaentity" table as `self`:

* It has the member `name`, which is the registered name `("mod:thing")`
* It has the member `object`, which is an `core.EntityRef` pointing to the object
* The original prototype is visible directly via a metatable
]]
---@class core.Entity : core.EntityDef
--[[
WIPDOC
]]
---@field initial_properties core.ObjectProperties.set
--[[
WIPDOC
]]
---@field  name core.Entity.name
--[[
WIPDOC
]]
---@field  object core.EntityRef
