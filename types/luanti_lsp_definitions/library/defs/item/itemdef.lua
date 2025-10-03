---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Items
-- luanti/doc/lua_api.md: Definition tables > Item definition

--[[
WIPDOC
]]
---@alias core.ItemDef.keys
--- | "description"
--- | "short_description"
--- | "groups"
--- | "inventory_image"
--- | "inventory_overlay"
--- | "wield_image"
--- | "wield_overlay"
--- | "wield_scale"
--- | "palette"
--- | "color"
--- | "stack_max"
--- | "range"
--- | "liquids_pointable"
--- | "pointabilities"
--- | "light_source"
--- | "tool_capabilities"
--- | "wear_color"
--- | "node_placement_prediction"
--- | "node_dig_prediction"
--- | "touch_interaction"
--- | "sounds"
--- | "on_place"
--- | "on_secondary_use"
--- | "on_drop"
--- | "on_pickup"
--- | "on_use"
--- | "after_use"

-- --------------------------------- ToolDef -------------------------------- --
--[[
WIPDOC
]]
---@class core.ToolDef : core.ItemDef
--[[
WIPDOC
]]
---@field tool_capabilities core.ToolCapabilities

-- ------------------------------- description ------------------------------ --

--[[
WIPDOC
]]
---@class core.ItemDef
--[[
Can contain new lines. "\n" has to be used as new line character.
See also: `get_description` in [`ItemStack`]
]]
---@field description string?
--[[
Must not contain new lines.
Defaults to nil.
Use an [`ItemStack`] to get the short description, e.g.:
  ItemStack(itemname):get_short_description()
]]
---@field short_description string?

-- -------------------------------------------------------------------------- --

---@class core.ItemDef
--[[
key = name, value = rating; rating = <number>.
If rating not applicable, use 1.
e.g. {wool = 1, fluffy = 3}
     {soil = 2, outerspace = 1, crumbly = 1}
     {bendy = 2, snappy = 1},
     {hard = 1, metal = 1, spikes = 1}
]]
---@field groups core.Groups.item?


-- ------------------------ inventory and wield image ----------------------- --

---@class core.ItemDef
--[[
Texture shown in the inventory GUI
Defaults to a 3D rendering of the node if left empty.
]]
---@field inventory_image core.Texture?
--[[
An overlay texture which is not affected by colorization
]]
---@field inventory_overlay core.Texture?
--[[
Texture shown when item is held in hand
Defaults to a 3D rendering of the node if left empty.
]]
---@field wield_image core.Texture?
--[[
Like inventory_overlay but only used in the same situation as wield_image
]]
---@field wield_overlay core.Texture?
--[[
Scale for the item when held in hand
]]
---@field wield_scale vector?
--[[
An image file containing the palette of a node.
You can set the currently used color as the "palette_index" field of
the item stack metadata.
The palette is always stretched to fit indices between 0 and 255, to
ensure compatibility with "colorfacedir" (and similar) nodes.
]]
---@field palette core.Texture?
--[[
Color the item is colorized with. The palette overrides this.
]]
---@field color core.ColorSpec?

-- -------------------------------------------------------------------------- --

---@class core.ItemDef
--[[
Maximum amount of items that can be in a single stack.
The default can be changed by the setting `default_stack_max`
]]
---@field stack_max integer?

-- ----------------------------- pointabilities ----------------------------- --

---@class core.ItemDef
--[[
Range of node and object pointing that is possible with this item held
Can be overridden with itemstack meta.
]]
---@field range number?
--[[
If true, item can point to all liquid nodes (`liquidtype ~= "none"`),
even those for which `pointable = false`
]]
---@field liquids_pointable boolean?

--[[ ItemDef.pointabilities split off into ./pointabilities.lua ]]--

-- -------------------------------------------------------------------------- --

--[[
WIPDOC
]]
core.LIGHT_MAX = 14

---@class core.ItemDef
--[[
When used for nodes: Defines amount of light emitted by node.
Otherwise: Defines texture glow when viewed as a dropped item
To set the maximum (14), use the value 'core.LIGHT_MAX'.
A value outside the range 0 to core.LIGHT_MAX causes undefined
behavior.
]]
---@field light_source core.Light.source?
--[[
See "Tool Capabilities" section for an example including explanation
]]
---@field tool_capabilities core.ToolCapabilities?
--[[
Set wear bar color of the tool by setting color stops and blend mode
See "Wear Bar Color" section for further explanation including an example
]]
---@field wear_color core.WearBarColor?
--[[
If nil and item is node, prediction is made automatically.
If nil and item is not a node, no prediction is made.
If "" and item is anything, no prediction is made.
Otherwise should be name of node which the client immediately places
on ground when the player places the item. Server will always update
with actual result shortly.
]]
---@field node_placement_prediction core.Node.name?
--[[
if "", no prediction is made.
if "air", node is removed.
Otherwise should be name of node which the client immediately places
upon digging. Server will always update with actual result shortly.
]]
---@field node_dig_prediction core.Node.name?

--[[ ItemDef.touch_interaction split off into ./touch_interaction.lua ]]--

--[[ ItemDef.sound split off into ./sound.lua ]]--

-- -------------------------------- callbacks ------------------------------- --

--[[
When the 'place' key was pressed with the item in hand
and a node was pointed at.
Shall place item and return the leftover itemstack
or nil to not modify the inventory.
The placer may be any ObjectRef or nil.
default: core.item_place
]]
---@alias core.ItemDef.on_place fun(itemstack:core.ItemStack, placer:core.ObjectRef?, pointed_thing:core.PointedThing): core.ItemStack?

--[[
Same as on_place but called when not pointing at a node.
Function must return either nil if inventory shall not be modified,
or an itemstack to replace the original itemstack.
The user may be any ObjectRef or nil.
default: nil
]]
---@alias core.ItemDef.on_secondary_use fun(itemstack:core.ItemStack, user:core.ObjectRef?, pointed_thing:core.PointedThing): core.ItemStack?

--[[
Shall drop item and return the leftover itemstack.
The dropper may be any ObjectRef or nil.
default: core.item_drop
]]
---@alias core.ItemDef.on_drop fun(itemstack:core.ItemStack, dropper:core.ObjectRef?, pos:vec): core.ItemStack?

--[[
Called when a dropped item is punched by a player.
Shall pick-up the item and return the leftover itemstack or nil to not
modify the dropped item.
Parameters:
* `itemstack`: The `ItemStack` to be picked up.
* `picker`: Any `ObjectRef` or `nil`.
* `pointed_thing` (optional): The dropped item (a `"__builtin:item"`
  luaentity) as `type="object"` `pointed_thing`.
* `time_from_last_punch, ...` (optional): Other parameters from
  `luaentity:on_punch`.
default: `core.item_pickup`
]]
---@alias core.ItemDef.on_pickup fun(itemstack: core.ItemStack, picker:core.ObjectRef?, pointed_thing:core.PointedThing?, time_from_last_punch:number?, tool_capabilities:core.ToolCapabilities?, dir:vec?, damage:integer?): core.ItemStack?

--[[
default: nil
When user pressed the 'punch/mine' key with the item in hand.
Function must return either nil if inventory shall not be modified,
or an itemstack to replace the original itemstack.
e.g. itemstack:take_item(); return itemstack
Otherwise, the function is free to do what it wants.
The user may be any ObjectRef or nil.
The default functions handle regular use cases.
]]
---@alias core.ItemDef.on_use fun(itemstack:core.ItemStack, user:core.ObjectRef?, pointed_thing:core.PointedThing): core.ItemStack?

--[[
default: nil
If defined, should return an itemstack and will be called instead of
wearing out the item (if tool). If returns nil, does nothing.
If after_use doesn't exist, it is the same as:
  function(itemstack, user, node, digparams)
    itemstack:add_wear(digparams.wear)
    return itemstack
  end
The user may be any ObjectRef or nil.
]]
---@alias core.ItemDef.after_use fun(itemstack:core.ItemStack, user:core.ObjectRef?, node:core.Node.get, digparams:core.DigParams): core.ItemStack?

---@class core.ItemDef
--[[
WIPDOC
]]
---@field on_place core.ItemDef.on_place?
--[[
WIPDOC
]]
---@field on_secondary_use core.ItemDef.on_secondary_use?
--[[
WIPDOC
]]
---@field on_drop core.ItemDef.on_drop?
--[[
WIPDOC
]]
---@field on_pickup core.ItemDef.on_pickup?
--[[
WIPDOC
]]
---@field on_use core.ItemDef.on_use?
--[[
WIPDOC
]]
---@field after_use core.ItemDef.after_use?