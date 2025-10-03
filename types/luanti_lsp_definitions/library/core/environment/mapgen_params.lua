---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Environment access

-- ------------------------------ MapgenParams ------------------------------ --

--[[
WIPDOC
]]
---@class core.MapgenParams
--[[
WIPDOC
]]
---@field mgname core.LuantiSettings.enums.mg_name
--[[
WIPDOC
]]
---@field seed integer
--[[
WIPDOC
]]
---@field chunksize integer
--[[
WIPDOC
]]
---@field water_level integer
--[[
WIPDOC
]]
---@field flags core.LuantiSettings.flags.mg_flags|core.LuantiSettings.flags

-- ---------------------------- core.* functions ---------------------------- --

--[[
* `core.get_mapgen_params()`
    * Deprecated: use `core.get_mapgen_setting(name)` instead.
    * Returns a table containing:
        * `mgname`
        * `seed`
        * `chunksize`
        * `water_level`
        * `flags`
]]
---@deprecated
---@nodiscard
---@return core.MapgenParams
function core.get_mapgen_params() end

--[[
* `core.set_mapgen_params(MapgenParams)`
    * Deprecated: use `core.set_mapgen_setting(name, value, override)`
      instead.
    * Set map generation parameters.
    * Function cannot be called after the registration period.
    * Takes a table as an argument with the fields:
        * `mgname`
        * `seed`
        * `chunksize`
        * `water_level`
        * `flags`
    * Leave field unset to leave that parameter unchanged.
    * `flags` contains a comma-delimited string of flags to set, or if the
      prefix `"no"` is attached, clears instead.
    * `flags` is in the same format and has the same options as `mg_flags` in
      `minetest.conf`.
]]
---@deprecated
---@param MapgenParams core.MapgenParams
function core.set_mapgen_params(MapgenParams) end