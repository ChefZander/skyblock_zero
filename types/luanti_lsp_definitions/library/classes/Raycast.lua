---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Representations of simple things
-- luanti/doc/lua_api.md: 'core' namespace reference > Environment access
-- luanti/doc/lua_api.md: Class reference > `Raycast`

-- ------------------------------- constructor ------------------------------ --

--[[
* `core.raycast(pos1, pos2, objects, liquids, pointabilities)`: returns `Raycast`
    * Creates a `Raycast` object.
    * `pos1`: start of the ray
    * `pos2`: end of the ray
    * `objects`: if false, only nodes will be returned. Default is `true`.
    * `liquids`: if false, liquid nodes (`liquidtype ~= "none"`) won't be
                 returned. Default is `false`.
    * `pointabilities`: Allows overriding the `pointable` property of
      nodes and objects. Uses the same format as the `pointabilities` property
      of item definitions. Default is `nil`.
]]
---@nodiscard
---@param pos1 vector
---@param pos2 vector
---@param objects false
---@param liquids boolean?
---@param pointabilities core.ItemDef.pointabilities?
---@return core.Raycast.nodes
function Raycast(pos1, pos2, objects, liquids, pointabilities) end

--[[
* `core.raycast(pos1, pos2, objects, liquids, pointabilities)`: returns `Raycast`
    * Creates a `Raycast` object.
    * `pos1`: start of the ray
    * `pos2`: end of the ray
    * `objects`: if false, only nodes will be returned. Default is `true`.
    * `liquids`: if false, liquid nodes (`liquidtype ~= "none"`) won't be
                 returned. Default is `false`.
    * `pointabilities`: Allows overriding the `pointable` property of
      nodes and objects. Uses the same format as the `pointabilities` property
      of item definitions. Default is `nil`.
]]
---@nodiscard
---@param pos1 vector
---@param pos2 vector
---@param objects true?
---@param liquids false?
---@param pointabilities core.ItemDef.pointabilities?
---@return core.Raycast.objects
function Raycast(pos1, pos2, objects, liquids, pointabilities) end

--[[
* `core.raycast(pos1, pos2, objects, liquids, pointabilities)`: returns `Raycast`
    * Creates a `Raycast` object.
    * `pos1`: start of the ray
    * `pos2`: end of the ray
    * `objects`: if false, only nodes will be returned. Default is `true`.
    * `liquids`: if false, liquid nodes (`liquidtype ~= "none"`) won't be
                 returned. Default is `false`.
    * `pointabilities`: Allows overriding the `pointable` property of
      nodes and objects. Uses the same format as the `pointabilities` property
      of item definitions. Default is `nil`.
]]
---@nodiscard
---@param pos1 vector
---@param pos2 vector
---@param objects true?
---@param liquids true
---@param pointabilities core.ItemDef.pointabilities?
---@return core.Raycast.all
function Raycast(pos1, pos2, objects, liquids, pointabilities) end

--[[
* `core.raycast(pos1, pos2, objects, liquids, pointabilities)`: returns `Raycast`
    * Creates a `Raycast` object.
    * `pos1`: start of the ray
    * `pos2`: end of the ray
    * `objects`: if false, only nodes will be returned. Default is `true`.
    * `liquids`: if false, liquid nodes (`liquidtype ~= "none"`) won't be
                 returned. Default is `false`.
    * `pointabilities`: Allows overriding the `pointable` property of
      nodes and objects. Uses the same format as the `pointabilities` property
      of item definitions. Default is `nil`.
]]
---@nodiscard
---@param pos1 vector
---@param pos2 vector
---@param objects false
---@param liquids boolean?
---@param pointabilities core.ItemDef.pointabilities?
---@return core.Raycast.nodes
function core.raycast(pos1, pos2, objects, liquids, pointabilities) end

--[[
* `core.raycast(pos1, pos2, objects, liquids, pointabilities)`: returns `Raycast`
    * Creates a `Raycast` object.
    * `pos1`: start of the ray
    * `pos2`: end of the ray
    * `objects`: if false, only nodes will be returned. Default is `true`.
    * `liquids`: if false, liquid nodes (`liquidtype ~= "none"`) won't be
                 returned. Default is `false`.
    * `pointabilities`: Allows overriding the `pointable` property of
      nodes and objects. Uses the same format as the `pointabilities` property
      of item definitions. Default is `nil`.
]]
---@nodiscard
---@param pos1 vector
---@param pos2 vector
---@param objects true?
---@param liquids false?
---@param pointabilities core.ItemDef.pointabilities?
---@return core.Raycast.objects
function core.raycast(pos1, pos2, objects, liquids, pointabilities) end

--[[
* `core.raycast(pos1, pos2, objects, liquids, pointabilities)`: returns `Raycast`
    * Creates a `Raycast` object.
    * `pos1`: start of the ray
    * `pos2`: end of the ray
    * `objects`: if false, only nodes will be returned. Default is `true`.
    * `liquids`: if false, liquid nodes (`liquidtype ~= "none"`) won't be
                 returned. Default is `false`.
    * `pointabilities`: Allows overriding the `pointable` property of
      nodes and objects. Uses the same format as the `pointabilities` property
      of item definitions. Default is `nil`.
]]
---@nodiscard
---@param pos1 vector
---@param pos2 vector
---@param objects true?
---@param liquids true
---@param pointabilities core.ItemDef.pointabilities?
---@return core.Raycast.all
function core.raycast(pos1, pos2, objects, liquids, pointabilities) end

-- --------------------------------- Raycast -------------------------------- --

--[[
WIPDOC
]]
---@class core.Raycast.nodes
---@operator call(): core.PointedThing.raycast.node
local RaycastNodes = {}

--[[
WIPDOC
]]
---@nodiscard
---@return core.PointedThing.raycast.node?
function RaycastNodes:next() end

--[[
WIPDOC
]]
---@class core.Raycast.objects
---@operator call(): core.PointedThing.raycast.object
local RaycastObjects = {}

--[[
WIPDOC
]]
---@nodiscard
---@return core.PointedThing.raycast.object?
function RaycastObjects:next() end

--[[
WIPDOC
]]
---@class core.Raycast.all
---@operator call(): core.PointedThing.raycast.all
local RaycastAll = {}

--[[
WIPDOC
]]
---@nodiscard
---@return core.PointedThing.raycast.all?
function RaycastAll:next() end