---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `Settings`
-- builtin/settingtypes.txt
-- minetest.conf.example

--[[
WIPDOC
]]
---@type core.LuantiSettings
core.settings = nil

--[[
NOTE: types in a .conf settings file
- int -> integer
- string -> string
- bool -> boolean
- float -> number
- enum -> string
- path -> string
- filepath -> string
- key -> string
- flags -> flag table
- noise_params_2d -> noiseparams
- noise_params_3d -> noiseparams
- v3f -> vec
]]

--[[
WIPDOC
]]
---@class core.LuantiSettings.flags : string

--[[
WIPDOC
]]
---@alias core.LuantiSettings.path string

-- --------------------------- LuantiSettings.keys -------------------------- --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.keys.boolean
--- | _.LuantiSettings.advanced.keys.boolean
--- | _.LuantiSettings.client_and_server.keys.boolean
--- | string

--[[
WIPDOC
]]
---@alias core.LuantiSettings.keys.noise_params.2d
--- | _.LuantiSettings.mapgen.keys.noise_params.2d
--- | string

--[[
WIPDOC
]]
---@alias core.LuantiSettings.keys.noise_params.3d
--- | _.LuantiSettings.mapgen.keys.noise_params.3d
--- | string

--[[
WIPDOC
]]
---@alias core.LuantiSettings.keys.vector
--- | _.LuantiSettings.mapgen.keys.vector
--- | string

--[[
WIPDOC
]]
---@alias core.LuantiSettings.keys
--- | _.LuantiSettings.advanced.keys
--- | _.LuantiSettings.client_and_server.keys
--- | _.LuantiSettings.mapgen.keys
--- | string

-- ------------------------- LuantiSettings.tablefmt ------------------------ --

--[[
WIPDOC
]]
---@class core.LuantiSettings.tablefmt : _.LuantiSettings.advanced.tablefmt, _.LuantiSettings.client_and_server.tablefmt, _.LuantiSettings.mapgen.tablefmt

-- ----------------------------- LuantiSettings ----------------------------- --

--[[
### Format

The settings have the format `key = value`. Example:

    foo = example text
    bar = """
    Multiline
    value
    """
]]
---@class core.LuantiSettings
local LuantiSettings = {}

--[[ LuantiSettings:get() split off into ./settings_enums.lua ]]--

--[[
* `get(key)`: returns a value
    * Returns `nil` if `key` is not found.
]]
---@nodiscard
---@param key core.LuantiSettings.keys
---@return string? value
function LuantiSettings:get(key) end

--[[
* `get_bool(key, [default])`: returns a boolean
    * `default` is the value returned if `key` is not found.
    * Returns `nil` if `key` is not found and `default` not specified.
]]
---@nodiscard
---@param key core.LuantiSettings.keys.boolean
---@return boolean? value
function LuantiSettings:get_bool(key) end

--[[
* `get_bool(key, [default])`: returns a boolean
    * `default` is the value returned if `key` is not found.
    * Returns `nil` if `key` is not found and `default` not specified.
]]
---@nodiscard
---@generic T
---@param key core.LuantiSettings.keys.boolean
---@param default T
---@return boolean|T value
function LuantiSettings:get_bool(key, default) end

--[[
* `get_np_group(key)`: returns a NoiseParams table
    * Returns `nil` if `key` is not found.
]]
---@nodiscard
---@param key core.LuantiSettings.keys.noise_params.2d
---@return core.NoiseParams.2d? value
function LuantiSettings:get_np_group(key) end

--[[
* `get_np_group(key)`: returns a NoiseParams table
    * Returns `nil` if `key` is not found.
]]
---@nodiscard
---@param key core.LuantiSettings.keys.noise_params.3d
---@return core.NoiseParams.3d? value
function LuantiSettings:get_np_group(key) end

--[[ LuantiSettings:get_flags() split off into ./settings_flags.lua ]]--

--[[
* `get_flags(key)`:
    * Returns `{flag = true/false, ...}` according to the set flags.
    * Is currently limited to mapgen flags `mg_flags` and mapgen-specific
      flags like `mgv5_spflags`.
    * Returns `nil` if `key` is not found.
]]
---@nodiscard
---@param key string
---@return table<string, boolean>? value
function LuantiSettings:get_flags(key) end

--[[
* `get_pos(key)`:
    * Returns a `vector`
    * Returns `nil` if no value is found or parsing failed.
]]
---@nodiscard
---@param key core.LuantiSettings.keys.vector
---@return vec? value
function LuantiSettings:get_pos(key) end

--[[ LuantiSettings:set() split off into ./settings_enums.lua ]]--

--[[
* `set(key, value)`
    * Setting names can't contain whitespace or any of `="{}#`.
    * Setting values can't contain the sequence `\n"""`.
    * Setting names starting with "secure." can't be set on the main settings
      object (`core.settings`).
]]
---@param key core.LuantiSettings.keys
---@param value string
function LuantiSettings:set(key, value) end

--[[
* `set_bool(key, value)`
    * See documentation for `set()` above.
]]
---@param key core.LuantiSettings.keys.boolean
---@param value boolean
function LuantiSettings:set_bool(key, value) end

--[[
* `set_np_group(key, value)`
    * `value` is a NoiseParams table.
    * Also, see documentation for `set()` above.
]]
---@param key core.LuantiSettings.keys.noise_params.2d
---@param value core.NoiseParams.2d
function LuantiSettings:set_np_group(key, value) end

--[[
* `set_np_group(key, value)`
    * `value` is a NoiseParams table.
    * Also, see documentation for `set()` above.
]]
---@param key core.LuantiSettings.keys.noise_params.3d
---@param value core.NoiseParams.3d
function LuantiSettings:set_np_group(key, value) end

--[[
* `set_pos(key, value)`
    * `value` is a `vector`.
    * Also, see documentation for `set()` above.
]]
---@param key core.LuantiSettings.keys.vector
---@param value vector
function LuantiSettings:set_pos(key, value) end

--[[
* `remove(key)`: returns a boolean (`true`) for success
]]
---@nodiscard
---@param key core.LuantiSettings.keys
---@return boolean
function LuantiSettings:remove(key) end

--[[
* `get_names()`: returns `{key1,...}`
]]
---@nodiscard
---@return core.LuantiSettings.keys[] keys
function LuantiSettings:get_names() end

--[[
* `has(key)`:
    * Returns a boolean indicating whether `key` exists.
    * In contrast to the various getter functions, `has()` doesn't consider
      any default values.
    * This means that on the main settings object (`core.settings`),
      `get(key)` might return a value even if `has(key)` returns `false`.
]]
---@nodiscard
---@param key core.LuantiSettings.keys
---@return boolean
function LuantiSettings:has(key) end

--[[
* `write()`: returns a boolean (`true` for success
    * Writes changes to file.
]]
---@nodiscard
---@return boolean
function LuantiSettings:write() end

--[[
* `to_table()`: returns `{[key1]=value1,...}`
]]
---@nodiscard
---@return core.LuantiSettings.tablefmt
function LuantiSettings:to_table() end
