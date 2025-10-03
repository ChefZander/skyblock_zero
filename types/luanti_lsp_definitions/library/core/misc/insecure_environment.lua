---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Misc.

--[[
WIPDOC
]]
---@class corelib.insecure
local insecure = {}

-- TODO inspect what's inside an insecure environment
-- TODO research what's different in an insecure environment

--[[
* `core.request_insecure_environment()`: returns an environment containing
  insecure functions if the calling mod has been listed as trusted in the
  `secure.trusted_mods` setting or security is disabled, otherwise returns
  `nil`.
    * Only works at init time and must be called from the mod's main scope
      (ie: the init.lua of the mod, not from another Lua file or within a function).
    * **DO NOT ALLOW ANY OTHER MODS TO ACCESS THE RETURNED ENVIRONMENT, STORE
      IT IN A LOCAL VARIABLE!**
]]
---@nodiscard
---@return corelib.insecure?
function core.request_insecure_environment() end