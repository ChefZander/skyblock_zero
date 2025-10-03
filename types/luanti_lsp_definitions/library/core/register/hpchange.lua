---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Global callback registration functions

-- -------------------------- PlayerHPChangeReason -------------------------- --

--[[
WIPDOC
]]
---@alias core.PlayerHPChangeReason.regular.type
--- | "set_hp"
--- | "fall"
--- | "drown"
--- | "respawn"
--- | string

--[[
WIPDOC
]]
---@class core.PlayerHPChangeReason.regular : {[string]:any}
--[[
WIPDOC
]]
---@field type core.PlayerHPChangeReason.regular.type
--[[
WIPDOC
]]
---@field from  "mod"|"engine"

--[[
WIPDOC
]]
---@class core.PlayerHPChangeReason.punch : core.PlayerHPChangeReason.regular
--[[
WIPDOC
]]
---@field type "punch"
--[[
WIPDOC
]]
---@field object core.ObjectRef?

--[[
WIPDOC
]]
---@class core.PlayerHPChangeReason.node_damage : core.PlayerHPChangeReason.regular
--[[
WIPDOC
]]
---@field type "node_damage"
--[[
WIPDOC
]]
---@field node core.Node.name?
--[[
WIPDOC
]]
---@field node_pos vec?

--[[
WIPDOC
]]
---@alias core.PlayerHPChangeReason
--- | core.PlayerHPChangeReason.regular
--- | core.PlayerHPChangeReason.punch
--- | core.PlayerHPChangeReason.node_damage

-- ---------------------------- core.* functions ---------------------------- --

--[[
WIPDOC
]]
---@alias core.fn.on_player_hpchange.logger fun(player:core.PlayerRef, hp_change:integer, reason:core.PlayerHPChangeReason)

--[[
* `core.register_on_player_hpchange(function(player, hp_change, reason), modifier)`
    * Called when the player gets damaged or healed
    * When `hp == 0`, damage doesn't trigger this callback.
    * When `hp == hp_max`, healing does still trigger this callback.
    * `player`: ObjectRef of the player
    * `hp_change`: the amount of change. Negative when it is damage.
      * Historically, the new HP value was clamped to [0, 65535] before
        calculating the HP change. This clamping has been removed as of
        version 5.10.0
    * `reason`: a PlayerHPChangeReason table.
        * The `type` field will have one of the following values:
            * `set_hp`: A mod or the engine called `set_hp` without
                        giving a type - use this for custom damage types.
            * `punch`: Was punched. `reason.object` will hold the puncher, or nil if none.
            * `fall`
            * `node_damage`: `damage_per_second` from a neighboring node.
                             `reason.node` will hold the node name or nil.
                             `reason.node_pos` will hold the position of the node
            * `drown`
            * `respawn`
        * Any of the above types may have additional fields from mods.
        * `reason.from` will be `mod` or `engine`.
    * `modifier`: when true, the function should return the actual `hp_change`.
       Note: modifiers only get a temporary `hp_change` that can be modified by later modifiers.
       Modifiers can return true as a second argument to stop the execution of further functions.
       Non-modifiers receive the final HP change calculated by the modifiers.
]]
---@param f core.fn.on_player_hpchange.logger
function core.register_on_player_hpchange(f) end

--[[
WIPDOC
]]
---@alias core.fn.on_player_hpchange.modifier fun(player:core.PlayerRef, hp_change:integer, reason:core.PlayerHPChangeReason):integer, boolean?

--[[
* `core.register_on_player_hpchange(function(player, hp_change, reason), modifier)`
    * Called when the player gets damaged or healed
    * When `hp == 0`, damage doesn't trigger this callback.
    * When `hp == hp_max`, healing does still trigger this callback.
    * `player`: ObjectRef of the player
    * `hp_change`: the amount of change. Negative when it is damage.
      * Historically, the new HP value was clamped to [0, 65535] before
        calculating the HP change. This clamping has been removed as of
        version 5.10.0
    * `reason`: a PlayerHPChangeReason table.
        * The `type` field will have one of the following values:
            * `set_hp`: A mod or the engine called `set_hp` without
                        giving a type - use this for custom damage types.
            * `punch`: Was punched. `reason.object` will hold the puncher, or nil if none.
            * `fall`
            * `node_damage`: `damage_per_second` from a neighboring node.
                             `reason.node` will hold the node name or nil.
                             `reason.node_pos` will hold the position of the node
            * `drown`
            * `respawn`
        * Any of the above types may have additional fields from mods.
        * `reason.from` will be `mod` or `engine`.
    * `modifier`: when true, the function should return the actual `hp_change`.
       Note: modifiers only get a temporary `hp_change` that can be modified by later modifiers.
       Modifiers can return true as a second argument to stop the execution of further functions.
       Non-modifiers receive the final HP change calculated by the modifiers.
]]
---@param f core.fn.on_player_hpchange.modifier
---@param modifier true
function core.register_on_player_hpchange(f, modifier) end

--[[
WIPDOC
]]
---@alias core.fn.on_dieplayer fun(ObjectRef:core.PlayerRef, reason: core.PlayerHPChangeReason)

--[[
* `core.register_on_dieplayer(function(ObjectRef, reason))`
    * Called when a player dies
    * `reason`: a PlayerHPChangeReason table, see register_on_player_hpchange
    * For customizing the death screen, see `core.show_death_screen`.
]]
---@param f core.fn.on_dieplayer
function core.register_on_dieplayer(f) end