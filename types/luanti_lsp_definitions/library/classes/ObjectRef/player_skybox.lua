---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- -------------------- PlayerSkyParameters.regular.color ------------------- --

--[[
WIPDOC
]]
---@class core.PlayerSkyParameters.regular.color.set
--[[
WIPDOC
]]
---@field day_sky core.ColorSpec?
--[[
WIPDOC
]]
---@field day_horizon core.ColorSpec?
--[[
WIPDOC
]]
---@field dawn_sky core.ColorSpec?
--[[
WIPDOC
]]
---@field dawn_horizon core.ColorSpec?
--[[
WIPDOC
]]
---@field night_sky core.ColorSpec?
--[[
WIPDOC
]]
---@field night_horizon core.ColorSpec?
--[[
WIPDOC
]]
---@field indoors core.ColorSpec?
--[[
WIPDOC
]]
---@field fog_sun_tint core.ColorSpec?
--[[
WIPDOC
]]
---@field fog_moon_tint core.ColorSpec?
--[[
WIPDOC
]]
---@field fog_tint_type "custom"|"default"?

--[[
WIPDOC
]]
---@class core.PlayerSkyParameters.regular.color.get
--[[
WIPDOC
]]
---@field day_sky core.ColorSpec
--[[
WIPDOC
]]
---@field day_horizon core.ColorSpec
--[[
WIPDOC
]]
---@field dawn_sky core.ColorSpec
--[[
WIPDOC
]]
---@field dawn_horizon core.ColorSpec
--[[
WIPDOC
]]
---@field night_sky core.ColorSpec
--[[
WIPDOC
]]
---@field night_horizon core.ColorSpec
--[[
WIPDOC
]]
---@field indoors core.ColorSpec
--[[
WIPDOC
]]
---@field fog_sun_tint core.ColorSpec
--[[
WIPDOC
]]
---@field fog_moon_tint core.ColorSpec
--[[
WIPDOC
]]
---@field fog_tint_type "custom"|"default"


-- ------------------------- PlayerSkyParameters.fog ------------------------ --

--[[
WIPDOC
]]
---@class core.PlayerSkyParameters.fog.set
--[[
WIPDOC
]]
---@field fog_distance integer?
--[[
WIPDOC
]]
---@field fog_start number?
--[[
WIPDOC
]]
---@field fog_color core.ColorSpec?

--[[
WIPDOC
]]
---@class core.PlayerSkyParameters.fog.get
--[[
WIPDOC
]]
---@field fog_distance integer
--[[
WIPDOC
]]
---@field fog_start number
--[[
WIPDOC
]]
---@field fog_color core.ColorSpec



-- ----------------------- PlayerSkyParameters.__base ----------------------- --

--[[
WIPDOC
]]
---@class _.PlayerSkyParameters.__base.set
--[[
WIPDOC
]]
---@field base_color core.ColorSpec?
--[[
WIPDOC
]]
---@field body_orbit_tilt number?
--[[
WIPDOC
]]
---@field textures {}?
--[[
WIPDOC
]]
---@field clouds boolean?
--[[
WIPDOC
]]
---@field fog core.PlayerSkyParameters.fog.set?

--[[
WIPDOC
]]
---@class _.PlayerSkyParameters.__base.get
--[[
WIPDOC
]]
---@field base_color core.ColorSpec
--[[
WIPDOC
]]
---@field body_orbit_tilt number
--[[
WIPDOC
]]
---@field textures {}
--[[
WIPDOC
]]
---@field clouds boolean
--[[
WIPDOC
]]
---@field fog core.PlayerSkyParameters.fog.get

-- ----------------------- PlayerSkyParameters.regular ---------------------- --

--[[
WIPDOC
]]
---@class core.PlayerSkyParameters.regular.set : _.PlayerSkyParameters.__base.set
--[[
WIPDOC
]]
---@field type "regular"
--[[
WIPDOC
]]
---@field sky_color core.PlayerSkyParameters.regular.color.set?

--[[
WIPDOC
]]
---@class core.PlayerSkyParameters.regular.get : _.PlayerSkyParameters.__base.get
--[[
WIPDOC
]]
---@field type "regular"
--[[
WIPDOC
]]
---@field sky_color core.PlayerSkyParameters.regular.color.get

-- ----------------------- PlayerSkyParameters.skybox ----------------------- --

--[[
WIPDOC
]]
---@class core.PlayerSkyParameters.skybox.textures.strict
--[[
WIPDOC
]]
---@field [1] core.Texture
--[[
WIPDOC
]]
---@field [2] core.Texture
--[[
WIPDOC
]]
---@field [3] core.Texture
--[[
WIPDOC
]]
---@field [4] core.Texture
--[[
WIPDOC
]]
---@field [5] core.Texture
--[[
WIPDOC
]]
---@field [6] core.Texture

--[[
WIPDOC
]]
---@alias core.PlayerSkyParameters.skybox.textures
--- | core.PlayerSkyParameters.skybox.textures.strict
--- | core.Texture[]

--[[
WIPDOC
]]
---@class core.PlayerSkyParameters.skybox.set : _.PlayerSkyParameters.__base.set
--[[
WIPDOC
]]
---@field type "skybox"
--[[
WIPDOC
]]
---@field textures core.PlayerSkyParameters.skybox.textures?

--[[
WIPDOC
]]
---@class core.PlayerSkyParameters.skybox.get : _.PlayerSkyParameters.__base.get
--[[
WIPDOC
]]
---@field type "skybox"
--[[
WIPDOC
]]
---@field textures core.PlayerSkyParameters.skybox.textures

-- ------------------------ PlayerSkyParameters.plain ----------------------- --

--[[
WIPDOC
]]
---@class core.PlayerSkyParameters.plain.set : _.PlayerSkyParameters.__base.set
--[[
WIPDOC
]]
---@field type "plain"

--[[
WIPDOC
]]
---@class core.PlayerSkyParameters.plain.get : _.PlayerSkyParameters.__base.get
--[[
WIPDOC
]]
---@field type "plain"


-- --------------------------- PlayerSkyParameters -------------------------- --

---@alias core.PlayerSkyParameters.set
--- | core.PlayerSkyParameters.regular.set
--- | core.PlayerSkyParameters.skybox.set
--- | core.PlayerSkyParameters.plain.set

---@alias core.PlayerSkyParameters.get
--- | core.PlayerSkyParameters.regular.get
--- | core.PlayerSkyParameters.skybox.get
--- | core.PlayerSkyParameters.plain.get

-- ---------------------------- PlayerRef methods --------------------------- --

---@class core.PlayerRef
local PlayerRef

--[[
WIPDOC
]]
---@param sky_parameters core.PlayerSkyParameters.set
function PlayerRef:set_sky(sky_parameters) end

--[[
* `get_sky(as_table)`:
    * `as_table`: boolean that determines whether the deprecated version of this
    function is being used.
        * `true` returns a table containing sky parameters as defined in `set_sky(sky_parameters)`.
        * Deprecated: `false` or `nil` returns base_color, type, table of textures,
        clouds.
]]
---@nodiscard
---@param as_table true
---@return core.PlayerSkyParameters.get sky_parameters
function PlayerRef:get_sky(as_table) end

--[[
WIPDOC
]]
---@deprecated
---@param base_color core.ColorSpec
---@param type "regular"|"skybox"|"plain"
---@param textures core.Texture[]
---@param clouds boolean?
function PlayerRef:set_sky(base_color, type, textures, clouds) end

--[[
* `get_sky(as_table)`:
    * `as_table`: boolean that determines whether the deprecated version of this
    function is being used.
        * `true` returns a table containing sky parameters as defined in `set_sky(sky_parameters)`.
        * Deprecated: `false` or `nil` returns base_color, type, table of textures,
        clouds.
]]
---@deprecated
---@nodiscard
---@return core.ColorSpec base_color, "regular"|"skybox"|"plain" type, core.Texture[] textures, boolean? clouds
function PlayerRef:get_sky(as_table) end

--[[
* `get_sky_color()`:
    * Deprecated: Use `get_sky(as_table)` instead.
    * returns a table with the `sky_color` parameters as in `set_sky`.
]]
---@deprecated
---@nodiscard
---@return core.PlayerSkyParameters.regular.color.get sky_color
function PlayerRef:get_sky_color() end