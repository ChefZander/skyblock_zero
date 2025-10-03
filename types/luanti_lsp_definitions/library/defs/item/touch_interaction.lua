---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > Item definition

-- ------------------------ ItemDef.touch_interaction ----------------------- --

---@alias core.ItemDef.touch_interaction.mode
--- | "long_dig_short_place"
--- | "short_dig_long_place"
--- | "user"

---@class core.ItemDef.touch_interaction.pointed_thing
--[[
WIPDOC
]]
---@field pointed_nothing core.ItemDef.touch_interaction.mode?
--[[
WIPDOC
]]
---@field pointed_node core.ItemDef.touch_interaction.mode?
--[[
WIPDOC
]]
---@field pointed_object core.ItemDef.touch_interaction.mode?

--[[
WIPDOC
]]
---@alias core.ItemDef.touch_interaction
--- | core.ItemDef.touch_interaction.mode
--- | core.ItemDef.touch_interaction.pointed_thing

-- ----------------------------- ItemDef fields ----------------------------- --

---@class core.ItemDef
--[[
Only affects touchscreen clients.
Defines the meaning of short and long taps with the item in hand.
If specified as a table, the field to be used is selected according to
the current `pointed_thing`.
There are three possible TouchInteractionMode values:
* "long_dig_short_place" (long tap  = dig, short tap = place)
* "short_dig_long_place" (short tap = dig, long tap  = place)
* "user":
  * For `pointed_object`: Equivalent to "short_dig_long_place" if the
    client-side setting "touch_punch_gesture" is "short_tap" (the
    default value) and the item is able to punch (i.e. has no on_use
    callback defined).
    Equivalent to "long_dig_short_place" otherwise.
  * For `pointed_node` and `pointed_nothing`:
    Equivalent to "long_dig_short_place".
  * The behavior of "user" may change in the future.
The default value is "user".
]]
---@field touch_interaction core.ItemDef.touch_interaction?
