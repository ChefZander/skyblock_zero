### API

This section details the Unified Dyes API and how to use it with your mods.

In your node definition, you must include a few things to interface with Unified Dyes. Here is an example:

```lua
minetest.register_node("mymod:colored_node", {
	description = "My custom colored node",
	tiles = { "mymod_custom_colored_node.png" },
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	groups = {snappy = 1, cracky = 2, ud_param2_colorable = 1}
	airbrush_replacement_node = "mymod:my_other_colored_node",
	on_dig = unifieddyes.on_dig
})
```

`paramtype2` must be one of:
- "color": this is an 89-color or 256-color node
- "colorwallmounted": this is a 32-color node using "wallmounted" mode
- "colorfacedir": this node uses one of the "split" 89-color palettes.

`palette` must be set to match the `paramtype2` setting, and must be one of:
- "unifieddyes_palette.png"
- "unifieddyes_palette_extended.png"
- "unifieddyes_palette_colorwallmounted.png"
- or one of the "split" hues palettes (see below).

`groups`: If your node can be colored by using the airbrush, its groups entry must contain the key ud_param2_colorable = 1, among whatever else you'd normally put there. If the node is software-controlled, as might be the case for some mesecons-digilines aware node, then this group key should be omitted.

If your node if of the kind where you need the split palette, but you need to put the *full color name* into the node name, as opposed to just the hue, then add the keys `ud_color_start` and `ud_color_end` and set them to the positions of the first and last characters of the color name (where 1 is the first character of the mod name at the start of the node name, i.e. "mymod:foo_bar_orange_baz" would have the start set to 15 and the end at 20).

`airbrush_replacement_node`:  The node to swap in when the airbrush is used on this node.  For example, you could `minetest.override_item()` on some default node to add this field, pointing to a colorable node of your own, so that when the default node is painted, it's replaced with yours in the new color.

#### Function calls

**`unifieddyes.on_dig(pos, node, digger)`**

Set in a node definition's `on_dig` callback, this makes sure that if the player digs a neutral node, i.e. a colorable node that was left uncolored/white after placing, they receive a version of that item that has been stripped of its itemstack color setting, so that it is identical to what would have been in their inventory when that node was originally placed.  This prevents the engine splitting stacks of that item due to technically-different but visually-identical itemstack coloring.  This function is only needed in the definition of colorable versions of a node, not any uncolored counterparts.  For example, if you have a mod that has a simple, wooden chair, and the mod turns it into one with a colored seat cushion when you airbrush or craft it with dye, then only that latter colored-seat version needs this function.

**`unifieddyes.fix_rotation(pos, placer, itemstack, pointed_thing)`
`unifieddyes.fix_rotation_nsew(pos, placer, itemstack, pointed_thing)`**

These two are used to re-orient `wallmounted` nodes after placing. The former allows positioning to floor, ceiling, and four walls, while the latter restricts the rotation to just the four walls. The latter is most often used with a node whose model is designed so that the four wall positions actually place the model "upright", facing +/- X or Z. This is a hacky way to make a node look like it has basic `facedir` capability, while being able to use the 32-color palette.

**`unifieddyes.fix_after_screwdriver_nsew(pos, node, user, mode, new_param2)`**

This serves the same purpose as the `fix_rotation_nsew`, but is used to restrict the node's rotation after it's been hit with the screwdriver.

**`unifieddyes.is_buildable_to(placer_name, ...)`**

Again, another obvious one, returns whether or not the pointed node is `buildable_to` (can be overwritten by another node).

**`unifieddyes.get_hsv(name)`**

Accepts an item name, and returns the corresponding hue, saturation, and value (in that order), as strings.

If the item name is a color (not greyscale), then `hue` will be the basic hue for that color, saturation will be empty string for high saturation or "\_s50" for low, and value will be "dark_", "medium_", "light_", or an empty string if it's full color.

If the item name is greyscale, then `hue` will contain "white", "light_grey", "grey", "dark_grey", or "black", saturation will (ironically) be an empty string, and value will be "light_", "dark_", or empty string to correspond with the contents of `hue`.

For example:

* "mymod:mynode_red" would return ("red", "", "")
* "mymod:mynode_light_blue" would return ("blue", "", "light_")
* "mymod:mynode_dark_yellow_s50" would return ("yellow", "_s50", "dark_")
* "mymod:mynode_dark_grey" would return ("dark_grey", "", "dark_")

**`unifieddyes.getpaletteidx(color, palette_type)`**

When given a `color` string (in the form of "dye:foo" or "unifieddyes:foo") and `palette_type` (either a boolean or string), this function returns the numerical index into that palette, and the hue name as a string.
* `false` or `nil`: the 89-color palette
* `true`: 89 color "split" palette mode, for nodes that need full `facedir` support. In this case, the returned hue will be the color of whichever of the 13 "split" palettes the node is using, and the index will be 1-7, representing the shade within that palette. See my coloredwoods mod for more information on how this mode is used.  If the node is black, white, or grey, the hue will be set to 0. 
* `wallmounted`: the 32-color palette, for nodes using `colorwallmounted` mode.
* `extended`: the 256-color "extended" palette

**`unifieddyes.color_to_name(param2, def)`**

This function will attempt to return the name of the color indicated by `param2`.  `palette` tells the function which palette filename was used with that param2 value.  The returned value should be suitable as a dye item name when prefixed with "dye:".

**`unifieddyes.on_airbrush(itemstack, player, pointed_thing)`**

This is called when a node is punched while wielding the airbrush.

**`unifieddyes.show_airbrush_form(player)`**

This one does just what it sounds like - it shows the color selector formspec.

**`unifieddyes.register_color_craft(recipe)`**

This will loop through all of Unified Dyes' color lists, generating one recipe for every color in the palette given in the call.  Example usage:

```lua
	unifieddyes.register_color_craft({
		output = "mymod:colored_node 6",
		palette = "extended",
		neutral_node = "mymod:my_base_node_material",
		recipe = {
			{ "NEUTRAL_NODE", "MAIN_DYE",     "NEUTRAL_NODE" },
			{ "MAIN_DYE",     "NEUTRAL_NODE", "MAIN_DYE"     }, 
			{ "NEUTRAL_NODE", "MAIN_DYE",     "NEUTRAL_NODE" }
		}
	})
```

`output` is a standard item string as in the normal `minetest.register_craft()` call.

`palette` specifies the palette type to iterate through ("extended" and "wallmounted" are obvious, and if not specified, it'll use the 89 color palette).

`type` can be "shapeless" or unspecified/`nil`, and works the same as in the normal call.

`neutral_node` should specify the name of whatever item or node serves as the base, neutrally-colored material in your recipe.  This really only applies if your node is just made from one item (or more than one of the same item), plus one or more dyes.  If your node is just made from a collection of assorted items and no one item is really the neutral material, or anyway if you don't need this substitution, you must set it to an empty string.

`recipe` is the same as in the normal call, except that Unified Dyes will replace all instances of the string "NEUTRAL_NODE" with the item specified in the preceding `neutral_node` field.  Every instance of "MAIN_DYE" will be replaced with a portion of dye, as Unified Dyes' recipe helper works through its color lists (i.e. this field will become whatever dye is needed for each recipe).

`output_prefix` and `output_suffix`, if specified (must use both if at all), will cause the recipe registration to set to the output item to `output_prefix` + (hue) + `output_suffix` + `output`.  Used for mods that use the split 89-color palette.  `hue` will thus be one of the 12 hues, or "grey", as defined by the split palettes.  In this situation, you can set `output` to your recipe yield (with a leading space) if needed.  For example, if the prefix is "foo:bar", the suffix is "baz", and the output is set to " 3", then the craft helper will generate output item strings of the form "foo:bar_COLOR_baz 3", for each color in the table.

**`unifieddyes.make_colored_itemstack(itemstack, palette, color)`**

Makes a colored itemstack out of the given `itemstack` and `color` (as a dye, e.g. "dye:dark_red_s50"), setting the correct index per the `palette` field, which works as described above for `unifieddyes.getpaletteidx()`.  Said itemstack is returned as a string suitable for use as the output field of a craft recipe, equal in size to the itemstack passed into the function (e.g. if you give it "mymod:colored_node 7", it'll return a stack of 7 colored items).

**`unifieddyes.generate_split_palette_nodes(name, def, drop)`**

Does just what it sounds like - it registers all the nodes that are needed for a given base node (`def`) to be able to use the split palette, each named according to `name`, with the palette hue appended.  If a custom drop is needed, it can be passed along (only a string is allowed here, specifying a single item).  

#### Tables

In addition to the above API calls, Unified Dyes provides several useful tables

`unifieddyes.HUES` contains a list of the 12 hues used by the 89-color palette.

`unifieddyes.HUES_EXTENDED` contains a list of the 24 hues in the 256-color palette. Each line contains the color name and its RGB value expressed as three numbers (rather than the usual `#RRGGBB` string).

`unifieddyes.base_color_crafts` contains a condensed list of crafting recipes for all 24 basic hues, plus black and white, most of which have multiple alternative recipes. Each line contains the name of the color, up to five dye itemstrings (with `nil` in each unused space), and the yield for that craft. 

`unifieddyes.shade_crafts` contains recipes for each of the 10 shades a hue can take on, used with one or two portions of the dye corresponding to that hue. Each line contains the shade name with trailing "_", the saturation name (either "_s50" or empty string), up to three dye item strings, and the yield for that craft.

`unifieddyes.greymixes` contains the recipes for the 14 shades of grey. Each line contains the grey shade number from 1-14, up to four dye item names, and the yield for that craft.

#### Converting an old mod

If your mod used the old paradigm where you craft a neutral-colored item, place it, and punch with dye to color it, and you wish to convert it to colored itemstacks, take the following actions for each node:

* Remove these keys from your node definition:

```lua
	place_param2 = 240,
	after_dig_node = unifieddyes.after_dig_node,
	ud_replacement_node = "mod:some_node",
	on_dig = unifieddyes.on_dig
```

* Add the `airbrush_replacement_node` key to the node definition, if needed.

* Add a call to `unifieddyes.register_color_craft(recipe)`, the create-all-the-recipes helper described above (of course, you don't have to register any recipes if you don't want to, or you can roll your own, your choice).

**If your mod never has never used Unified Dyes at all**

* Remove all of your various colored node definitions, keeping only the one for the white version of your node, or delete them all, and keep whatever node you consider to be "neutral colored".

* Delete all of the colored texture files too, except keep the brightest, highest-contrast, most detailed one - whichever color that happens to be.  Most likely, red or green will be the best one.

* Convert that remaining texture to grayscale, enhance its contrast as much as you can without distorting it, and rename it and the node it'll be used to something neutral-sounding.

* Add the `palette` key to your neutral node definition, for example:

	`palette = "unifieddyes_palette_extended.png",`

* Adjust your node's groups to specify that the node can be colored.  Example (note the last item):

	`groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3, ud_param2_colorable = 1},`

* Remove all crafting recipes for all colored versions of that node, keeping only the one that makes the "neutral" one.

* Add the above recipes helper call (which replaces those delted recipes)

* If your colored node is based on someone else's neutral node, for example if you made a mod that creates multiple colors of minetest_game's default clay, you may find it best to create a single "stand-in" node that's identical to the neutral node, but named for your mod, hidden from the creative inventory, and which has a properly-prepared grayscale texture image in addition to the above keys.  Use `minetest.override_item()` to add the `palette` and `airbrush_replacement_node` keys, and the `ud_param2_colorable` group, to that "someone else's" node.  Then use that node and your custom, hidden node in the craft helper call.

* You will need to write a run-only-once LBM to convert your old statically-colored nodes to use hardware coloring.  See above for functions that will help reduce the work required for this part.

**If your mod has no colorable items**

If you wish to expand your mod to support color, just follow the above "never used" section, skipping the "remove/delete this and that" items, and of course omitting the LBM.
