---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Class reference > `ObjectRef`

-- ------------------------------ PlayerControl ----------------------------- --

--[[
WIPDOC
]]
---@class core.PlayerControl
--[[
WIPDOC
]]
---@field  up boolean
--[[
WIPDOC
]]
---@field  down boolean
--[[
WIPDOC
]]
---@field  left boolean
--[[
WIPDOC
]]
---@field  right boolean
--[[
WIPDOC
]]
---@field  jump boolean
--[[
WIPDOC
]]
---@field  aux1 boolean
--[[
WIPDOC
]]
---@field  sneak boolean
--[[
WIPDOC
]]
---@field  dig boolean
--[[
WIPDOC
]]
---@field  place boolean
--[[
WIPDOC
]]
---@field  LMB boolean
--[[
WIPDOC
]]
---@field  RMB boolean
--[[
WIPDOC
]]
---@field  zoom boolean
--[[
WIPDOC
]]
---@field  movement_x number
--[[
WIPDOC
]]
---@field  movement_y number

-- ---------------------------- PlayerRef methods --------------------------- --

---@class core.PlayerRef
local PlayerRef

--[[
* `get_player_control()`: returns table with player input
    * The table contains the following boolean fields representing the pressed
      keys: `up`, `down`, `left`, `right`, `jump`, `aux1`, `sneak`, `dig`,
      `place`, `LMB`, `RMB` and `zoom`.
    * The fields `LMB` and `RMB` are equal to `dig` and `place` respectively,
      and exist only to preserve backwards compatibility.
    * The table also contains the fields `movement_x` and `movement_y`.
        * They represent the movement of the player. Values are numbers in the
          range [-1.0,+1.0].
        * They take both keyboard and joystick input into account.
        * You should prefer them over `up`, `down`, `left` and `right` to
          support different input methods correctly.
    * Returns an empty table `{}` if the object is not a player.
]]
---@nodiscard
---@return core.PlayerControl
function PlayerRef:get_player_control() end

--[[
* `get_player_control_bits()`: returns integer with bit packed player pressed
  keys.
    * Bits:
        * 0 - up
        * 1 - down
        * 2 - left
        * 3 - right
        * 4 - jump
        * 5 - aux1
        * 6 - sneak
        * 7 - dig
        * 8 - place
        * 9 - zoom
    * Returns `0` (no bits set) if the object is not a player.
]]
---@nodiscard
---@return integer
function PlayerRef:get_player_control_bits() end