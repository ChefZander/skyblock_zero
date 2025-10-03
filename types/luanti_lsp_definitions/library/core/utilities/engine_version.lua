---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Utilities

-- ------------------------------ EngineVersion ----------------------------- --

--[[
Use this for informational purposes only. The information in the returned
  table does not represent the capabilities of the engine, nor is it
  reliable or verifiable. Compatible forks will have a different name and
  version entirely. To check for the presence of engine features, test
  whether the functions exported by the wanted features exist. For example:
  `if core.check_for_falling then ... end`.
]]
---@class core.EngineVersion
--[[
Name of the project, eg, "Luanti"
]]
---@field project  "Luanti"|string
--[[
Simple version, eg, "1.2.3-dev"
]]
---@field string  string
--[[
The minimum supported protocol version
]]
---@field proto_min  core.Protocol
--[[
The maximum supported protocol version
]]
---@field proto_max  core.Protocol
--[[
Full git version (only set if available), eg, "1.2.3-dev-01234567-dirty".
]]
---@field hash  string
--[[
Boolean value indicating whether it's a development build
]]
---@field is_dev  boolean

-- ---------------------------- core.* functions ---------------------------- --

--[[
WIPDOC
]]
---@nodiscard
---@return core.EngineVersion
function core.get_version() end