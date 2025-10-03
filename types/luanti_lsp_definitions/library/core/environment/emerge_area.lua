---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Environment access

-- ------------------------------- EMERGE enum ------------------------------ --

--[[
WIPDOC
]]
---@class core.EmergeAction : integer

--[[
WIPDOC
]]
---@type core.EmergeAction
core.EMERGE_CANCELLED = nil

--[[
WIPDOC
]]
---@type core.EmergeAction
core.EMERGE_ERRORED = nil

--[[
WIPDOC
]]
---@type core.EmergeAction
core.EMERGE_FROM_MEMORY = nil

--[[
WIPDOC
]]
---@type core.EmergeAction
core.EMERGE_FROM_DISK = nil

--[[
WIPDOC
]]
---@type core.EmergeAction
core.EMERGE_GENERATED = nil

-- ---------------------------- core.* functions ---------------------------- --

--[[
WIPDOC
]]
---@alias core.fn.emerge_area fun(blockpos:ivec, action:core.EmergeAction , calls_remaining:integer, param:any?)

--[[
* `core.emerge_area(pos1, pos2, [callback], [param])`
    * Queue all blocks in the area from `pos1` to `pos2`, inclusive, to be
      asynchronously fetched from memory, loaded from disk, or if inexistent,
      generates them.
    * If `callback` is a valid Lua function, this will be called for each block
      emerged.
    * The function signature of callback is:
      `function EmergeAreaCallback(blockpos, action, calls_remaining, param)`
        * `blockpos` is the *block* coordinates of the block that had been
          emerged.
        * `action` could be one of the following constant values:
            * `core.EMERGE_CANCELLED`
            * `core.EMERGE_ERRORED`
            * `core.EMERGE_FROM_MEMORY`
            * `core.EMERGE_FROM_DISK`
            * `core.EMERGE_GENERATED`
        * `calls_remaining` is the number of callbacks to be expected after
          this one.
        * `param` is the user-defined parameter passed to emerge_area (or
          nil if the parameter was absent).
]]
---@param pos1 ivector
---@param pos2 ivector
---@param callback core.fn.emerge_area?
---@param param any?
function core.emerge_area(pos1, pos2, callback, param) end