---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Nodes > Node paramtypes
-- luanti/doc/lua_api.md: Definition tables > Node definition

-- --------------------------- NodeDef.paramtype2 --------------------------- --

--[[
WIPDOC
]]
---@alias core.NodeDef.paramtype
--- | "light"
--- | "none"

--[[
WIPDOC
]]
---@alias core.NodeDef.paramtype2.color
--- | "color"
--- | "colorfacedir"
--- | "color4dir"
--- | "colorwallmounted"
--- | "colordegrotate"

--[[
WIPDOC
]]
---@alias core.NodeDef.paramtype2
--- | "flowingliquid"
--- | "wallmounted"
--- | "facedir"
--- | "4dir"
--- | "leveled"
--- | "degrotate"
--- | "meshoptions"
--- | "color"
--- | "colorfacedir"
--- | "color4dir"
--- | "colorwallmounted"
--- | "glasslikeliquidlevel"
--- | "colordegrotate"
--- | "none"

-- ----------------------------- NodeDef fields ----------------------------- --

---@class core.NodeDef
--[[
paramtype = "none",  -- See "Nodes"
* `paramtype = "light"`
    * The value stores light with and without sun in its lower and upper 4 bits
      respectively.
    * Required by a light source node to enable spreading its light.
    * Required by the following drawtypes as they determine their visual
      brightness from their internal light value:
        * torchlike
        * signlike
        * firelike
        * fencelike
        * raillike
        * nodebox
        * mesh
        * plantlike
        * plantlike_rooted
* `paramtype = "none"`
    * `param1` will not be used by the engine and can be used to store
      an arbitrary value
]]
---@field  paramtype core.NodeDef.paramtype?
--[[
WIPDOC
]]
---@field paramtype2 core.NodeDef.paramtype2?
