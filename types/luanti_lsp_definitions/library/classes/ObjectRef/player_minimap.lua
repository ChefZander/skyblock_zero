---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- ---------------------------- PlayreMinimapMode --------------------------- --

--[[
WIPDOC
]]
---@alias core.PlayerMinimapMode.type
--- | "off"
--- | "surface"
--- | "radar"
--- | "texture"

--[[
WIPDOC
]]
---@class core.PlayerMinimapMode
--[[
WIPDOC
]]
---@field type core.PlayerMinimapMode.type
--[[
WIPDOC
]]
---@field label string?
--[[
WIPDOC
]]
---@field size integer
--[[
WIPDOC
]]
---@field texture core.Texture?
--[[
WIPDOC
]]
---@field scale integer?

-- ---------------------------- PlayerRef methods --------------------------- --

---@class core.PlayerRef
local PlayerRef

--[[
* `set_minimap_modes({mode, mode, ...}, selected_mode)`
    * Overrides the available minimap modes (and toggle order), and changes the
    selected mode.
    * `mode` is a table consisting of up to four fields:
        * `type`: Available type:
            * `off`: Minimap off
            * `surface`: Minimap in surface mode
            * `radar`: Minimap in radar mode
            * `texture`: Texture to be displayed instead of terrain map
              (texture is centered around 0,0 and can be scaled).
              Texture size is limited to 512 x 512 pixel.
        * `label`: Optional label to display on minimap mode toggle
          The translation must be handled within the mod.
        * `size`: Sidelength or diameter, in number of nodes, of the terrain
          displayed in minimap
        * `texture`: Only for texture type, name of the texture to display
        * `scale`: Only for texture type, scale of the texture map in nodes per
          pixel (for example a `scale` of 2 means each pixel represents a 2x2
          nodes square)
    * `selected_mode` is the mode index to be selected after modes have been changed
    (0 is the first mode).
]]
---@param modes core.PlayerMinimapMode[]
---@param selected_mode integer
function PlayerRef:set_minimap_modes(modes, selected_mode) end