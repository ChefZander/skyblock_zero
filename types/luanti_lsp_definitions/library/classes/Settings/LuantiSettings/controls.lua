---@meta _
-- DRAFT 1 DONE
-- builtin/settingtypes.txt
-- minetest.conf.example

-- NOTE: key type is not a type mods and games will have to deal with
---@class _.LuantiSettings.key

-- Section context mapping:
-- * [Controls]: [client]

-- -------------------------- [Controls] [*General] ------------------------- --

---@class _.LuantiSettings.controls.general
--[[
#    Smooths rotation of camera, also called look or mouse smoothing. 0 to disable.
[client]
(Camera smoothing) 0.0 0.0 0.99
]]
---@field camera_smoothing number?
--[[
#    Smooths rotation of camera when in cinematic mode, 0 to disable. Enter cinematic mode by using the key set in Controls.
#
#    Requires: keyboard_mouse
[client]
(Camera smoothing in cinematic mode) 0.7 0.0 0.99
]]
---@field cinematic_camera_smoothing number?
--[[
#    If enabled, you can place nodes at the position (feet + eye level) where you stand.
#    This is helpful when working with nodeboxes in small areas.
[client]
(Build inside player) false
]]
---@field enable_build_where_you_stand boolean?
--[[
#    If enabled, "Aux1" key instead of "Sneak" key is used for climbing down and
#    descending.
[client]
(Aux1 key for climbing/descending) false
]]
---@field aux1_descends boolean?
--[[
#    Double-tapping the jump key toggles fly mode.
[client]
(Double tap jump for fly) false
]]
---@field doubletap_jump boolean?
--[[
#    If disabled, "Aux1" key is used to fly fast if both fly and fast mode are
#    enabled.
(Always fly fast) true
]]
---@field always_fly_fast boolean?
--[[
#    If enabled, the "Sneak" key will toggle when pressed.
#    This functionality is ignored when fly is enabled.
[client]
(Toggle Sneak key) false
]]
---@field toggle_sneak_key boolean?
--[[
#    If enabled, the "Aux1" key will toggle when pressed.
[client]
(Toggle Aux1 key) false
]]
---@field toggle_aux1_key boolean?
--[[
#    The time in seconds it takes between repeated node placements when holding
#    the place button.
#
#    Requires: keyboard_mouse
[client]
(Place repetition interval) 0.25 0.16 2.0
]]
---@field repeat_place_time number?
--[[
#    The minimum time in seconds it takes between digging nodes when holding
#    the dig button.
[client]
(Minimum dig repetition interval) 0.0 0.0 2.0
]]
---@field repeat_dig_time number?
--[[
#    Automatically jump up single-node obstacles.
[client]
(Automatic jumping) false
]]
---@field autojump boolean?
--[[
#    Prevent digging and placing from repeating when holding the respective buttons.
#    Enable this when you dig or place too often by accident.
#    On touchscreens, this only affects digging.
[client]
(Safe digging and placing) false
]]
---@field safe_dig_and_place boolean?

-- -------------------- [Controls] [*Keyboard and Mouse] -------------------- --

---@class _.LuantiSettings.controls.keyboard_and_mouse
--[[
#    Invert vertical mouse movement.
#
#    Requires: keyboard_mouse
[client]
(Invert mouse) false
]]
---@field invert_mouse boolean?
--[[
#    Mouse sensitivity multiplier.
#
#    Requires: keyboard_mouse
[client]
(Mouse sensitivity) 0.2 0.001 10.0
]]
---@field mouse_sensitivity number?
--[[
#    Enable mouse wheel (scroll) for item selection in hotbar.
#
#    Requires: keyboard_mouse
[client]
(Hotbar: Enable mouse wheel for selection) true
]]
---@field enable_hotbar_mouse_wheel boolean?
--[[
#    Invert mouse wheel (scroll) direction for item selection in hotbar.
#
#    Requires: keyboard_mouse
[client]
(Hotbar: Invert mouse wheel direction) false
]]
---@field invert_hotbar_mouse_wheel boolean?

-- ------------ [Controls] [*Keyboard and Mouse] [**Keybindings] ------------ --

---@class _.LuantiSettings.controls.keyboard_and_mouse.keybindings
--[[
#    WIPDOC
[client]
(Move forward) SYSTEM_SCANCODE_26
]]
---@field keymap_forward _.LuantiSettings.key?
--[[
#    Will also disable autoforward, when active.
[client]
(Move backward) SYSTEM_SCANCODE_22
]]
---@field keymap_backward _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Move left) SYSTEM_SCANCODE_4
]]
---@field keymap_left _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Move right) SYSTEM_SCANCODE_7
]]
---@field keymap_right _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Jump) SYSTEM_SCANCODE_44
]]
---@field keymap_jump _.LuantiSettings.key?
--[[
#    Also used for climbing down and descending in water if aux1_descends is disabled.
[client]
(Sneak) SYSTEM_SCANCODE_225
]]
---@field keymap_sneak _.LuantiSettings.key?
--[[
#    Key for digging, punching or using something.
#    (Note: The actual meaning might vary on a per-game basis.)
[client]
(Dig/punch/use) KEY_LBUTTON
]]
---@field keymap_dig _.LuantiSettings.key?
--[[
#    Key for placing an item/block or for using something.
#    (Note: The actual meaning might vary on a per-game basis.)
[client]
(Place/use) KEY_RBUTTON
]]
---@field keymap_place _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Open inventory) SYSTEM_SCANCODE_12
]]
---@field keymap_inventory _.LuantiSettings.key?
--[[
#    Key for moving fast in fast mode.
[client]
(Aux1) SYSTEM_SCANCODE_8
]]
---@field keymap_aux1 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Open chat) SYSTEM_SCANCODE_23
]]
---@field keymap_chat _.LuantiSettings.key?
--[[
#    Key for opening the chat window to type commands.
[client]
(Command) SYSTEM_SCANCODE_56
]]
---@field keymap_cmd _.LuantiSettings.key?
--[[
#    Key for opening the chat window to type local commands.
[client]
(Local command) SYSTEM_SCANCODE_55
]]
---@field keymap_cmd_local _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle unlimited view range)
]]
---@field keymap_rangeselect _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle fly) SYSTEM_SCANCODE_14
]]
---@field keymap_freemove _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle pitchmove)
]]
---@field keymap_pitchmove _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle fast) SYSTEM_SCANCODE_13
]]
---@field keymap_fastmove _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle noclip) SYSTEM_SCANCODE_11
]]
---@field keymap_noclip _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar: select next item) SYSTEM_SCANCODE_17
]]
---@field keymap_hotbar_next _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar: select previous item) SYSTEM_SCANCODE_5
]]
---@field keymap_hotbar_previous _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Mute) SYSTEM_SCANCODE_16
]]
---@field keymap_mute _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Increase volume)
]]
---@field keymap_increase_volume _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Decrease volume)
]]
---@field keymap_decrease_volume _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle automatic forward)
]]
---@field keymap_autoforward _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle cinematic mode)
]]
---@field keymap_cinematic _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle minimap) SYSTEM_SCANCODE_25
]]
---@field keymap_minimap _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Screenshot) SYSTEM_SCANCODE_69
]]
---@field keymap_screenshot _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle fullscreen) SYSTEM_SCANCODE_68
]]
---@field keymap_fullscreen _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Drop item) SYSTEM_SCANCODE_20
]]
---@field keymap_drop _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Zoom) SYSTEM_SCANCODE_29
]]
---@field keymap_zoom _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle HUD) SYSTEM_SCANCODE_58
]]
---@field keymap_toggle_hud _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle chat log) SYSTEM_SCANCODE_59
]]
---@field keymap_toggle_chat _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle large chat console) SYSTEM_SCANCODE_67
]]
---@field keymap_console _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle fog) SYSTEM_SCANCODE_60
]]
---@field keymap_toggle_fog _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle debug info) SYSTEM_SCANCODE_62
]]
---@field keymap_toggle_debug _.LuantiSettings.key?
--[[
#    Key for toggling the display of the profiler. Used for development.
[client]
(Toggle profiler) SYSTEM_SCANCODE_63
]]
---@field keymap_toggle_profiler _.LuantiSettings.key?
--[[
#    Key for toggling the display of mapblock boundaries.
[client]
(Toggle block bounds)
]]
---@field keymap_toggle_block_bounds _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Toggle camera mode) SYSTEM_SCANCODE_6
]]
---@field keymap_camera_mode _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Increase view range) SYSTEM_SCANCODE_46
]]
---@field keymap_increase_viewing_range_min _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Decrease view range) SYSTEM_SCANCODE_45
]]
---@field keymap_decrease_viewing_range_min _.LuantiSettings.key?
--[[
#    Modifier key bind for closing your world.
#    Requires ESC + the selected key to work.
[client]
(Return to Main Menu)
]]
---@field keymap_close_world _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 1) SYSTEM_SCANCODE_30
]]
---@field keymap_slot1 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 2) SYSTEM_SCANCODE_31
]]
---@field keymap_slot2 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 3) SYSTEM_SCANCODE_32
]]
---@field keymap_slot3 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 4) SYSTEM_SCANCODE_33
]]
---@field keymap_slot4 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 5) SYSTEM_SCANCODE_34
]]
---@field keymap_slot5 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 6) SYSTEM_SCANCODE_35
]]
---@field keymap_slot6 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 7) SYSTEM_SCANCODE_36
]]
---@field keymap_slot7 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 8) SYSTEM_SCANCODE_37
]]
---@field keymap_slot8 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 9) SYSTEM_SCANCODE_38
]]
---@field keymap_slot9 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 10) SYSTEM_SCANCODE_39
]]
---@field keymap_slot10 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 11)
]]
---@field keymap_slot11 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 12)
]]
---@field keymap_slot12 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 13)
]]
---@field keymap_slot13 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 14)
]]
---@field keymap_slot14 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 15)
]]
---@field keymap_slot15 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 16)
]]
---@field keymap_slot16 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 17)
]]
---@field keymap_slot17 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 18)
]]
---@field keymap_slot18 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 19)
]]
---@field keymap_slot19 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 20)
]]
---@field keymap_slot20 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 21)
]]
---@field keymap_slot21 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 22)
]]
---@field keymap_slot22 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 23)
]]
---@field keymap_slot23 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 24)
]]
---@field keymap_slot24 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 25)
]]
---@field keymap_slot25 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 26)
]]
---@field keymap_slot26 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 27)
]]
---@field keymap_slot27 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 28)
]]
---@field keymap_slot28 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 29)
]]
---@field keymap_slot29 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 30)
]]
---@field keymap_slot30 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 31)
]]
---@field keymap_slot31 _.LuantiSettings.key?
--[[
#    WIPDOC
[client]
(Hotbar slot 32)
]]
---@field keymap_slot32 _.LuantiSettings.key?


-- ------------------------ [Controls] [*Touchscreen] ----------------------- --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.touch_controls
--- | "auto"
--- | "true"
--- | "false"

---@class _.LuantiSettings.controls.touchscreen
--[[
#    Enables the touchscreen controls, allowing you to play the game with a touchscreen.
#    "auto" means that the touchscreen controls will be enabled and disabled
#    automatically depending on the last used input method.
#
#    Requires: touch_support
[client]
(Touchscreen controls) auto auto,true,false
]]
---@field touch_controls core.LuantiSettings.enums.touch_controls?

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.touch_interaction_style
--- | "tap"
--- | "tap_crosshair"
--- | "buttons_crosshair"

---@class _.LuantiSettings.controls.touchscreen
--[[
#    The kind of digging/placing controls used.
#
#    * Tap
#      Long/short tap anywhere on the screen to interact.
#      Interaction happens at finger position.
#
#    * Tap with crosshair
#      Long/short tap anywhere on the screen to interact.
#      Interaction happens at crosshair position.
#
#    * Buttons with crosshair
#      Use dedicated dig/place buttons to interact.
#      Interaction happens at crosshair position.
#
#    Requires: touchscreen
[client]
(Interaction style) tap tap,tap_crosshair,buttons_crosshair
]]
---@field touch_interaction_style core.LuantiSettings.enums.touch_interaction_style?

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.touch_punch_gesture
--- | "short_tap"
--- | "long_tap"

---@class _.LuantiSettings.controls.touchscreen
--[[
#    The gesture for punching players/entities.
#    This can be overridden by games and mods.
#
#    * Short tap
#      Easy to use and well-known from other games that shall not be named.
#
#    * Long tap
#      Known from the classic Luanti mobile controls.
#      Combat is more or less impossible.
#
#    Requires: touchscreen, touch_interaction_style_tap
[client]
(Punch gesture) short_tap short_tap,long_tap
]]
---@field touch_punch_gesture core.LuantiSettings.enums.touch_punch_gesture?

---@class _.LuantiSettings.controls.touchscreen
--[[
#    Touchscreen sensitivity multiplier.
#
#    Requires: touchscreen
[client]
(Touchscreen sensitivity) 0.2 0.001 10.0
]]
---@field touchscreen_sensitivity number?
--[[
#    The length in pixels after which a touch interaction is considered movement.
#
#    Requires: touchscreen
[client]
(Movement threshold) 20 0 100
]]
---@field touchscreen_threshold integer?
--[[
#    The delay in milliseconds after which a touch interaction is considered a long tap.
#
#    Requires: touchscreen
[client]
(Threshold for long taps) 400 100 1000
]]
---@field touch_long_tap_delay integer?
--[[
#    Fixes the position of virtual joystick.
#    If disabled, virtual joystick will center to first-touch's position.
#
#    Requires: touchscreen
[client]
(Fixed virtual joystick) false
]]
---@field fixed_virtual_joystick boolean?
--[[
#    Use virtual joystick to trigger "Aux1" button.
#    If enabled, virtual joystick will also tap "Aux1" button when out of main circle.
#
#    Requires: touchscreen
[client]
(Virtual joystick triggers Aux1 button) false
]]
---@field virtual_joystick_triggers_aux1 boolean?