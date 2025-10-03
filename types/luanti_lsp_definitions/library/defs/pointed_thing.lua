---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Representations of simple things

-- -------------------------- PointedThing.nothing -------------------------- --

--[[
WIPDOC
]]
---@class core.PointedThing.nothing
--[[
WIPDOC
]]
---@field type "nothing"

-- ---------------------------- PointedThing.node --------------------------- --

--[[
WIPDOC
]]
---@class core.PointedThing.node
--[[
WIPDOC
]]
---@field type "node"
--[[
WIPDOC
]]
---@field under ivector
--[[
WIPDOC
]]
---@field above ivector

-- --------------------------- PointedThing.object -------------------------- --

--[[
WIPDOC
]]
---@class core.PointedThing.object
--[[
WIPDOC
]]
---@field type "object"
--[[
WIPDOC
]]
---@field ref core.ObjectRef

--[[
WIPDOC
]]
---@alias core.PointedThing
--- | core.PointedThing.nothing
--- | core.PointedThing.node
--- | core.PointedThing.object

-- -------------------------- PointedThing.raycast -------------------------- --

---@class _.PointedThing.raycast.__partial
--[[
Only raycast supports this
* `pointed_thing.intersection_point`: The absolute world coordinates of the
  point on the selection box which is pointed at. May be in the selection box
  if the pointer is in the box too.
]]
---@field intersection_point vector
--[[
Only raycast supports this
* `pointed_thing.box_id`: The ID of the pointed selection box (counting starts
  from 1).
]]
---@field box_id integer
--[[
Only raycast supports this
* `pointed_thing.intersection_normal`: Unit vector, points outwards of the
  selected selection box. This specifies which face is pointed at.
  Is a null vector `vector.zero()` when the pointer is inside the selection box.
  For entities with rotated selection boxes, this will be rotated properly
  by the entity's rotation - it will always be in absolute world space.
]]
---@field intersection_normal vector

--[[
WIPDOC
]]
---@class core.PointedThing.raycast.node : core.PointedThing.node, _.PointedThing.raycast.__partial

--[[
WIPDOC
]]
---@class core.PointedThing.raycast.object : core.PointedThing.object, _.PointedThing.raycast.__partial

--[[
WIPDOC
]]
---@alias core.PointedThing.raycast.all
--- | core.PointedThing.raycast.node
--- | core.PointedThing.raycast.object