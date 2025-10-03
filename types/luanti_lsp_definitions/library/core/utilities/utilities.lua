---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Utilities

-- ------------------------- engine and client info ------------------------- --

--[[
Returns currently loading mod's name WHEN LOADING A MOD
]]
---@nodiscard
---@return string
function core.get_current_modname() end

--[[
WIPDOC
]]
---@nodiscard
---@param modname string
---@return core.Path
function core.get_modpath(modname) end

--[[
WIPDOC
]]
---@return string[]
---@nodiscard
function core.get_modnames() end

--[[ core.get_game_info() split off into ./game_info.lua ]]--

--[[
WIPDOC
]]
---@nodiscard
---@return core.Path
function core.get_worldpath() end

--[[
WIPDOC
]]
---@nodiscard
---@return boolean
function core.is_singleplayer() end

--[[ core.features .. core.has_features() split off into ./features.lua  ]]--

--[[ core.get_player_information() split off into ./player_information.lua ]]--

--[[ core.protocol_versions.lua() split off into ./protocol_versions.lua ]]--

--[[ core.get_player_window_information() split off into ./player_information.lua ]]--

-- ------------------------------- filesystem ------------------------------- --

--[[
WIPDOC
]]
---@nodiscard
---@param path core.Path
---@return boolean success
function core.mkdir(path) end

--[[
WIPDOC
]]
---@nodiscard
---@param path core.Path
---@param recursive boolean?
---@return boolean success
function core.rmdir(path, recursive) end

--[[
WIPDOC
]]
---@nodiscard
---@param source core.Path
---@param destination core.Path
---@return boolean success
function core.cpdir(source, destination) end

--[[
WIPDOC
]]
---@nodiscard
---@param source core.Path
---@param destination core.Path
---@return boolean success
function core.mvdir(source, destination) end

--[[
* `core.get_dir_list(path, [is_dir])`: returns list of entry names
    * is_dir is one of:
        * nil: return all entries,
        * true: return only subdirectory names, or
        * false: return only file names.
]]
---@nodiscard
---@param path string
---@param is_dir nil|true|false
---@return core.Path[]
function core.get_dir_list(path, is_dir) end

--[[
* `core.safe_file_write(path, content)`: returns boolean indicating success
    * Replaces contents of file at path with new contents in a safe (atomic)
      way. Use this instead of below code when writing e.g. database files:
      `local f = io.open(path, "wb"); f:write(content); f:close()`
]]
---@nodiscard
---@param path core.Path
---@param content string
---@return boolean success
function core.safe_file_write(path, content) end

-- ----------------------------- engine version ----------------------------- --

--[[ core.get_version() split off into ./engine_version.lua ]]--

-- --------------------------------- hashing -------------------------------- --

--[[
WIPDOC
]]
---@nodiscard
---@param data string
---@param raw boolean? raw bytes instead of hex digits, default: false
---@return string
function core.sha1(data, raw) end

--[[
WIPDOC
]]
---@nodiscard
---@param data string
---@param raw boolean? raw bytes instead of hex digits, default: false
---@return string
function core.sha256(data, raw) end

-- --------------------------------- colors --------------------------------- --

--[[
Colorspec to hex basically
]]
---@nodiscard
---@param colorspec core.ColorSpec
---@return core.ColorString
function core.colorspec_to_colorstring(colorspec) end

--[[
Layout: RGBA
]]
---@nodiscard
---@return core.ColorSpec
---@param colorspec core.ColorSpec.numberfmt
function core.colorspec_to_bytes(colorspec) end

--[[
WIPDOC
]]
---@nodiscard
---@param colorspec core.ColorSpec
---@return core.ColorSpec.tablefmt
function core.colorspec_to_table(colorspec) end

-- ---------------------------------- misc ---------------------------------- --

--[[
WIPDOC
]]
---@param time_of_day string
---@return number
function core.time_to_day_night_ratio(time_of_day) end

--[[
Unofficial note: shhh.... but you can do this in `core.handle_async` instead, get like a really good Promise library
Unofficial note: shh... but you can also use it real-time and it's real cool
Unofficial note: you can do "[png:"..core.encode_base64(core.encode_png(...)) to have a png
* `core.encode_png(width, height, data, [compression])`: Encode a PNG
  image and return it in string form.
    * `width`: Width of the image
    * `height`: Height of the image
    * `data`: Image data, one of:
        * array table of ColorSpec, length must be width*height
        * string with raw RGBA pixels, length must be width*height*4
    * `compression`: Optional zlib compression level, number in range 0 to 9.
  The data is one-dimensional, starting in the upper left corner of the image
  and laid out in scanlines going from left to right, then top to bottom.
  You can use `colorspec_to_bytes` to generate raw RGBA values.
  Palettes are not supported at the moment.
  You may use this to procedurally generate textures during server init.
]]
---@nodiscard
---@param width integer
---@param height integer
---@param data string|core.ColorSpec[]
---@param compression integer?
---@return string
function core.encode_png(width, height, data, compression) end

--[[
* `core.urlencode(str)`: Encodes reserved URI characters by a
  percent sign followed by two hex digits. See
  [RFC 3986, section 2.3](https://datatracker.ietf.org/doc/html/rfc3986#section-2.3).
]]
---@nodiscard
---@param str string
---@return string
function core.urlencode(str) end