---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Global callback registration functions

-- ---------------------------------- Cheat --------------------------------- --

--[[
WIPDOC
]]
---@alias core.Cheat.type
--- | "moved_too_fast"
--- | "interacted_too_far"
--- | "interacted_with_self"
--- | "interacted_while_dead"
--- | "finished_unknown_dig"
--- | "dug_unbreakable"
--- | "dug_too_fast"

--[[
WIPDOC
]]
---@class core.Cheat
--[[
WIPDOC
]]
---@field type core.Cheat.type

-- ---------------------------- core.* functions ---------------------------- --

--[[
WIPDOC
]]
---@alias core.fn.on_cheat fun(ObjectRef:core.PlayerRef, cheat:core.Cheat)

--[[
* `core.register_on_cheat(function(ObjectRef, cheat))`
    * Called when a player cheats
    * `cheat`: `{type=<cheat_type>}`, where `<cheat_type>` is one of:
        * `moved_too_fast`
        * `interacted_too_far`
        * `interacted_with_self`
        * `interacted_while_dead`
        * `finished_unknown_dig`
        * `dug_unbreakable`
        * `dug_too_fast`
]]
---@param f core.fn.on_cheat
function core.register_on_cheat(f) end