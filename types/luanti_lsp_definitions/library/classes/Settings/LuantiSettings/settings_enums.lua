---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `Settings`
-- builtin/settingtypes.txt
-- minetest.conf.example

---@class core.LuantiSettings
local LuantiSettings = {}

-- -------------------------------- Advanced -------------------------------- --

---@nodiscard
---@param key "debug_log_level"
---@return core.LuantiSettings.enums.debug_log_level? value
function LuantiSettings:get(key) end

---@param key "debug_log_level"
---@param value core.LuantiSettings.enums.debug_log_level?
function LuantiSettings:set(key, value) end

---@nodiscard
---@param key "deprecated_lua_api_handling"
---@return core.LuantiSettings.enums.deprecated_lua_api_handling? value
function LuantiSettings:get(key) end

---@param key "deprecated_lua_api_handling"
---@param value core.LuantiSettings.enums.deprecated_lua_api_handling?
function LuantiSettings:set(key, value) end

---@nodiscard
---@param key "profiler.default_report_format"
---@return core.LuantiSettings.enums.profiler.default_report_format? value
function LuantiSettings:get(key) end

---@nodiscard
---@param key "profiler.default_report_format"
---@param value core.LuantiSettings.enums.profiler.default_report_format?
function LuantiSettings:set(key, value) end

---@nodiscard
---@param key "sqlite_synchronous"
---@return core.LuantiSettings.enums.sqlite_synchronous? value
function LuantiSettings:get(key) end

---@nodiscard
---@param key "sqlite_synchronous"
---@param value core.LuantiSettings.enums.sqlite_synchronous?
function LuantiSettings:set(key, value) end

-- --------------------------------- Mapgen --------------------------------- --

---@nodiscard
---@param key "mg_name"
---@return core.LuantiSettings.enums.mg_name? value
function LuantiSettings:get(key) end

---@nodiscard
---@param key "mg_name"
---@param value core.LuantiSettings.enums.mg_name?
function LuantiSettings:set(key, value) end