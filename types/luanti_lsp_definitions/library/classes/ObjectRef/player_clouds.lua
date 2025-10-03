---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`


-- -------------------------- PlayerCloudParameters ------------------------- --

--[[
WIPDOC
]]
---@class core.PlayerCloudParameters.set
--[[
WIPDOC
]]
---@field density number?
--[[
WIPDOC
]]
---@field color core.ColorSpec?
--[[
WIPDOC
]]
---@field ambient core.ColorSpec?
--[[
WIPDOC
]]
---@field height integer?
--[[
WIPDOC
]]
---@field thickness integer?
--[[
WIPDOC
]]
---@field speed vec2.xy?
--[[
WIPDOC
]]
---@field shadow core.ColorSpec?

--[[
WIPDOC
]]
---@class core.PlayerCloudParameters.get
--[[
WIPDOC
]]
---@field density number
--[[
WIPDOC
]]
---@field color core.ColorSpec
--[[
WIPDOC
]]
---@field ambient core.ColorSpec
--[[
WIPDOC
]]
---@field height integer
--[[
WIPDOC
]]
---@field thickness integer
--[[
WIPDOC
]]
---@field speed vec2.xy
--[[
WIPDOC
]]
---@field shadow core.ColorSpec

-- ---------------------------- PlayerRef methods --------------------------- --

---@class core.PlayerRef
local PlayerRef


--[[
* `set_clouds(cloud_parameters)`: set cloud parameters
    * Passing no arguments resets clouds to their default values.
    * `cloud_parameters` is a table with the following optional fields:
        * `density`: from `0` (no clouds) to `1` (full clouds) (default `0.4`)
        * `color`: basic cloud color with alpha channel, ColorSpec
          (default `#fff0f0e5`).
        * `ambient`: cloud color lower bound, use for a "glow at night" effect.
          ColorSpec (alpha ignored, default `#000000`)
        * `height`: cloud height, i.e. y of cloud base (default per conf,
          usually `120`)
        * `thickness`: cloud thickness in nodes (default `16`).
          if set to zero the clouds are rendered flat.
        * `speed`: 2D cloud speed + direction in nodes per second
          (default `{x=0, z=-2}`).
        * `shadow`: shadow color, applied to the base of the cloud
          (default `#cccccc`).
]]
---@param cloud_parameters core.PlayerCloudParameters.set
function PlayerRef:set_clouds(cloud_parameters) end

--[[
* `get_clouds()`: returns a table with the current cloud parameters as in
  `set_clouds`.
]]
---@nodiscard
---@return core.PlayerCloudParameters.get cloud_parameters
function PlayerRef:get_clouds() end