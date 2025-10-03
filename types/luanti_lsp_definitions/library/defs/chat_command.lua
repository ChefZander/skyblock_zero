---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Chat command definition

--[[
WIPDOC
]]
---@alias core.ChatCommandDef.keys
--- | "pulverize"
--- | "fixlight"
--- | "dump"
--- | "grantme"
--- | "rollback_check"
--- | "mods"
--- | "days"
--- | "last-login"
--- | "help"
--- | "privs"
--- | "clearinv"
--- | "status"
--- | "msg"
--- | "shutdown"
--- | "revokeme"
--- | "grant"
--- | "revoke"
--- | "admin"
--- | "ban"
--- | "kick"
--- | "giveme"
--- | "remove_player"
--- | "unban"
--- | "haspriv"
--- | "kill"
--- | "set"
--- | "rollback"
--- | "auth_reload"
--- | "clearobjects"
--- | "setpassword"
--- | "me"
--- | "emergeblocks"
--- | "teleport"
--- | "give"
--- | "time"
--- | "spawnentity"
--- | "clearpassword"
--- | "deleteblocks"
--- | string

--[[
WIPDOC
]]
---@alias core.ChatCommandDef.func fun(name:string, param:string): boolean?, string?

--[[
WIPDOC
]]
---@class core.ChatCommandDef
--[[
Note that in params, the conventional use of symbols is as follows:

* `<>` signifies a placeholder to be replaced when the command is used. For
  example, when a player name is needed: `<name>`
* `[]` signifies param is optional and not required when the command is used.
  For example, if you require param1 but param2 is optional:
  `<param1> [<param2>]`
* `|` signifies exclusive or. The command requires one param from the options
  provided. For example: `<param1> | <param2>`
* `()` signifies grouping. For example, when param1 and param2 are both
  required, or only param3 is required: `(<param1> <param2>) | <param3>`
]]
---@field params string?
--[[
WIPDOC
]]
---@field description string?
--[[
WIPDOC
]]
---@field privs core.PrivilegeSet?
--[[
WIPDOC
]]
---@field func core.ChatCommandDef.func

--[[
WIPDOC
]]
---@class core.ChatCommandDef.override
--[[
WIPDOC
]]
---@field func core.ChatCommandDef.func?