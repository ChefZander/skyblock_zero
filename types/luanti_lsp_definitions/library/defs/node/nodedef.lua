---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Nodes
-- luanti/doc/lua_api.md: Definition tables > Node definition

-- NOTE: not practical to separate out every mutually exclusive fields as there
-- are too many states resulting in too many permutations.

--[[
WIPDOC
]]
---@alias core.NodeDef.keys
--- | core.ItemDef.keys
--- | "light_source"
--- | "drawtype"
--- | "visual_scale"
--- | "tiles"
--- | "overlay_tiles"
--- | "special_tiles"
--- | "color"
--- | "use_texture_alpha"
--- | "palette"
--- | "post_effect_color"
--- | "post_effect_color_shaded"
--- | "paramtype"
--- | "paramtype2"
--- | "place_param2"
--- | "wallmounted_rotate_vertical"
--- | "is_ground_content"
--- | "sunlight_propagates"
--- | "walkable"
--- | "pointable"
--- | "diggable"
--- | "climbable"
--- | "move_resistance"
--- | "buildable_to"
--- | "floodable"
--- | "liquidtype"
--- | "liquid_alternative_flowing"
--- | "liquid_alternative_source"
--- | "liquid_viscosity"
--- | "liquid_renewable"
--- | "liquid_move_physics"
--- | "air_equivalent"
--- | "leveled"
--- | "leveled_max"
--- | "liquid_range"
--- | "drowning"
--- | "damage_per_second"
--- | "node_box"
--- | "connects_to"
--- | "connect_sides"
--- | "mesh"
--- | "selection_box"
--- | "collision_box"
--- | "legacy_wallmounted"
--- | "legacy_facedir_simple"
--- | "waving"
--- | "mod_origin"
--- | "sounds"
--- | "drop"
--- | "on_construct"
--- | "on_destruct"
--- | "after_destruct"
--- | "on_flood"
--- | "preserve_metadata"
--- | "after_place_node"
--- | "after_dig_node"
--- | "can_dig"
--- | "on_punch"
--- | "on_rightclick"
--- | "on_dig"
--- | "on_timer"
--- | "on_receive_fields"
--- | "allow_metadata_inventory_move"
--- | "allow_metadata_inventory_put"
--- | "allow_metadata_inventory_take"
--- | "on_metadata_inventory_move"
--- | "on_metadata_inventory_put"
--- | "on_metadata_inventory_take"
--- | "on_blast"

-- -------------------------------------------------------------------------- --

--[[ NodeDef.drawtype split off into ./drawtype.lua ]]--

--[[
WIPDOC
]]
---@class core.NodeDef: core.ItemDef
--[[
When used for nodes: Defines amount of light emitted by node.
Otherwise: Defines texture glow when viewed as a dropped item
To set the maximum (14), use the value 'core.LIGHT_MAX'.
A value outside the range 0 to core.LIGHT_MAX causes undefined
behavior.
]]
---@field light_source core.Light.source?
--[[
visual_scale = 1.0,
Supported for drawtypes "plantlike", "signlike", "torchlike",
"firelike", "mesh", "nodebox", "allfaces".
For plantlike and firelike, the image will start at the bottom of the
node. For torchlike, the image will start at the surface to which the
node "attaches". For the other drawtypes the image will be centered
on the node.
]]
---@field visual_scale number?

--[[ NodeDef.tiles .. NodeDef.special_tiles split off into ./tiles.lua ]]--

-- ------------------------- color and transparency ------------------------- --

--[[
WIPDOC
]]
---@alias core.NodeDef.use_texture_alpha
--- | "opaque"
--- | "clip"
--- | "blend"

---@class core.NodeDef
--[[
color = ColorSpec,
The node's original color will be multiplied with this color.
If the node has a palette, then this setting only has an effect in
the inventory and on the wield item.
]]
---@field color core.ColorSpec?
--[[
use_texture_alpha = ...,
Specifies how the texture's alpha channel will be used for rendering.
Possible values:
* "opaque":
  Node is rendered opaque regardless of alpha channel.
* "clip":
  A given pixel is either fully see-through or opaque
  depending on the alpha channel being below/above 50% in value.
  Use this for nodes with fully transparent and fully opaque areas.
* "blend":
  The alpha channel specifies how transparent a given pixel
  of the rendered node is. This comes at a performance cost.
  Only use this when correct rendering
  among semitransparent nodes is necessary.
The default is "opaque" for drawtypes normal, liquid and flowingliquid,
mesh and nodebox or "clip" otherwise.
If set to a boolean value (deprecated): true either sets it to blend
or clip, false sets it to clip or opaque mode depending on the drawtype.

* @deprecated 5.X `true` may blend or clip, `false` had special handling depending on drawtype
]]
---@field  use_texture_alpha core.NodeDef.use_texture_alpha?
--[[
palette = "",
The node's `param2` is used to select a pixel from the image.
Pixels are arranged from left to right and from top to bottom.
The node's color will be multiplied with the selected pixel's color.
Tiles can override this behavior.
Only when `paramtype2` supports palettes.
]]
---@field  palette core.Texture?
--[[
post_effect_color = "#00000000",
Screen tint if a player is inside this node, see `ColorSpec`.
Color is alpha-blended over the screen.
]]
---@field post_effect_color core.ColorSpec?
--[[
post_effect_color_shaded = false,
Determines whether `post_effect_color` is affected by lighting.
]]
---@field post_effect_color_shaded boolean?

-- ---------------------------------- param --------------------------------- --

--[[ NodeDef.paramtype .. NodeDef.paramtype2 split off into ./paramtype2.lua ]]--

---@class core.NodeDef
--[[
place_param2 = 0,
Value for param2 that is set when player places node
]]
---@field place_param2 core.Param2?
--[[
wallmounted_rotate_vertical = false,
If true, place_param2 is nil, and this is a wallmounted node,
this node might use the special 90° rotation when placed
on the floor or ceiling, depending on the direction.
See the explanation about wallmounted for details.
Otherwise, the rotation is always the same on vertical placement.
]]
---@field wallmounted_rotate_vertical boolean?


-- -------------------------------------------------------------------------- --

--[[
WIPDOC
]]
---@alias core.NodeDef.move_resistance
--- | 0
--- | 1
--- | 2
--- | 3
--- | 4
--- | 5
--- | 6
--- | 7
--- | integer

---@class core.NodeDef
--[[
is_ground_content = true,
If false, the cave generator and dungeon generator will not carve
through this node.
Specifically, this stops mod-added nodes being removed by caves and
dungeons when those generate in a neighbor mapchunk and extend out
beyond the edge of that mapchunk.
]]
---@field is_ground_content boolean?
--[[
sunlight_propagates = false,
If true, sunlight will go infinitely through this node
]]
---@field sunlight_propagates boolean?
--[[
walkable = true,  -- If true, objects collide with node
]]
---@field walkable boolean?
--[[
pointable = true,
Can be `true` if it is pointable, `false` if it can be pointed through,
or `"blocking"` if it is pointable but not selectable.
Clients older than 5.9.0 interpret `pointable = "blocking"` as `pointable = true`.
Can be overridden by the `pointabilities` of the held item.
A client may be able to point non-pointable nodes, since it isn't checked server-side.
]]
---@field pointable boolean?
--[[
diggable = true,  -- If false, can never be dug
]]
---@field diggable boolean?
--[[
climbable = false,  -- If true, can be climbed on like a ladder
]]
---@field climbable boolean?
--[[
move_resistance = 0,
Slows down movement of players through this node (max. 7).
If this is nil, it will be equal to liquid_viscosity.
Note: If liquid movement physics apply to the node
(see `liquid_move_physics`), the movement speed will also be
affected by the `movement_liquid_*` settings.
]]
---@field move_resistance core.NodeDef.move_resistance?
--[[
buildable_to = false,  -- If true, placed nodes can replace this node
]]
---@field buildable_to boolean?
--[[
floodable = false,
If true, liquids flow into and replace this node.
Warning: making a liquid node 'floodable' will cause problems.
]]
---@field floodable boolean?


-- ---------------------------- liquid properties --------------------------- --

--[[
WIPDOC
]]
---@alias core.NodeDef.liquidtype
--- | "none"
--- | "source"
--- | "flowing"

--[[
WIPDOC
]]
---@alias core.NodeDef.liquid_viscosity
--- | 0
--- | 1
--- | 2
--- | 3
--- | 4
--- | 5
--- | 6
--- | 7
--- | integer

---@class core.NodeDef
--[[
liquidtype = "none",  -- specifies liquid flowing physics
* "none":    no liquid flowing physics
* "source":  spawns flowing liquid nodes at all 4 sides and below;
             recommended drawtype: "liquid".
* "flowing": spawned from source, spawns more flowing liquid nodes
             around it until `liquid_range` is reached;
             will drain out without a source;
             recommended drawtype: "flowingliquid".
If it's "source" or "flowing", then the
`liquid_alternative_*` fields _must_ be specified
]]
---@field liquidtype core.NodeDef.liquidtype?
--[[
`liquid_alternative_flowing` may contain the node name that represents
the flowing version of a liquid.

This field is required if `liquidtype ~= "none"` or
`drawtype == "flowingliquid"`.

Liquids consist of up to two nodes: source and flowing.

There are two ways to define a liquid:
1) Source node and flowing node. This requires both fields to be
   specified for both nodes.
2) Standalone source node (cannot flow). `liquid_alternative_source`
   must be specified and `liquid_range` must be set to 0.

Example:
    liquid_alternative_flowing = "example:water_flowing",
]]
---@field liquid_alternative_flowing string?
--[[
`liquid_alternative_source` may contain the node name that represents
the source version of a liquid.

This field is required if `liquidtype ~= "none"` or
`drawtype == "flowingliquid"`.

Liquids consist of up to two nodes: source and flowing.

There are two ways to define a liquid:
1) Source node and flowing node. This requires both fields to be
   specified for both nodes.
2) Standalone source node (cannot flow). `liquid_alternative_source`
   must be specified and `liquid_range` must be set to 0.

Example:
    liquid_alternative_source = "example:water_source",
]]
---@field liquid_alternative_source string?
--[[
liquid_viscosity = 0,
Controls speed at which the liquid spreads/flows (max. 7).
0 is fastest, 7 is slowest.
By default, this also slows down movement of players inside the node
(can be overridden using `move_resistance`)
]]
---@field liquid_viscosity core.NodeDef.liquid_viscosity?
--[[
liquid_renewable = true,
If true, a new liquid source can be created by placing two or more
sources nearby
]]
---@field liquid_renewable boolean?
--[[
liquid_move_physics = nil, -- specifies movement physics if inside node
* false: No liquid movement physics apply.
* true: Enables liquid movement physics. Enables things like
  ability to "swim" up/down, sinking slowly if not moving,
  smoother speed change when falling into, etc. The `movement_liquid_*`
  settings apply.
* nil: Will be treated as true if `liquidtype ~= "none"`
  and as false otherwise.
]]
---@field liquid_move_physics boolean?
--[[
air_equivalent = nil,
unclear meaning, the engine sets this to true for 'air' and 'ignore'
deprecated.
Unofficial note: But what else are you supposed to do? i guess make an is_air function lmao

* @deprecated 5.X
]]
---@field air_equivalent boolean?

-- --------------------------------- leveled -------------------------------- --

---@class core.NodeDef
--[[
leveled = 0,
Only valid for "nodebox" drawtype with 'type = "leveled"'.
Allows defining the nodebox height without using param2.
The nodebox height is 'leveled' / 64 nodes.
The maximum value of 'leveled' is `leveled_max`.
]]
---@field  leveled core.Param2.leveled?
--[[
leveled_max = 127,
Maximum value for `leveled` (0-127), enforced in
`core.set_node_level` and `core.add_node_level`.
Values above 124 might causes collision detection issues.
]]
---@field  leveled_max core.Param2.leveled?

-- -------------------------------------------------------------------------- --

--[[
WIPDOC
]]
---@alias core.NodeDef.liquid_range
--- | 0
--- | 1
--- | 2
--- | 3
--- | 4
--- | 5
--- | 6
--- | 7
--- | 8

---@class core.NodeDef
--[[
liquid_range = 8,
Maximum distance that flowing liquid nodes can spread around
source on flat land;
maximum = 8; set to 0 to disable liquid flow
]]
---@field liquid_range core.NodeDef.liquid_range?
--[[
drowning = 0,
Player will take this amount of damage if no bubbles are left
]]
---@field drowning integer?
--[[
damage_per_second = 0,
If player is inside node, this damage is caused
]]
---@field damage_per_second integer?

-- -------------------------- node shape properties ------------------------- --

--[[
WIPDOC
]]
---@alias core.NodeDef.connect_side
--- | "top"
--- | "bottom"
--- | "front"
--- | "left"
--- | "back"
--- | "right"

---@class core.NodeDef
--[[
node_box = {type = "regular"},  -- See "Node boxes"
]]
---@field node_box core.NodeBox?
--[[
connects_to = {},
Used for nodebox nodes with the type == "connected".
Specifies to what neighboring nodes connections will be drawn.
e.g. `{"group:fence", "default:wood"}` or `"default:stone"`
]]
---@field connects_to OneOrMany<core.Node.namelike>?
--[[
connect_sides = {},
Tells connected nodebox nodes to connect only to these sides of this
node. possible: "top", "bottom", "front", "left", "back", "right"
]]
---@field connect_sides core.NodeDef.connect_side[]?
--[[
mesh = "",
File name of mesh when using "mesh" drawtype
The center of the node is the model origin.
For legacy reasons, this uses a different scale depending on the mesh:
1. For glTF models: 10 units = 1 node (consistent with the scale for entities).
2. For obj models: 1 unit = 1 node.
3. For b3d and x models: 1 unit = 1 node if static, otherwise 10 units = 1 node.
Using static glTF or obj models is recommended.
You can use the `visual_scale` multiplier to achieve the expected scale.
]]
---@field  mesh core.Path?
--[[
selection_box = {
see [Node boxes] for possibilities
},
Custom selection box definition. Multiple boxes can be defined.
If "nodebox" drawtype is used and selection_box is nil, then node_box
definition is used for the selection box.
]]
---@field selection_box core.NodeBox?
--[[
collision_box = {
see [Node boxes] for possibilities
},
Custom collision box definition. Multiple boxes can be defined.
If "nodebox" drawtype is used and collision_box is nil, then node_box
definition is used for the collision box.
]]
---@field collision_box core.NodeBox?

-- -------------------------------------------------------------------------- --

--[[
WIPDOC
]]
---@alias core.NodeDef.waving
--- | 0
--- | 1
--- | 2
--- | 3

---@class core.NodeDef
--[[
Support maps made in and before January 2012
]]
---@field legacy_wallmounted boolean?
--[[
Support maps made in and before January 2012
]]
---@field legacy_facedir_simple boolean?
--[[
waving = 0,
Valid for drawtypes:
mesh, nodebox, plantlike, allfaces_optional, liquid, flowingliquid.
1 - wave node like plants (node top moves side-to-side, bottom is fixed)
2 - wave node like leaves (whole node moves side-to-side)
3 - wave node like liquids (whole node moves up and down)
Not all models will properly wave.
plantlike drawtype can only wave like plants.
allfaces_optional drawtype can only wave like leaves.
liquid, flowingliquid drawtypes can only wave like liquids.
]]
---@field  waving core.NodeDef.waving?

--[[ NodeDefBase.sounds split off into ./sounds.lua ]]--

--[[ NodeDef.drop split off into ./drop.lua ]]--

---@class core.NodeDef
--[[
mod_origin = "modname",
stores which mod actually registered a node
If the source could not be determined it contains "??"
Useful for getting which mod truly registered something
example: if a node is registered as ":othermodname:nodename",
nodename will show "othermodname", but mod_origin will say "modname"
]]
---@field mod_origin string?

-- -------------------------------- callbacks ------------------------------- --

--[[
WIPDOC
]]
---@alias core.NodeDef.on_construct fun(pos:ivec)

--[[
WIPDOC
]]
---@alias core.NodeDef.on_destruct fun(pos:ivec?)

--[[
WIPDOC
]]
---@alias core.NodeDef.after_destruct fun(pos:ivec, oldnode:core.Node.get)

--[[
WIPDOC
]]
---@alias core.NodeDef.on_flood fun(pos:ivec, oldnode:core.Node.get, newnode:core.Node.get):boolean?

--[[
WIPDOC
]]
---@alias core.NodeDef.preserve_metadata fun(pos:ivec, oldnode:core.Node.get, oldmeta:core.MetadataTable.node.get)

--[[
WIPDOC
]]
---@alias core.NodeDef.after_place_node fun(pos:ivec, placer:core.ObjectRef?, itemstack:core.ItemStack, pointed_thing:core.PointedThing)

--[[
WIPDOC
]]
---@alias core.NodeDef.after_dig_node fun(pos:ivec, oldnode:core.Node.get, oldmetadata:core.MetadataTable.node.get, digger:core.ObjectRef?)

--[[
WIPDOC
]]
---@alias core.NodeDef.can_dig fun(pos:ivec, player:core.ObjectRef?):boolean

--[[
WIPDOC
]]
---@alias core.NodeDef.on_punch fun(pos:ivec, node:core.Node.get, puncher:core.ObjectRef?, pointed_thing:core.PointedThing)

--[[
WIPDOC
]]
---@alias core.NodeDef.on_rightclick fun(pos:ivec, node:core.Node.get, clicker:core.ObjectRef?, itemstack:core.ItemStack, pointed_thing:core.PointedThing?):core.ItemStack?

--[[
WIPDOC

* @deprecated 5.X returning `nil` is the same are `true`
]]
---@alias core.NodeDef.on_dig fun(pos:ivec, node:core.Node.get, digger:core.ObjectRef?):boolean

--[[
WIPDOC
]]
---@alias core.NodeDef.on_timer fun(pos:ivec, elapsed:number, node:core.Node.get, timeout:number):boolean?

--[[
WIPDOC
]]
---@alias core.NodeDef.on_receive_fields fun(pos:ivec, formname:"", fields: core.FormspecFields, sender:core.ObjectRef)

--[[
WIPDOC
]]
---@alias core.NodeDef.allow_metadata_inventory_move fun(pos:ivec, from_list:core.InventoryList, from_index:integer, to_list:core.InventoryList, to_index:integer, count:integer, player:core.ObjectRef):integer

--[[
WIPDOC
]]
---@alias core.NodeDef.allow_metadata_inventory_put fun(pos:ivec, listname:core.InventoryList, index:integer, stack:core.ItemStack, player:core.ObjectRef):integer

--[[
WIPDOC
]]
---@alias core.NodeDef.allow_metadata_inventory_take fun(pos:ivec, listname:core.InventoryList, index:integer, stack:core.ItemStack, player:core.ObjectRef):integer

--[[
WIPDOC
]]
---@alias core.NodeDef.on_metadata_inventory_move fun(pos:ivec, from_list:core.InventoryList, from_index:integer, to_list:core.InventoryList, to_index:integer, count:integer, player:core.ObjectRef):nil

--[[
WIPDOC
]]
---@alias core.NodeDef.on_metadata_inventory_put fun(pos:ivec, listname:core.InventoryList, index:integer, stack:core.ItemStack, player:core.ObjectRef):nil

--[[
WIPDOC
]]
---@alias core.NodeDef.on_metadata_inventory_take fun(pos:ivec, listname:core.InventoryList, index:integer, stack:core.ItemStack, player:core.ObjectRef):nil

--[[
WIPDOC
]]
---@alias core.NodeDef.on_blast fun(pos:ivec, intensity:number?)

---@class core.NodeDef
--[[
on_construct = function(pos),
Node constructor; called after adding node.
Can set up metadata and stuff like that.
Not called for bulk node placement (i.e. schematics and VoxelManip).
Note: Within an on_construct callback, core.set_node can cause an
infinite loop if it invokes the same callback.
 Consider using core.swap_node instead.
default: nil
]]
---@field on_construct core.NodeDef.on_construct?
--[[
on_destruct = function(pos),
Node destructor; called before removing node.
Not called for bulk node placement.
default: nil
]]
---@field on_destruct core.NodeDef.on_destruct?
--[[
after_destruct = function(pos, oldnode),
Node destructor; called after removing node.
Not called for bulk node placement.
default: nil
]]
---@field after_destruct core.NodeDef.after_destruct?
--[[
on_flood = function(pos, oldnode, newnode),
Called when a liquid (newnode) is about to flood oldnode, if it has
`floodable = true` in the nodedef. Not called for bulk node placement
(i.e. schematics and VoxelManip) or air nodes. If return true the
node is not flooded, but on_flood callback will most likely be called
over and over again every liquid update interval.
Default: nil
Warning: making a liquid node 'floodable' will cause problems.
]]
---@field on_flood core.NodeDef.on_flood?
--[[
preserve_metadata = function(pos, oldnode, oldmeta, drops),
Called when `oldnode` is about be converted to an item, but before the
node is deleted from the world or the drops are added. This is
generally the result of either the node being dug or an attached node
becoming detached.
* `pos`: node position
* `oldnode`: node table of node before it was deleted
* `oldmeta`: metadata of node before it was deleted, as a metadata table
* `drops`: a table of `ItemStack`s, so any metadata to be preserved can
  be added directly to one or more of the dropped items. See
  "ItemStackMetaRef".
default: `nil`
]]
---@field preserve_metadata core.NodeDef.preserve_metadata?
--[[
after_place_node = function(pos, placer, itemstack, pointed_thing),
Called after constructing node when node was placed using
core.item_place_node / core.place_node.
If return true no item is taken from itemstack.
`placer` may be any valid ObjectRef or nil.
default: nil
]]
---@field after_place_node core.NodeDef.after_place_node?
--[[
after_dig_node = function(pos, oldnode, oldmetadata, digger),
Called after destructing the node when node was dug using
`core.node_dig` / `core.dig_node`.
* `pos`: node position
* `oldnode`: node table of node before it was dug
* `oldmetadata`: metadata of node before it was dug,
                 as a metadata table
* `digger`: ObjectRef of digger
default: nil
]]
---@field after_dig_node core.NodeDef.after_dig_node?
--[[
can_dig = function(pos, [player]),
Returns true if node can be dug, or false if not.
default: nil
]]
---@field can_dig core.NodeDef.can_dig?
--[[
on_punch = function(pos, node, puncher, pointed_thing),
default: core.node_punch
Called when puncher (an ObjectRef) punches the node at pos.
By default calls core.register_on_punchnode callbacks.
]]
---@field on_punch core.NodeDef.on_punch?
--[[
on_rightclick = function(pos, node, clicker, itemstack, pointed_thing),
default: nil
Called when clicker (an ObjectRef) used the 'place/build' key
(not necessarily an actual rightclick)
while pointing at the node at pos with 'node' being the node table.
itemstack will hold clicker's wielded item.
Shall return the leftover itemstack.
Note: pointed_thing can be nil, if a mod calls this function.
This function does not get triggered by clients <=0.4.16 if the
"formspec" node metadata field is set.
]]
---@field on_rightclick core.NodeDef.on_rightclick?
--[[
on_dig = function(pos, node, digger),
default: core.node_dig
By default checks privileges, wears out item (if tool) and removes node.
return true if the node was dug successfully, false otherwise.
Deprecated: returning nil is the same as returning true.
]]
---@field on_dig core.NodeDef.on_dig?
--[[
on_timer = function(pos, elapsed),
default: nil
called by NodeTimers, see core.get_node_timer and NodeTimerRef.
elapsed is the total time passed since the timer was started.
return true to run the timer for another cycle with the same timeout
value.
]]
---@field on_timer core.NodeDef.on_timer?
--[[
on_receive_fields = function(pos, formname, fields, sender),
fields = {name1 = value1, name2 = value2, ...}
formname should be the empty string; you **must not** use formname.
Called when an UI form (e.g. sign text input) returns data.
See core.register_on_player_receive_fields for more info.
default: nil
]]
---@field on_receive_fields core.NodeDef.on_receive_fields?
--[[
allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player),
Called when a player wants to move items inside the inventory.
Return value: number of items allowed to move.
]]
---@field allow_metadata_inventory_move core.NodeDef.allow_metadata_inventory_move?
--[[
allow_metadata_inventory_put = function(pos, listname, index, stack, player),
Called when a player wants to put something into the inventory.
Return value: number of items allowed to put.
Return value -1: Allow and don't modify item count in inventory.
]]
---@field allow_metadata_inventory_put core.NodeDef.allow_metadata_inventory_put?
--[[
allow_metadata_inventory_take = function(pos, listname, index, stack, player),
Called when a player wants to take something out of the inventory.
Return value: number of items allowed to take.
Return value -1: Allow and don't modify item count in inventory.
]]
---@field allow_metadata_inventory_take core.NodeDef.allow_metadata_inventory_take?
--[[
on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player),
Called after the actual action has happened, according to what was
allowed.
No return value.
]]
---@field on_metadata_inventory_move core.NodeDef.on_metadata_inventory_move?
--[[
on_metadata_inventory_put = function(pos, listname, index, stack, player),
Called after the actual action has happened, according to what was
allowed.
No return value.
]]
---@field on_metadata_inventory_put core.NodeDef.on_metadata_inventory_put?
--[[
on_metadata_inventory_take = function(pos, listname, index, stack, player),
Called after the actual action has happened, according to what was
allowed.
No return value.
]]
---@field on_metadata_inventory_take core.NodeDef.on_metadata_inventory_take?
--[[
on_blast = function(pos, intensity),
intensity: 1.0 = mid range of regular TNT.
If defined, called when an explosion touches the node, instead of
removing the node.
Unofficial note: this is a custom field, just documented in lua_api.md i assume because TNT mods usually don't handle indestructible nodes/whatever very well
]]
---@field on_blast core.NodeDef.on_blast?