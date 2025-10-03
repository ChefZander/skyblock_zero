---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Privilege definition

-- ------------------------------ PrivilegeSet ------------------------------ --

--[[
WIPDOC
]]
---@alias core.PrivilegeSet.keys
--- | "shout"
--- | "interact"
--- | "fast"
--- | "fly"
--- | "noclip"
--- | "teleport"
--- | "bring"
--- | "give"
--- | "settime"
--- | "debug"
--- | "privs"
--- | "basic_privs"
--- | "kick"
--- | "ban"
--- | "password"
--- | "protection_bypass"
--- | "server"
--- | "rollback"
--- | string

--[[
WIPDOC
]]
---@class core.PrivilegeSet : {[string]:boolean?}
--[[
WIPDOC
]]
---@field shout boolean?
--[[
WIPDOC
]]
---@field interact boolean?
--[[
WIPDOC
]]
---@field fast boolean?
--[[
WIPDOC
]]
---@field fly boolean?
--[[
WIPDOC
]]
---@field noclip boolean?
--[[
WIPDOC
]]
---@field teleport boolean?
--[[
WIPDOC
]]
---@field bring boolean?
--[[
WIPDOC
]]
---@field give boolean?
--[[
WIPDOC
]]
---@field settime boolean?
--[[
WIPDOC
]]
---@field debug boolean?
--[[
WIPDOC
]]
---@field privs boolean?
--[[
WIPDOC
]]
---@field basic_privs boolean?
--[[
WIPDOC
]]
---@field kick boolean?
--[[
WIPDOC
]]
---@field ban boolean?
--[[
WIPDOC
]]
---@field password boolean?
--[[
WIPDOC
]]
---@field protection_bypass boolean?
--[[
WIPDOC
]]
---@field server boolean?
--[[
WIPDOC
]]
---@field rollback boolean?

-- ------------------------------ PrivilegeDef ------------------------------ --

--[[
WIPDOC
]]
---@alias core.PrivilegeDef.on_grant fun(name:string, granter_name:string): boolean?

--[[
WIPDOC
]]
---@alias core.PrivilegeDef.on_revoke fun(name:string, revoker_name:string): boolean?

--[[
WIPDOC
]]
---@class core.PrivilegeDef
--[[
WIPDOC
]]
---@field description string?
--[[
WIPDOC
]]
---@field give_to_singleplayer boolean?
--[[
Whether to grant the privilege to the server admin.
Uses value of 'give_to_singleplayer' by default.
]]
---@field give_to_admin boolean?
--[[
Note that the above two callbacks will be called twice if a player is
responsible, once with the player name, and then with a nil player
name.
Return true in the above callbacks to stop register_on_priv_grant or
revoke being called.
]]
---@field on_grant core.PrivilegeDef.on_grant?
--[[
Note that the above two callbacks will be called twice if a player is
responsible, once with the player name, and then with a nil player
name.
Return true in the above callbacks to stop register_on_priv_grant or
revoke being called.
]]
---@field on_revoke core.PrivilegeDef.on_revoke?
