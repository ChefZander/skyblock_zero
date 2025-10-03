---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Nodes > Node boxes

-- ------------------------------- NodeBox.box ------------------------------ --

--[[
WIPDOC
]]
---@class core.NodeBox.box.strict
--[[
WIPDOC
]]
---@field [1] number
--[[
WIPDOC
]]
---@field [2] number
--[[
WIPDOC
]]
---@field [3] number
--[[
WIPDOC
]]
---@field [4] number
--[[
WIPDOC
]]
---@field [5] number
--[[
WIPDOC
]]
---@field [6] number

--[[
WIPDOC
]]
---@alias core.NodeBox.box
--- | number[]
--- | core.NodeBox.box.strict

--[[
WIPDOC
]]
---@alias core.NodeBox.boxes
--- | core.NodeBox.box
--- | core.NodeBox.box[]

-- ----------------------------- NodeBox.regular ---------------------------- --

--[[
WIPDOC
]]
---@class core.NodeBox.regular
--[[
WIPDOC
]]
---@field type "regular"?


-- ------------------------------ NodeBox.fixed ----------------------------- --

--[[
WIPDOC
]]
---@class core.NodeBox.fixed
--[[
WIPDOC
]]
---@field type "fixed"|"leveled"
--[[
WIPDOC
]]
---@field fixed core.NodeBox.boxes

-- --------------------------- NodeBox.wallmounted -------------------------- --

--[[
WIPDOC
]]
---@class core.NodeBox.wallmounted
--[[
WIPDOC
]]
---@field type "wallmounted"
--[[
WIPDOC
]]
---@field wall_top core.NodeBox.box
--[[
WIPDOC
]]
---@field wall_bottom core.NodeBox.box
--[[
WIPDOC
]]
---@field wall_side core.NodeBox.box


-- ---------------------------- NodeBox.connected --------------------------- --

--[[
WIPDOC
]]
---@class core.NodeBox.connected
--[[
WIPDOC
]]
---@field type "connected"
--[[
WIPDOC
]]
---@field fixed core.NodeBox.boxes
--[[
WIPDOC
]]
---@field connect_top core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field connect_bottom core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field connect_front core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field connect_left core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field connect_back core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field connect_right core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field disconnected_top core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field disconnected_bottom core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field disconnected_front core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field disconnected_left core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field disconnected_back core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field disconnected_right core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field disconnected core.NodeBox.boxes?
--[[
WIPDOC
]]
---@field disconnected_sides core.NodeBox.boxes?


-- --------------------------------- NodeBox -------------------------------- --

--[[
WIPDOC
]]
---@alias core.NodeBox
--- | core.NodeBox.regular
--- | core.NodeBox.fixed
--- | core.NodeBox.wallmounted
--- | core.NodeBox.connected