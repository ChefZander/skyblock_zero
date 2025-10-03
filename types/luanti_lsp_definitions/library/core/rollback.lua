---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Rollback

--[[
WIPDOC
]]
---@class core.RollbackNodeAction
--[[
WIPDOC
]]
---@field [1] string
--[[
WIPDOC
]]
---@field [2] ivec
--[[
WIPDOC
]]
---@field [3] number
--[[
WIPDOC
]]
---@field [4] core.Node.get
--[[
WIPDOC
]]
---@field [5] core.Node.get

--[[
* `core.rollback_get_node_actions(pos, range, seconds, limit)`:
  returns `{{actor, pos, time, oldnode, newnode}, ...}`
    * Find who has done something to a node, or near a node
    * `actor`: `"player:<name>"`, also `"liquid"`.
]]
---@nodiscard
---@param pos ivector
---@param range integer
---@param seconds number
---@param limit number
---@return core.RollbackNodeAction[]
function core.rollback_get_node_actions(pos, range, seconds, limit) end

--[[
* `core.rollback_revert_actions_by(actor, seconds)`: returns
  `boolean, log_messages`.
    * Revert latest actions of someone
    * `actor`: `"player:<name>"`, also `"liquid"`.
]]
---@nodiscard
---@param actor string|"liquid"
---@param seconds number
---@return boolean success, string[] log_messages
function core.rollback_revert_actions_by(actor, seconds) end