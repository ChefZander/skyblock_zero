---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Environment access

--[[
WIPDOC
]]
---@class core.BiomeData
--[[
WIPDOC
]]
---@field biome core.BiomeID
--[[
WIPDOC
]]
---@field heat number
--[[
WIPDOC
]]
---@field humidity number

--[[
* `core.get_biome_data(pos)`
    * Returns a table containing:
        * `biome` the biome id of the biome at that position
        * `heat` the heat at the position
        * `humidity` the humidity at the position
    * Or returns `nil` on failure.
]]
---@nodiscard
---@param pos ivector
---@return core.BiomeData?
function core.get_biome_data(pos) end