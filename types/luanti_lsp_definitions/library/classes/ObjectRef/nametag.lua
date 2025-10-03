---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- ---------------------------- NametagAttributes --------------------------- --

--[[
WIPDOC
]]
---@class core.NametagAttributes.get
--[[
WIPDOC
]]
---@field text string
--[[
WIPDOC
]]
---@field color core.ColorSpec.tablefmt
--[[
WIPDOC
]]
---@field bgcolor core.ColorSpec.tablefmt

--[[
WIPDOC
]]
---@class core.NametagAttributes.set
--[[
WIPDOC
]]
---@field text string
--[[
WIPDOC
]]
---@field color core.ColorSpec
--[[
WIPDOC
]]
---@field bgcolor core.ColorSpec | false | nil


-- ---------------------------- ObjectRef methods --------------------------- --

---@class _.ObjectRef.__base
local ObjectRefBase

--[[
* `get_nametag_attributes()`
    * returns a table with the attributes of the nametag of an object
    * a nametag is a HUD text rendered above the object
    * ```lua
      {
          text = "",
          color = {a=0..255, r=0..255, g=0..255, b=0..255},
          bgcolor = {a=0..255, r=0..255, g=0..255, b=0..255},
      }
      ```
]]
---@nodiscard
---@return  core.NametagAttributes.get attributes
function ObjectRefBase:get_nametag_attributes() end

--[[
* `set_nametag_attributes(attributes)`
    * sets the attributes of the nametag of an object
    * `attributes`:
      ```lua
      {
          text = "My Nametag",
          color = ColorSpec,
          -- ^ Text color
          bgcolor = ColorSpec or false,
          -- ^ Sets background color of nametag
          -- `false` will cause the background to be set automatically based on user settings
          -- Default: false
      }
      ```
]]
---@param attributes core.NametagAttributes.set
function ObjectRefBase:set_nametag_attributes(attributes) end