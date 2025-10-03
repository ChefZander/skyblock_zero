---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Helper functions

-- NOTE: helpers not under core.* are in library/helpers.lua

--[[
WIPDOC
]]
---@nodiscard
---@param str string
---@param limit integer
---@param as_table boolean?
---@return string
function core.wrap_text(str, limit, as_table) end

--[[
WIPDOC
]]
---@nodiscard
---@param pos vector
---@param decimal_places integer?
---@return string
function core.pos_to_string(pos, decimal_places) end

--[[
WIPDOC
]]
---@nodiscard
---@param string string
---@return vec
function core.string_to_pos(string) end

--[[
returns two positions
Converts a string representing an area box into two positions
X1, Y1, ... Z2 are coordinates
relative_to: Optional. If set to a position, each coordinate can use the tilde notation for relative positions
"~": Relative coordinate
"~<number>": Relative coordinate plus <number>
Example: core.string_to_area("(1,2,3) (~5,~-5,~)", {x=10,y=10,z=10}) returns {x=1,y=2,z=3}, {x=15,y=5,z=10}
]]
---@nodiscard
---@param str string (X1, Y1, Z1) (X2, Y2, Z2)
---@param relative_to vector?
---@return vec?, vec?
function core.string_to_area(str, relative_to) end

--[[
escapes the characters "[", "]", "", "," and ";", which cannot be used in formspecs.
]]
---@nodiscard
---@param string string
---@return string
function core.formspec_escape(string) end

--[[
WIPDOC
]]
---@nodiscard
---@param arg string|number|boolean
---@return boolean
function core.is_yes(arg) end

--[[
WIPDOC
]]
---@nodiscard
---@param arg number
---@return boolean
function core.is_nan(arg) end

--[[
returns time with microsecond precision. May not return wall time.
Unofficial note: I think you should use os.clock() for benchmarking instead
]]
---@nodiscard
---@return integer
function core.get_us_time() end

--[[ after table.* intermission ]]--

--[[
WIPDOC
]]
---@nodiscard
---@param placer core.ObjectRef
---@param pointed_thing core.PointedThing
---@return vec
function core.pointed_thing_to_face_pos(placer, pointed_thing) end

--[[
WIPDOC
]]
---@param uses integer
---@param initial_wear core.Tool.wear?
---@return core.Tool.wear
function core.get_tool_wear_after_use(uses, initial_wear) end

--[[ core.get_dig_params() split off into ./dig_params.lua ]]--

--[[ core.get_hit_params() split off into ./hit_params.lua ]]--