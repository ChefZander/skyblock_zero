---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Mapgen objects

-- ----------------------------- GenNotify.flags ---------------------------- --

--[[
WIPDOC
]]
---@class core.GenNotify.flags.tablefmt : {[string]:boolean?}
--[[
WIPDOC
]]
---@field dungeon boolean?
--[[
WIPDOC
]]
---@field nodungeon boolean?
--[[
WIPDOC
]]
---@field temple boolean?
--[[
WIPDOC
]]
---@field notemple boolean?
--[[
WIPDOC
]]
---@field cave_begin boolean?
--[[
WIPDOC
]]
---@field nocave_begin boolean?
--[[
WIPDOC
]]
---@field cave_end boolean?
--[[
WIPDOC
]]
---@field nocave_end boolean?
--[[
WIPDOC
]]
---@field large_cave_begin boolean?
--[[
WIPDOC
]]
---@field nolarge_cave_begin boolean?
--[[
WIPDOC
]]
---@field large_cave_end boolean?
--[[
WIPDOC
]]
---@field nolarge_cave_end boolean?
--[[
WIPDOC
]]
---@field custom boolean?
--[[
WIPDOC
]]
---@field nocustom boolean?
--[[
WIPDOC
]]
---@field decoration boolean?
--[[
WIPDOC
]]
---@field nodecoration boolean?

--[[
WIPDOC
]]
---@alias core.GenNotify.flags.stringfmt string

--[[
WIPDOC
]]
---@alias core.GenNotify.flags
--- | core.GenNotify.flags.tablefmt
--- | core.GenNotify.flags.stringfmt

-- -------------------------------- GenNotify ------------------------------- --

--[[
WIPDOC
]]
---@alias core.GenNotify.key.decoration string

--[[
Returns a table. You need to announce your interest in a specific
field by calling `core.set_gen_notify()` *before* map generation happens.

* key = string: generation notification type
* value = list of positions (usually)
   * Exceptions are denoted in the listing below.

Available generation notification types:

* `dungeon`: bottom center position of dungeon rooms
* `temple`: as above but for desert temples (mgv6 only)
* `cave_begin`
* `cave_end`
* `large_cave_begin`
* `large_cave_end`
* `custom`: data originating from [Mapgen environment](#mapgen-environment) (Lua API)
   * This is a table.
   * key = user-defined ID (string)
   * value = arbitrary Lua value
* `decoration#id`: decorations
  * (see below)

Decorations have a key in the format of `"decoration#id"`, where `id` is the
numeric unique decoration ID as returned by `core.get_decoration_id()`.
For example, `decoration#123`.

The returned positions are the ground surface 'place_on' nodes,
not the decorations themselves. A 'simple' type decoration is often 1
node above the returned position and possibly displaced by 'place_offset_y'.
]]
---@class core.GenNotify
--[[
WIPDOC
]]
---@field dungeon ivec?
--[[
WIPDOC
]]
---@field temple ivec?
--[[
WIPDOC
]]
---@field cave_begin ivec?
--[[
WIPDOC
]]
---@field cave_end ivec?
--[[
WIPDOC
]]
---@field large_cave_begin ivec?
--[[
WIPDOC
]]
---@field large_cave_end ivec?
--[[
WIPDOC
]]
---@field custom table<string, any>
--[[
WIPDOC
]]
---@field [core.GenNotify.key.decoration] ivec?