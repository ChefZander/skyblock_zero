---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- -------------------------- PlayerStarParameters -------------------------- --

--[[
WIPDOC
]]
---@class core.PlayerStarParameters.set
--[[
WIPDOC
]]
---@field visible boolean?
--[[
WIPDOC
]]
---@field day_opacity number?
--[[
WIPDOC
]]
---@field count integer?
--[[
WIPDOC
]]
---@field star_color core.ColorSpec?
--[[
WIPDOC
]]
---@field scale number?

--[[
WIPDOC
]]
---@class core.PlayerStarParameters.get
--[[
WIPDOC
]]
---@field visible boolean
--[[
WIPDOC
]]
---@field day_opacity number
--[[
WIPDOC
]]
---@field count integer
--[[
WIPDOC
]]
---@field star_color core.ColorSpec
--[[
WIPDOC
]]
---@field scale number

-- ---------------------------- PlayerRef methods --------------------------- --

---@class core.PlayerRef
local PlayerRef


--[[
* `set_stars(star_parameters)`:
    * Passing no arguments resets stars to their default values.
    * `star_parameters` is a table with the following optional fields:
        * `visible`: Boolean for whether the stars are visible.
            (default: `true`)
        * `day_opacity`: Float for maximum opacity of stars at day.
            No effect if `visible` is false.
            (default: 0.0; maximum: 1.0; minimum: 0.0)
        * `count`: Integer number to set the number of stars in
            the skybox. Only applies to `"skybox"` and `"regular"` sky types.
            (default: `1000`)
        * `star_color`: ColorSpec, sets the colors of the stars,
            alpha channel is used to set overall star brightness.
            (default: `#ebebff69`)
        * `scale`: Float controlling the overall size of the stars (default: `1`)
]]
---@param star_parameters core.PlayerStarParameters.set
function PlayerRef:set_stars(star_parameters) end

--[[
* `get_stars()`: returns a table with the current stars parameters as in
    `set_stars`.
]]
---@nodiscard
---@return core.PlayerStarParameters.get star_parameters
function PlayerRef:get_stars() end