---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Utilities

-- -------------------------------- GameInfo -------------------------------- --

--[[
WIPDOC
]]
---@class core.GameInfo
--[[
WIPDOC
]]
---@field id string
--[[
WIPDOC
]]
---@field title string
--[[
WIPDOC
]]
---@field author string
--[[
WIPDOC
]]
---@field path core.Path

-- ---------------------------- core.* functions ---------------------------- --

--[[
Unofficial: Path is the root directory of the game, useful if you are looking for it
]]
---@nodiscard
---@return core.GameInfo
function core.get_game_info() end