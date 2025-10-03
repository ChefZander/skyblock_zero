---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Formspec functions

--[[
* `core.show_formspec(playername, formname, formspec)`
    * `playername`: name of player to show formspec
    * `formname`: name passed to `on_player_receive_fields` callbacks.
        * It should follow the `"modname:<whatever>"` naming convention.
        * If empty: Shows a custom, temporary inventory formspec.
            * An inventory formspec shown this way will also be updated if
              `ObjectRef:set_inventory_formspec` is called.
            * Use `ObjectRef:set_inventory_formspec` to change the player's
              inventory formspec for future opens.
            * Supported if server AND client are both of version >= 5.13.0.
    * `formspec`: formspec to display
    * See also: `core.register_on_player_receive_fields`
]]
---@param playername string
---@param formname string
---@param formspec core.Formspec
function core.show_formspec(playername, formname, formspec) end

--[[
* `core.close_formspec(playername, formname)`
    * `playername`: name of player to close formspec
    * `formname`: has to exactly match the one given in `show_formspec`, or the
      formspec will not close.
    * calling `show_formspec(playername, formname, "")` is equal to this
      expression.
    * to close a formspec regardless of the formname, call
      `core.close_formspec(playername, "")`.
      **USE THIS ONLY WHEN ABSOLUTELY NECESSARY!**
]]
---@param playername string
---@param formname string
function core.close_formspec(playername, formname) end

--[[
* `core.hypertext_escape(string)`: returns a string
    * escapes the characters "\", "<", and ">" to show text in a hypertext element.
    * not safe for use with tag attributes.
    * this function does not do formspec escaping, you will likely need to do
      `core.formspec_escape(core.hypertext_escape(string))` if the hypertext is
      not already being formspec escaped.
]]
---@nodiscard
---@param string string
---@return string
function core.hypertext_escape(string) end

--[[
WIPDOC
]]
---@class core.ExplodeEvent.table
--[[
WIPDOC
]]
---@field type "INV"|"CHG"|"DCL"
--[[
WIPDOC
]]
---@field row integer
--[[
WIPDOC
]]
---@field column integer

--[[
* `core.explode_table_event(string)`: returns a table
    * returns e.g. `{type="CHG", row=1, column=2}`
    * `type` is one of:
        * `"INV"`: no row selected
        * `"CHG"`: selected
        * `"DCL"`: double-click
]]
---@nodiscard
---@param string string
---@return core.ExplodeEvent.table
function core.explode_table_event(string) end

--[[
WIPDOC
]]
---@class core.ExplodeEvent.textlist
--[[
WIPDOC
]]
---@field type "INV"|"CHG"|"DCL"
--[[
WIPDOC
]]
---@field index integer

--[[
* `core.explode_textlist_event(string)`: returns a table
    * returns e.g. `{type="CHG", index=1}`
    * `type` is one of:
        * `"INV"`: no row selected
        * `"CHG"`: selected
        * `"DCL"`: double-click
]]
---@nodiscard
---@param string string
---@return core.ExplodeEvent.textlist
function core.explode_textlist_event(string) end

--[[
WIPDOC
]]
---@class core.ExplodeEvent.scrollbar
--[[
WIPDOC
]]
---@field type "INV"|"CHG"|"VAL"
--[[
WIPDOC
]]
---@field value integer

--[[
* `core.explode_scrollbar_event(string)`: returns a table
    * returns e.g. `{type="CHG", value=500}`
    * `type` is one of:
        * `"INV"`: something failed
        * `"CHG"`: has been changed
        * `"VAL"`: not changed
]]
---@nodiscard
---@param string string
---@return core.ExplodeEvent.scrollbar
function core.explode_scrollbar_event(string) end

--[[
* `core.show_death_screen(player, reason)`
    * Called when the death screen should be shown.
    * `player` is an ObjectRef, `reason` is a PlayerHPChangeReason table or nil.
    * By default, this shows a simple formspec with the option to respawn.
      Respawning is done via `ObjectRef:respawn`.
    * You can override this to show a custom death screen.
    * For general death handling, use `core.register_on_dieplayer` instead.
]]
---@param player core.PlayerRef
---@param reason core.PlayerHPChangeReason?
function core.show_death_screen(player, reason) end