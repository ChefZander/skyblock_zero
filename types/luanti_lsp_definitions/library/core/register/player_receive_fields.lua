---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Global callback registration functions

--[[
WIPDOC
]]
---@class core.FormspecFields : {[string]:string}
--[[
WIPDOC
]]
---@field quit "true"?
--[[
WIPDOC
]]
---@field try_quit "true"?
--[[
WIPDOC
]]
---@field key_enter "true"?

--[[
WIPDOC
]]
---@alias core.fn.on_player_receive_fields fun(player:core.PlayerRef, formname:string, fields:core.FormspecFields):boolean?

--[[
* `core.register_on_player_receive_fields(function(player, formname, fields))`
* Called when the server received input from `player`.
  Specifically, this is called on any of the
  following events:
      * a button was pressed,
      * Enter was pressed while the focus was on a text field
      * a checkbox was toggled,
      * something was selected in a dropdown list,
      * a different tab was selected,
      * selection was changed in a textlist or table,
      * an entry was double-clicked in a textlist or table,
      * a scrollbar was moved, or
      * the form was actively closed by the player.
* `formname` is the name passed to `core.show_formspec`.
  Special case: The empty string refers to the player inventory
  (the formspec set by the `set_inventory_formspec` player method).
* Fields are sent for formspec elements which define a field. `fields`
  is a table containing each formspecs element value (as string), with
  the `name` parameter as index for each. The value depends on the
  formspec element type:
    * `animated_image`: Returns the index of the current frame.
    * `button` and variants: If pressed, contains the user-facing button
      text as value. If not pressed, is `nil`
    * `field`, `textarea` and variants: Text in the field
    * `dropdown`: Either the index or value, depending on the `index event`
      dropdown argument.
    * `tabheader`: Tab index, starting with `"1"` (only if tab changed)
    * `checkbox`: `"true"` if checked, `"false"` if unchecked
    * `textlist`: See `core.explode_textlist_event`
    * `table`: See `core.explode_table_event`
    * `scrollbar`: See `core.explode_scrollbar_event`
    * Special case: `["quit"]="true"` is sent when the user actively
      closed the form by mouse click, keypress or through a `button_exit[]`
      element.
    * Special case: `["try_quit"]="true"` is sent when the user tries to
      close the formspec, but the formspec used `allow_close[false]`.
    * Special case: `["key_enter"]="true"` is sent when the user pressed
      the Enter key and the focus was either nowhere (causing the formspec
      to be closed) or on a button. If the focus was on a text field,
      additionally, the index `key_enter_field` contains the name of the
      text field. See also: `field_close_on_enter`.
* Newest functions are called first
* If function returns `true`, remaining functions are not called
]]
---@param f core.fn.on_player_receive_fields
function core.register_on_player_receive_fields(f) end